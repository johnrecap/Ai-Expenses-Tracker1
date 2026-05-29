# Data Model: AI, Settings, Empty States, And Final QA

## AiAdviceViewData

- `id`
- `title`
- `summary`
- `severity`
- `accentToken`
- `relatedRoute`

## ChatBubbleViewData

- `id`
- `authorLabel`
- `text`
- `timestampLabel`
- `isUser`
- `textDirection`

## SuggestedPrompt

- `id`
- `label`
- `mockResponse`

## SettingsRowViewData

- `id`
- `iconName`
- `label`
- `valueLabel`
- `rowType`: chevron, toggle, static
- `initialToggleValue`

## EmptyStateViewData

- `id`
- `title`
- `body`
- `iconName`
- `ctaLabel`

## Validation Rules

- Chat send appends local mock data only.
- Settings toggles do not persist.
- Arabic messages use RTL direction and clean strings.
- Empty/not-found states do not load remote assets.
