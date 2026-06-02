# Contract: AI Gateway Quota Alignment

## Purpose

Separate local AI save credits from server-side AI request protection.

## Local AI Save Credit

- Counts successful saves from the AI entry flow.
- Stored locally.
- Does not require the server.
- Does not upload financial history.

## Gateway AI Request Quota

- Counts AI parse/advice/receipt requests at the gateway.
- Protects provider cost and abuse.
- Can require Firebase identity or another gateway identity mechanism.
- Returns user-safe quota status when a request is blocked.

## Required Behavior

- If local AI save credit is exhausted, do not call the gateway for a save-only action; show the local AI reward sheet.
- If the gateway blocks parsing, show the gateway quota message and do not consume local AI save credit.
- If the gateway succeeds but the user never saves the draft, do not consume local AI save credit.
- If a local/offline parser produces an AI draft and the user saves from the AI screen, consume local AI save credit.

## Privacy Rules

- Do not send raw expense history, merchant lists, descriptions, or receipt text for quota decisions.
- Parse requests may send only the current text the user explicitly typed for that AI action.
- Advice requests stay governed by the compact-summary contract from `specs/030-local-only-ai-on-demand/`.
