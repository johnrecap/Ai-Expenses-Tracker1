#!/usr/bin/env python3
"""
AI Proxy Server for Ai-Expenses-Tracker1
=======================================
Acts as a secure proxy between the Flutter app and Gemini/Groq APIs.
- API keys are stored in server environment variables only
- Simple API key auth for the Flutter app
- Rate limiting per client
- Two endpoints:
  POST /parseExpense  -> Gemini (text to structured expense)
  POST /getAdvice     -> Groq (financial advice prompt)

Run: python3 app.py
Requires: Flask, requests, python-dotenv, redis (optional, for rate limiting)
"""

import os
import sys
import time
import json
import re
import logging
from datetime import datetime, timezone
from functools import wraps

from flask import Flask, request, jsonify, abort
from dotenv import load_dotenv
import requests

# Load .env from same directory
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger('ai-proxy')

app = Flask(__name__)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PROXY_API_KEY = os.environ.get('PROXY_API_KEY')
if not PROXY_API_KEY:
    logger.error('PROXY_API_KEY is not set. Set it in the server environment.')
    # Allow startup for local dev, but requests will fail auth

GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
GROQ_API_KEY = os.environ.get('GROQ_API_KEY')

GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-1.5-flash')
GROQ_MODEL = os.environ.get('GROQ_MODEL', 'llama3-8b-8192')

# Rate limiting
RATE_LIMIT_RPS = float(os.environ.get('RATE_LIMIT_RPS', '1'))   # requests per second
RATE_LIMIT_BURST = int(os.environ.get('RATE_LIMIT_BURST', '5')) # burst allowance

# In-memory rate limit store (use Redis in production)
_rate_limit_store = {}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _require_auth():
    """Validate the X-API-Key header against PROXY_API_KEY."""
    if not PROXY_API_KEY:
        abort(500, description='Server misconfiguration: PROXY_API_KEY not set')
    key = request.headers.get('X-API-Key', '')
    if not key or key != PROXY_API_KEY:
        logger.warning('Unauthorized request from %s', request.remote_addr)
        abort(401, description='Invalid or missing X-API-Key header')

def _get_client_id():
    """Use X-Client-ID if provided, otherwise fall back to IP."""
    return request.headers.get('X-Client-ID', request.remote_addr or 'unknown')

def _check_rate_limit(client_id: str) -> bool:
    """Simple token-bucket rate limiter (in-memory)."""
    now = time.time()
    bucket = _rate_limit_store.get(client_id, {'tokens': RATE_LIMIT_BURST, 'last': now})
    elapsed = now - bucket['last']
    bucket['tokens'] = min(RATE_LIMIT_BURST, bucket['tokens'] + elapsed * RATE_LIMIT_RPS)
    bucket['last'] = now
    if bucket['tokens'] < 1:
        _rate_limit_store[client_id] = bucket
        return False
    bucket['tokens'] -= 1
    _rate_limit_store[client_id] = bucket
    return True

