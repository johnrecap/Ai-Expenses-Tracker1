---
name: persistent-memory
description: Use when the user asks to remember project decisions, retrieve prior project context, summarize conventions, or maintain long-lived knowledge across sessions.
---
# Persistent Memory via memsearch

## Prerequisites
- `memsearch` installed, preferably via `uv tool install memsearch`.

## Workflow
1. Save stable decisions, architecture notes, and conventions as Markdown.
2. Search before planning work that depends on earlier decisions.
3. Never store secrets, tokens, passwords, or private customer data.
4. Summarize retrieved memory and cite the local note/file when possible.

## Failure handling
- If `memsearch` is unavailable, write or search project memory manually in `docs/agent-playbooks`.