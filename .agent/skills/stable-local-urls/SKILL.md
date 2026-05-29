---
name: stable-local-urls
description: Use when a project has multiple local services or when agents/users need stable named localhost URLs instead of remembering ports.
---
# Stable Local URLs via portless

## Prerequisites
- `portless` installed: `npm install -g portless`

## Workflow
1. Prefer wrapping dev commands, e.g. `portless myapp npm run dev`.
2. Use readable names: `frontend`, `api`, `admin`, `storybook`.
3. Document the chosen local URLs in the project quickstart.

## Failure handling
- If `portless` is unavailable, report the normal localhost URL and port.