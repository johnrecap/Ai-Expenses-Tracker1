# Contract: Real Data And No Mock Data

## Production Screen Rule

Any screen reachable by a normal user must use one of these states:

1. Real user data.
2. Loading state.
3. Empty state.
4. Error state.
5. Explicit unavailable state.

It must not show fake financial data, fake AI advice, fake AI history, fake premium plan, fake purchase success, or demo budgets as if they are real.

## Allowed Mock Usage

Mock data is allowed only in:

- Tests.
- Local design previews.
- Documentation examples.
- Explicit developer-only demo modes if isolated from production routing.

## Required Audits

Before a phase is complete, run focused searches for:

```powershell
rg -n "MockAiService|mock|demo|sample|placeholder|TODO|not available yet|Future.delayed" lib packages/expense_repository/lib
```

Each hit must be classified as:

- test-only or docs-only,
- honest unavailable UI,
- production blocker to remove.

## AI-Specific Rule

AI screens must not fall back to generated-looking local responses. If the gateway cannot answer, show quota, auth, network, empty, or unavailable.

## Finance-Specific Rule

Finance totals, budgets, reports, exchange rates, and exports must never invent values. If data is missing, say it is missing.
