# Research: Smart Add Entry

## Decision 1: Use one primary home add button

**Decision**: Replace the two stacked floating add/AI buttons with one primary add button.

**Rationale**: Adding an expense is the most repeated home-screen action. One button removes visual competition and gives the user one clear starting point.

**Alternatives considered**:

- Keep stacked buttons: rejected because AI and add compete visually.
- Move AI expense to the top bar: rejected because the top bar AI already means assistant/help.
- Put all add methods in bottom navigation: rejected because it would overload navigation.

## Decision 2: Use a bottom sheet for add choices

**Decision**: Tapping the add button opens a bottom sheet with add methods.

**Rationale**: A bottom sheet fits mobile use, supports short descriptions, and can show disabled/unavailable states without crowding the dashboard.

**Alternatives considered**:

- Popup menu: rejected because Arabic labels and subtitles can feel cramped.
- Full screen chooser: rejected because it adds unnecessary navigation for a frequent action.
- Inline dashboard cards: rejected because it would make the dashboard busier.

## Decision 3: Route AI text through the canonical AI text expense flow

**Decision**: The AI text choice must open `AppRoutes.expensesNewText`.

**Rationale**: The app already has both `AddExpenseAiTextScreen` and the older `AiExpenseScreen`. A single canonical target avoids maintaining two different AI expense experiences.

**Alternatives considered**:

- Use `AppRoutes.expensesNewAi`: rejected because the earlier review found it follows older behavior and can navigate inconsistently.
- Build a third AI add screen: rejected because it would increase duplication.

## Decision 4: Keep top-bar AI separate

**Decision**: The home top-bar AI icon remains assistant/help only.

**Rationale**: AI assistant and AI expense entry are different jobs. Keeping them separate makes the UI easier to understand.

**Alternatives considered**:

- Remove top-bar AI: rejected because it may still be useful for advice/help.
- Make top-bar AI open expense entry: rejected because it conflicts with the assistant meaning.

## Decision 5: Receipt must be honest

**Decision**: Receipt choice must be disabled, hidden, or clearly marked unavailable unless real receipt behavior is wired.

**Rationale**: Mohamed explicitly asked for no mock data and everything visible should work. A fake receipt flow would break user trust.

**Alternatives considered**:

- Keep receipt as a working-looking option: rejected because it risks fake behavior.
- Remove receipt permanently: rejected because the route/screen exists and may become real after the AI gateway work.

## Decision 6: Preserve the current design language

**Decision**: Use existing theme tokens and shared widgets only.

**Rationale**: The project rules say not to create a new design language. The smart add sheet should feel like part of the current app.

**Alternatives considered**:

- New colors or new button style: rejected unless Mohamed approves.
- Large redesign of the dashboard: rejected because this feature is only about the add entry point.
