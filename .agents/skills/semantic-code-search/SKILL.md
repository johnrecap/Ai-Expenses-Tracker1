---
name: semantic-code-search
description: Use when the user describes a code behavior, feature, architecture concern, or data flow and you need to locate relevant implementation by meaning rather than exact text. Prefer rg for exact strings/errors.
---
# Semantic Code Search via osgrep

## Prerequisites
- `osgrep` installed: `npm install -g osgrep`
- Optional first-time setup: `osgrep setup`

## Workflow
1. Use exact search first when the user gives a symbol, exact text, or error.
2. Use `osgrep "<natural language query>"` when the user describes behavior.
3. Use `osgrep trace "<function_or_symbol>"` to inspect call relationships.
4. Report file paths, symbols, and why each result matters before editing.

## Failure handling
- If `osgrep` is missing, use `rg` and say semantic search is unavailable.
- If indexing fails, report the index path and the command output.