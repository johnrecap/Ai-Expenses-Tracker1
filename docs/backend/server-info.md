# معلومات السيرفر والباكند

هذا الملف يلخص وضع الباكند الحالي لتطبيق AI Expenses Tracker عشان أي شغل على السيرفر أو قاعدة البيانات يبقى واضح وسريع.

## ملخص سريع

- التطبيق: Flutter / Dart.
- تسجيل الدخول: Firebase Auth.
- قاعدة بيانات التطبيق السحابية: Firestore.
- تخزين محلي على الموبايل: Drift / SQLite.
- باكند VPS: Node.js / TypeScript / Fastify في مجلد `server/`.
- قاعدة بيانات VPS: PostgreSQL 16، مع Redis اختياري.
- بوابة الذكاء الاصطناعي الحالية في التطبيق: Cloudflare Worker في `workers/ai-gateway`.
- بروكسي AI قديم/بديل: Python Flask في `server/ai-proxy`.
- ممنوع وضع مفاتيح Gemini أو Groq أو Firebase service account داخل Flutter أو Git.

## معلومات السيرفر المذكورة من جلسة السيرفر

هذه المعلومات جاية من تقرير السيرفر السابق، ولم يتم التحقق منها من هذا الجهاز:

| البند | القيمة |
| --- | --- |
| نظام التشغيل | Linux Ubuntu/Debian |
| Kernel | `6.8.0-117-generic` |
| مستخدم السيرفر | `hermeswebui` |
| Home | `/home/hermeswebui` |
| Workspace | `/workspace` |
| مسار المشروع على السيرفر | `/workspace/Ai-Expenses-Tracker1` |
| دومين API المذكور | `https://api.saeeddev.com` |
| مستودع Git المذكور | `git@github.com:johnrecap/Ai-Expenses-Tracker1.git` |

قبل أي تعديل إنتاجي، اتأكد من الدومين والخدمة الشغالة عليه:

```bash
curl -s https://api.saeeddev.com/health
```

## خريطة الباكند داخل المشروع

| الجزء | المسار | وظيفته |
| --- | --- | --- |
| VPS API | `server/` | API رئيسي للمزامنة، الحساب، المستخدم، وPostgreSQL |
| AI Python Proxy | `server/ai-proxy/` | بروكسي Flask لـ Gemini/Groq بنظام API key |
| Cloudflare AI Gateway | `workers/ai-gateway/` | بوابة AI الحالية المستخدمة من Flutter افتراضيا |
| Firebase rules/schema | `firestore.rules`, `docs/firebase/firestore-schema.md` | قواعد Firestore وشكل البيانات |
| Flutter config | `lib/core/config/app_config.dart` | رابط AI Gateway الذي يستخدمه التطبيق |

## الباكند الرئيسي: Fastify VPS API

المسار:

```bash
cd /workspace/Ai-Expenses-Tracker1/server
```

أو محليا داخل المشروع:

```bash
cd server
```

التقنيات:

- Node.js 20.
- TypeScript.
- Fastify.
- Firebase Admin SDK للتحقق من Firebase ID Token.
- PostgreSQL 16.
- Drizzle ORM.
- Redis اختياري للكاش أو rate limiting.

أهم الملفات:

| الملف | وظيفته |
| --- | --- |
| `server/src/app.ts` | إنشاء التطبيق وتسجيل المسارات |
| `server/src/main.ts` | تشغيل السيرفر |
| `server/src/config/env.ts` | قراءة وفحص متغيرات البيئة |
| `server/src/db/schema/` | جداول PostgreSQL |
| `server/src/db/migrations/` | migrations |
| `server/nginx.conf` | قالب Nginx |
| `server/.env.example` | مثال متغيرات البيئة |

المسارات المهمة:

| Method | Path | Auth | الوظيفة |
| --- | --- | --- | --- |
| GET | `/health` | لا | فحص أن السيرفر شغال |
| GET | `/metrics` | لا | Metrics |
| GET | `/api/users/me` | Firebase | بيانات المستخدم الحالي |
| GET | `/api/account` | Firebase | بيانات الحساب |
| POST | `/api/sync/push` | Firebase | رفع تغييرات من التطبيق للسيرفر |
| POST | `/api/sync/pull` | Firebase | سحب تغييرات من السيرفر للتطبيق |

متغيرات البيئة المهمة في `server/.env`:

