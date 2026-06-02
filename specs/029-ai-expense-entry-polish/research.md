# Research: AI Expense Entry Polish

## Decision 1: Rebuild the AI input as a real text field surface

**Decision**: Use the existing app input theme principles: filled surface, clear focus border, and internal padding. Keep the text entry area separate from microphone and parse controls.

**Rationale**: The current AI input puts a `TextField` with zero content padding inside an outer container. That makes the text and hint feel like they are touching or escaping the field. A real input surface makes the visual boundary obvious and matches the rest of the app.

**Alternatives considered**:

- Keep the current outer container and only increase padding. This is faster but still mixes input text and action controls inside one visual field.
- Create a brand-new AI design language. Rejected because project rules require reusing existing theme and components.

## Decision 2: Keyboard done action should finish input, not keep typing active

**Decision**: Pressing the keyboard done/enter action should unfocus the field and trigger the same safe parse behavior if the text is not empty.

**Rationale**: Mohamed specifically reported that the keyboard stays open. The AI entry use case is usually one short sentence, so the primary mobile keyboard action should close the keyboard and move the user forward.

**Alternatives considered**:

- Keep multiline enter inserting new lines. Rejected as the primary behavior because it conflicts with the reported UX problem.
- Only hide keyboard when pressing Parse. Rejected because the keyboard done action would still feel broken.

## Decision 3: Save belongs under the AI result/review area

**Decision**: Place the save action directly under the AI panel and suggestion/review result. Manual correction fields can remain below as secondary editing tools.

**Rationale**: The AI flow should feel like "type, review, save". When the save button is below category/payment/manual cards, users are forced into a manual-form mental model.

**Alternatives considered**:

- Keep the save button at the bottom. Rejected because it is the exact UX problem reported.
- Duplicate save buttons at top and bottom. Rejected to avoid two competing primary actions.

## Decision 4: Refresh after AI save must be explicit

**Decision**: After successful AI save, refresh the shared expense-related state used by list, home, reports, and current budget.

**Rationale**: The app already refreshes these areas when `CreateExpenseBloc` succeeds, but AI save currently writes through its own cubit. That means the common refresh listener can be bypassed. An explicit refresh after AI save fixes the immediate user-facing problem.

**Alternatives considered**:

- Rely only on repository streams. Rejected because Mohamed sees stale data and some screens compute from one-time fetches.
- Refactor all saving flows now. Rejected for this feature because the immediate fix should stay scoped.

## Decision 5: Focused verification only

**Decision**: Use focused tests and analyzer commands on touched files and directly related tests.

**Rationale**: Project agent rules forbid broad full-project analysis for normal feature work. The issue is scoped to AI expense entry and refresh after save.

**Alternatives considered**:

- Run full `flutter analyze` and full `flutter test`. Rejected for this feature unless the user later asks for release-wide validation.