def rate_limit(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        client_id = _get_client_id()
        if not _check_rate_limit(client_id):
            logger.warning('Rate limit exceeded for client %s', client_id)
            abort(429, description='Rate limit exceeded. Slow down.')
        return f(*args, **kwargs)
    return decorated

def _groq_parse_expense(text: str) -> dict:
    """Call Groq to parse free-form text into structured expense JSON (fallback)."""
    if not GROQ_API_KEY:
        raise RuntimeError('GROQ_API_KEY not configured on server')

    url = 'https://api.groq.com/openai/v1/chat/completions'
    headers = {
        'Authorization': f'Bearer {GROQ_API_KEY}',
        'Content-Type': 'application/json',
    }
    
    prompt = (
        "You are an expert expense parser for Arabic and English text. "
        "Extract the following fields from the user's text and return ONLY a valid JSON object:\n"
        "{\n"
        "  \"amount\": number (extract the numeric value, e.g., 200),\n"
        "  \"currency\": string (e.g., 'EGP', 'USD', 'SAR', default 'EGP' for Arabic),\n"
        "  \"category\": string (one of: food, transport, shopping, bills, entertainment, health, education, other),\n"
        "  \"description\": string (brief description in the same language as input),\n"
        "  \"date\": string (ISO 8601 date, use today's date if not specified, format: YYYY-MM-DD)\n"
        "}\n\n"
        "Examples:\n"
        "Input: \"200 جنيه أكل امبارح\"\n"
        "Output: {\"amount\": 200, \"currency\": \"EGP\", \"category\": \"food\", \"description\": \"أكل\", \"date\": \"2026-05-30\"}\n\n"
        "Input: \"50 جنيه مواصلات\"\n"
        "Output: {\"amount\": 50, \"currency\": \"EGP\", \"category\": \"transport\", \"description\": \"مواصلات\", \"date\": \"2026-05-30\"}\n\n"
        "Input: \"اشتريت هدوم بـ 500 من المحل\"\n"
        "Output: {\"amount\": 500, \"currency\": \"EGP\", \"category\": \"shopping\", \"description\": \"هدوم من المحل\", \"date\": \"2026-05-30\"}\n\n"
        "Now parse this input:\n"
        "\"" + text.replace('"', '\\"') + "\""
    )
    
    payload = {
        'model': GROQ_MODEL,
        'messages': [
            {
                'role': 'system',
                'content': 'You are an expert expense parser. Return ONLY valid JSON.'
            },
            {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.1,
        'max_tokens': 1024,
        'response_format': {'type': 'json_object'},
    }

    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    choices = data.get('choices', [])
    if not choices:
        raise RuntimeError('No choices in Groq response')
    
    raw_text = choices[0].get('message', {}).get('content', '')
    
    try:
        parsed = json.loads(raw_text)
    except json.JSONDecodeError:
        parsed = _fallback_parse(text)
    
    # Ensure all required fields exist
    if 'amount' not in parsed or parsed['amount'] is None:
        parsed['amount'] = _extract_amount(text)
    if 'currency' not in parsed or parsed['currency'] is None:
        parsed['currency'] = 'EGP' if any('\u0600' <= c <= '\u06FF' for c in text) else 'USD'
    if 'category' not in parsed or parsed['category'] is None:
        parsed['category'] = _detect_category(text)
    if 'description' not in parsed or parsed['description'] is None:
        parsed['description'] = text
    if 'date' not in parsed or parsed['date'] is None:
        parsed['date'] = datetime.now(timezone.utc).strftime('%Y-%m-%d')
    
    return parsed

def _gemini_parse_expense(text: str) -> dict:
    """Call Gemini to parse free-form text into structured expense JSON."""
    if not GEMINI_API_KEY:
        raise RuntimeError('GEMINI_API_KEY not configured on server')

    url = (
        f'https://generativelanguage.googleapis.com/v1beta/models/'
        f'{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}'
    )

    prompt = (
        "You are an expert expense parser for Arabic and English text. "
        "Extract the following fields from the user's text and return ONLY a valid JSON object:\n"
        "{\n"
        "  \"amount\": number (extract the numeric value, e.g., 200),\n"
        "  \"currency\": string (e.g., 'EGP', 'USD', 'SAR', default 'EGP' for Arabic),\n"
        "  \"category\": string (one of: food, transport, shopping, bills, entertainment, health, education, other),\n"
        "  \"description\": string (brief description in the same language as input),\n"
        "  \"date\": string (ISO 8601 date, use today's date if not specified, format: YYYY-MM-DD)\n"
        "}\n\n"
        "Examples:\n"
        "Input: \"200 جنيه أكل امبارح\"\n"
        "Output: {\"amount\": 200, \"currency\": \"EGP\", \"category\": \"food\", \"description\": \"أكل\", \"date\": \"2026-05-30\"}\n\n"
        "Input: \"50 جنيه مواصلات\"\n"
        "Output: {\"amount\": 50, \"currency\": \"EGP\", \"category\": \"transport\", \"description\": \"مواصلات\", \"date\": \"2026-05-30\"}\n\n"
        "Input: \"اشتريت هدوم بـ 500 من المحل\"\n"
        "Output: {\"amount\": 500, \"currency\": \"EGP\", \"category\": \"shopping\", \"description\": \"هدوم من المحل\", \"date\": \"2026-05-30\"}\n\n"
        "Now parse this input:\n"
        "\"" + text.replace('"', '\\"') + "\""
    )

    payload = {
        'contents': [
            {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.1,
        }
    }

    resp = requests.post(url, json=payload, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    # Extract text from Gemini response
    candidates = data.get('candidates', [])
    if not candidates:
        raise RuntimeError('No candidates in Gemini response')
    parts = candidates[0].get('content', {}).get('parts', [])
    if not parts:
        raise RuntimeError('No content parts in Gemini response')
    raw_text = parts[0].get('text', '')

    # Try to parse JSON from the text
    raw_text = raw_text.strip()
    # Remove markdown code fences if present
    raw_text = re.sub(r'^```json\s*', '', raw_text)
    raw_text = re.sub(r'```\s*$', '', raw_text)

    try:
        parsed = json.loads(raw_text)
    except json.JSONDecodeError:
        # Fallback: try to extract data using regex
        parsed = _fallback_parse(text)
    
    # Ensure all required fields exist
    if 'amount' not in parsed or parsed['amount'] is None:
        parsed['amount'] = _extract_amount(text)
    if 'currency' not in parsed or parsed['currency'] is None:
        parsed['currency'] = 'EGP' if any('\u0600' <= c <= '\u06FF' for c in text) else 'USD'
    if 'category' not in parsed or parsed['category'] is None:
        parsed['category'] = _detect_category(text)
    if 'description' not in parsed or parsed['description'] is None:
        parsed['description'] = text
    if 'date' not in parsed or parsed['date'] is None:
        parsed['date'] = datetime.now(timezone.utc).strftime('%Y-%m-%d')
    
    return parsed

def _fallback_parse(text: str) -> dict:
    """Fallback parsing when JSON parsing fails."""
    return {
        'amount': _extract_amount(text),
        'currency': 'EGP' if any('\u0600' <= c <= '\u06FF' for c in text) else 'USD',
        'category': _detect_category(text),
        'description': text,
        'date': datetime.now(timezone.utc).strftime('%Y-%m-%d'),
    }

def _extract_amount(text: str) -> float | None:
    """Extract numeric amount from text using regex."""
    # Look for numbers followed by currency words or symbols
    patterns = [
        r'(\d+(?:\.\d+)?)\s*(?:جنيه|جنايح|ريال|ريالات|دولار|دولارات|يورو|يوروه|بوند|باوند|شيكل)',
        r'(\d+(?:\.\d+)?)\s*(?:EGP|SAR|USD|EUR|GBP)',
        r'(?:بـ|بي|في|\$|€|£)?\s*(\d+(?:\.\d+)?)',
    ]
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            try:
                return float(match.group(1))
            except (ValueError, IndexError):
                continue
    return None

def _detect_category(text: str) -> str:
    """Detect expense category from Arabic/English text."""
    text_lower = text.lower()
    categories = {
        'food': ['أكل', 'اكل', 'طعام', 'فطار', 'عشاء', 'مطعم', 'ريستوران', 'كفتيريا', 'برجر', 'بيتزا', 'مكدونالدز', 'شاورما', 'كنتاكي', 'سبروماركت', 'كفتيريا', 'مطعم', 'طعام', 'food', 'eat', 'restaurant', 'cafe', 'burger', 'pizza', 'shawarma'],
        'transport': ['مواصلات', 'تكسي', 'أوبر', 'كاريم', 'بنزين', 'مترو', 'باص', 'قطار', 'طياران', 'سفر', 'رحلة', 'توكتوك', 'transport', 'taxi', 'uber', 'car', 'bus', 'train', 'metro', 'fuel', 'gas'],
        'shopping': ['هدوم', 'ملابس', 'حذاء', 'مستلزمات', 'مواد غذائية', 'سوبرماركت', 'بازار', 'سوق', 'شراء', 'تسوق', 'shopping', 'clothes', 'shoes', 'buy', 'purchase', 'market', 'mall', 'store'],
        'bills': ['فاتورة', 'كهرباء', 'مايه', 'نت', 'إنترنت', 'تلفون', 'رصيد', 'فواتير', 'bills', 'electricity', 'water', 'internet', 'phone', 'gas', 'rent'],
        'entertainment': ['سينما', 'فيلم', 'لعب', 'بلايستيشن', 'نادي', 'مقهى', 'ترفيه', 'فن', 'موسيقى', 'كونسيرت', 'حفلة', 'مسرح', 'مسراح', 'entertainment', 'cinema', 'movie', 'game', 'playstation', 'netflix', 'spotify', 'concert', 'party'],
        'health': ['دكتور', 'صيدلية', 'عيادة', 'مستشفى', 'دواء', 'صحة', 'رياضة', 'جم', 'مصاب', 'health', 'doctor', 'pharmacy', 'medicine', 'hospital', 'gym', 'fitness'],
        'education': ['كتب', 'كورس', 'دروس', 'جامعة', 'مدرسة', 'تعليم', 'دراسة', 'مذكرة', 'قلم', 'كراسة', 'education', 'book', 'course', 'school', 'university', 'tuition', 'learning'],
    }
    for category, keywords in categories.items():
        for keyword in keywords:
            if keyword in text_lower:
                return category
    return 'other'

def _groq_get_advice(prompt: str) -> str:
    """Call Groq to get financial advice based on a prompt."""
    if not GROQ_API_KEY:
        raise RuntimeError('GROQ_API_KEY not configured on server')

    url = 'https://api.groq.com/openai/v1/chat/completions'
    headers = {
        'Authorization': f'Bearer {GROQ_API_KEY}',
        'Content-Type': 'application/json',
    }
    payload = {
        'model': GROQ_MODEL,
        'messages': [
            {
                'role': 'system',
                'content': (
                    'You are a helpful financial advisor. Provide concise, actionable advice. '
                    'Always include a disclaimer that this is not professional financial advice.'
                )
            },
            {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
    }

    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()
    data = resp.json()
    choices = data.get('choices', [])
    if not choices:
        raise RuntimeError('No choices in Groq response')
    return choices[0].get('message', {}).get('content', '')

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.before_request
def before_request():
    if request.method == 'OPTIONS':
        return
    # Skip auth for health check
    if request.path == '/health':
        return
    _require_auth()

@app.after_request
def after_request(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, X-API-Key, X-Client-ID'
    return response

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'ok',
        'time': datetime.now(timezone.utc).isoformat(),
        'gemini_configured': bool(GEMINI_API_KEY),
        'groq_configured': bool(GROQ_API_KEY),
    })

@app.route('/parseExpense', methods=['POST'])
@rate_limit
def parse_expense():
    body = request.get_json(silent=True) or {}
    text = body.get('text', '').strip()
    if not text:
        abort(400, description='Missing "text" field in JSON body')

    logger.info('parseExpense called by %s', _get_client_id())
    
    # Try Gemini first, fallback to Groq
    errors = []
    
    if GEMINI_API_KEY:
        try:
            result = _gemini_parse_expense(text)
            return jsonify({
                'success': True,
                'data': result,
                'provider': 'gemini',
            })
        except Exception as e:
            logger.warning('Gemini failed, trying Groq: %s', e)
            errors.append(f'Gemini: {str(e)}')
    
    if GROQ_API_KEY:
        try:
            result = _groq_parse_expense(text)
            return jsonify({
                'success': True,
                'data': result,
                'provider': 'groq',
            })
        except Exception as e:
            logger.error('Groq also failed: %s', e)
            errors.append(f'Groq: {str(e)}')
    
    # Both failed
    logger.error('All providers failed: %s', errors)
    abort(500, description=f'All AI providers failed: {"; ".join(errors)}')

@app.route('/getAdvice', methods=['POST'])
@rate_limit
def get_advice():
    body = request.get_json(silent=True) or {}
    prompt = body.get('prompt', '').strip()
    expenses = body.get('expenses', [])
    if not prompt:
        abort(400, description='Missing "prompt" field in JSON body')

    logger.info('getAdvice called by %s', _get_client_id())
    try:
        # Build context from user expenses
        expense_context = ""
        if expenses:
            expense_context = "User expenses:\n"
            for exp in expenses:
                expense_context += f"- {exp.get('amount', 0)} {exp.get('currency', 'USD')} for {exp.get('category', 'unknown')}: {exp.get('description', '')}\n"
        
        full_prompt = f"{expense_context}\n\n{prompt}"
        advice = _groq_get_advice(full_prompt)
        return jsonify({
            'success': True,
            'advice': advice,
        })
    except requests.HTTPError as e:
        logger.error('Groq HTTP error: %s', e)
        abort(502, description=f'Upstream Groq error: {e.response.status_code}')
    except Exception as e:
        logger.error('Groq processing error: %s', e)
        abort(500, description='Failed to get advice')

# ---------------------------------------------------------------------------
# Error handlers
# ---------------------------------------------------------------------------

@app.errorhandler(400)
def bad_request(e):
    return jsonify({'success': False, 'error': str(e.description)}), 400

@app.errorhandler(401)
def unauthorized(e):
    return jsonify({'success': False, 'error': str(e.description)}), 401

@app.errorhandler(429)
def too_many_requests(e):
    return jsonify({'success': False, 'error': str(e.description)}), 429

@app.errorhandler(500)
def internal_error(e):
    return jsonify({'success': False, 'error': str(e.description)}), 500

@app.errorhandler(502)
def bad_gateway(e):
    return jsonify({'success': False, 'error': str(e.description)}), 502

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    port = int(os.environ.get('PORT', '8080'))
    debug = os.environ.get('FLASK_DEBUG', '0') == '1'
    logger.info('Starting AI Proxy on port %s (debug=%s)', port, debug)
    app.run(host='0.0.0.0', port=port, debug=debug)
