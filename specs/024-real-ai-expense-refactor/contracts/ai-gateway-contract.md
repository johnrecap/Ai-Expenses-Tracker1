# Contract: AI Gateway Usage From Flutter

## General Rules

- Flutter must not send `X-API-Key`.
- Flutter must not contain AI provider keys or shared proxy secrets.
- Flutter sends an authenticated user token in the `Authorization` header.
- Requests use JSON unless sending receipt image data.
- Logs must include only safe metadata such as status, request id, and error code.
- Raw user financial text and raw AI provider response bodies must not be logged.

## Endpoint: Parse Expense Text

Path:

```text
POST /aiParse
```

Required headers:

```text
Authorization: Bearer <signed-in-user-token>
Content-Type: application/json
```

Request body:

```json
{
  "input": "دفعت 250 جنيه أكل امبارح",
  "now": "2026-05-31T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "uuid",
  "categories": [
    {
      "categoryId": "food",
      "name": "Food",
      "isArchived": false
    }
  ],
  "recentExpenses": [],
  "budgetSummary": {}
}
```

Success response behavior:

- Response indicates success.
- Response includes a request id.
- Response includes structured expense data.
- Response may include quota status.

Failure response behavior:

- Response indicates failure.
- Response includes request id and error code.
- App maps error codes to friendly Arabic/English messages.
- Typed input remains on screen.

## Endpoint: Extract Receipt

Path:

```text
POST /aiReceipt
```

Required headers:

```text
Authorization: Bearer <signed-in-user-token>
Content-Type: application/json
```

Request body:

```json
{
  "imageBase64": "<base64 image data>",
  "mimeType": "image/jpeg",
  "now": "2026-05-31T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "uuid",
  "imageFingerprint": "safe-client-generated-fingerprint",
  "categories": []
}
```

Receipt rule:

- If the real endpoint is not available or not wired in Flutter, receipt mode must show a clear unavailable/manual fallback state instead of placeholder parsed data.

## Endpoint: Financial Advice

Path:

```text
POST /aiAdvice
```

Required headers:

```text
Authorization: Bearer <signed-in-user-token>
Content-Type: application/json
```

Request body:

```json
{
  "period": "month",
  "now": "2026-05-31T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "uuid",
  "summary": {}
}
```

## Acceptance Tests

- Search finds no Flutter usage of `PROXY_API_KEY`.
- Search finds no Flutter usage of `X-API-Key`.
- `/parseExpense` and `/getAdvice` old paths are not used by Flutter production code.
- Simulated quota error keeps typed input and shows a friendly message.
- Simulated auth error shows session guidance.
- Simulated network error allows retry/manual entry.