```bash
NODE_ENV=production
HOST=0.0.0.0
PORT=8080
DATABASE_URL=postgres://USER:PASSWORD@HOST:5432/DB_NAME
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
LOG_LEVEL=info
```

تشغيل Docker:

```bash
cd /workspace/Ai-Expenses-Tracker1
docker compose up -d
docker compose logs -f server
```

تشغيل بدون Docker:

```bash
cd /workspace/Ai-Expenses-Tracker1/server
npm ci
npm run build
NODE_ENV=production node dist/src/main.js
```

أوامر قاعدة البيانات:

```bash
cd /workspace/Ai-Expenses-Tracker1/server
npm run db:generate
npm run db:migrate
npm run db:studio
```

## قاعدة بيانات VPS: PostgreSQL

PostgreSQL هي قاعدة بيانات الباكند الرئيسي في `server/`.

أهم متغير:

```bash
DATABASE_URL=postgres://USER:PASSWORD@HOST:5432/DB_NAME
```

مع Docker Compose:

```bash
POSTGRES_USER=ai_expenses
POSTGRES_PASSWORD=CHANGE_THIS
POSTGRES_DB=ai_expenses
POSTGRES_PORT=5432
```

فحص الاتصال داخل Docker:

```bash
docker compose ps
docker compose logs -f postgres
docker compose exec postgres pg_isready -U ai_expenses -d ai_expenses
```

مراجع مهمة:

- `docs/backend/postgres-backup-restore.md`
- `docs/backend/migration-cutover-rollback.md`
- `docs/backend/vps-postgres-runbook.md`

## Cloudflare AI Gateway

هذا هو مسار AI الحالي الذي يستخدمه Flutter افتراضيا.

المسار:

```bash
cd /workspace/Ai-Expenses-Tracker1/workers/ai-gateway
```

الرابط الافتراضي داخل التطبيق:

```text
https://ai-expenses-gateway.mohamedsaied-m20.workers.dev
```

مكانه في Flutter:

```text
lib/core/config/app_config.dart
```

يمكن تغييره وقت التشغيل:

```bash
flutter run --dart-define=AI_GATEWAY_URL=https://your-worker-url
```

المسارات:

| Method | Path | Auth | الوظيفة |
| --- | --- | --- | --- |
| POST | `/aiParse` | Firebase Bearer token | تحويل النص لمصروف |
| POST | `/aiReceipt` | Firebase Bearer token | قراءة إيصال |
| POST | `/aiAdvice` | Firebase Bearer token | نصائح AI |

إعدادات Cloudflare:

| النوع | الاسم |
| --- | --- |
| D1 Binding | `AI_DB` |
| Secret | `GEMINI_API_KEY` |
| Var | `FIREBASE_PROJECT_ID` |
| Var | `AI_PROVIDER` |
| Var | `AI_MODEL` |
| Var | `AI_PARSE_DAILY_USER_LIMIT` |
| Var | `AI_RECEIPT_DAILY_USER_LIMIT` |
| Var | `AI_ADVICE_DAILY_USER_LIMIT` |

أوامر محلية:

```bash
cd workers/ai-gateway
npm install
npm test
npm run typecheck
npm run migrate:local
npm run dev
```

نشر:

```bash
cd workers/ai-gateway
npm run migrate:remote
npm run deploy
```

مهم: مفتاح Gemini لا يتحط في `wrangler.toml`. يتحط Secret:

```bash
npx wrangler secret put GEMINI_API_KEY
```

## Python AI Proxy

هذا بروكسي Flask موجود في المشروع وقد يكون مستخدم على `api.saeeddev.com` حسب تقرير السيرفر السابق، لكنه ليس رابط AI الافتراضي في Flutter حاليا.

المسار:

```bash
cd /workspace/Ai-Expenses-Tracker1/server/ai-proxy
```

أهم الملفات:

| الملف | وظيفته |
| --- | --- |
| `app.py` | تطبيق Flask |
| `.env` | أسرار السيرفر |
| `.env.example` | مثال متغيرات البيئة |
| `requirements.txt` | مكتبات Python |
| `nginx.conf` | قالب Nginx/aaPanel |

المسارات:

| Method | Path | Auth | الوظيفة |
| --- | --- | --- | --- |
| GET | `/health` | لا | فحص الخدمة |
| POST | `/parseExpense` | `X-API-Key` | تحويل النص لمصروف |
| POST | `/getAdvice` | `X-API-Key` | نصائح مالية |

متغيرات البيئة:

```bash
PROXY_API_KEY=...
GEMINI_API_KEY=...
GROQ_API_KEY=...
GEMINI_MODEL=gemini-1.5-flash
GROQ_MODEL=llama3-8b-8192
RATE_LIMIT_RPS=1
RATE_LIMIT_BURST=5
PORT=5000
```

تشغيل:

```bash
cd /workspace/Ai-Expenses-Tracker1/server/ai-proxy
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

فحص:

```bash
curl -s http://127.0.0.1:5000/health
```

لو Nginx موجه للدومين:

```bash
curl -s https://api.saeeddev.com/health
```

تنبيه مهم: `app.py` يستخدم `PORT=8080` لو المتغير غير موجود، بينما `server/ai-proxy/nginx.conf` يفترض أن الخدمة على `5000`. لازم توحيد `PORT` مع إعداد Nginx.

## Firebase وFirestore

Firebase مستخدم في:

- Firebase Auth لتسجيل الدخول.
- Firestore لتخزين بيانات المستخدم والمصروفات والمحافظ والميزانيات.
- Firebase Admin SDK في باكند `server/` للتحقق من التوكنات.

ملفات مهمة:

| الملف | وظيفته |
| --- | --- |
| `firestore.rules` | قواعد الحماية |
| `firestore.indexes.json` | Indexes |
| `docs/firebase/firestore-schema.md` | شكل البيانات |
| `packages/expense_repository/lib/src/firebase/` | Repositories الخاصة بـ Firestore |

نقطة أمان:

- ملف Firebase service account يستخدم على السيرفر فقط.
- لا يتحط في Flutter.
- لا يتحط في Git.
- لو المفتاح اتسرب، يتعمل rotate فورا من Firebase Console.

## عند إضافة Database أو تعديل Sync

لو هتضيف جدول جديد على VPS:

1. عدل schema في `server/src/db/schema/`.
2. اعمل migration:

```bash
cd server
npm run db:generate
npm run db:migrate
```

3. عدل service/routes في `server/src/`.
4. أضف اختبارات في `server/tests/`.
5. لو Flutter هيستخدم API جديد، عدل client/repository في التطبيق.

لو هتعدل Firestore:

1. عدل models/entities في `packages/expense_repository`.
2. عدل `firestore.rules`.
3. عدل `docs/firebase/firestore-schema.md`.
4. أضف اختبار contract لو التغيير مؤثر.

## أوامر فحص سريعة على السيرفر

```bash
cd /workspace/Ai-Expenses-Tracker1
git status
git pull --ff-only
```

فحص API:

```bash
curl -s https://api.saeeddev.com/health
```

فحص العمليات:

```bash
ps aux | grep node
ps aux | grep python
ss -tlnp
```

فحص Docker:

```bash
docker compose ps
docker compose logs -f server
docker compose logs -f postgres
```

فحص Node backend:

```bash
cd server
npm run typecheck
npm run test
npm run build
```

فحص Worker:

```bash
cd workers/ai-gateway
npm test
npm run typecheck
```

## قواعد أمان لا تتكسر

- لا تضع أي API key في Flutter.
- لا تطبع مفاتيح أو tokens في logs.
- لا ترفع `.env` على Git.
- استخدم server env vars أو Cloudflare secrets.
- لو محتاج تغير رابط AI من Flutter، استخدم `--dart-define=AI_GATEWAY_URL=...`.
- أي screenshot أو log فيه token أو secret يتعامل كأنه تسريب.

## ملاحظات محتاجة تأكيد من السيرفر

- هل `https://api.saeeddev.com` يشير إلى Fastify VPS API أم Python AI Proxy؟
- هل Python AI Proxy مازال مستخدم فعليا، أم تم استبداله بـ Cloudflare Worker؟
- هل PostgreSQL الإنتاجي شغال من Docker Compose أم خدمة مستقلة؟
- هل Nginx الحالي مبني على `server/nginx.conf` أم `server/ai-proxy/nginx.conf`؟

أول أمر تأكيد عملي:

```bash
curl -s https://api.saeeddev.com/health
```

الناتج سيحدد الخدمة الشغالة حاليا على الدومين.
