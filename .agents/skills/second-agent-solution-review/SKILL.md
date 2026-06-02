---
name: second-agent-solution-review
description: Use when the user and Codex have discussed a problem, reached a tentative or approved solution, and the user wants a second agent to critique, debate, or validate the solution before implementation.
---

# Second Agent Solution Review

## Core Rule

When this skill triggers, do not stop at a one-shot subagent analysis. Run an actual critique loop: present the tentative solution to a second agent, ask it to challenge the plan, revise the plan, send the revision back, and continue until there are no material objections or the remaining tradeoffs are explicit.

## Workflow

1. Confirm the debate inputs:
   - problem statement
   - current agreed solution
   - user constraints and non-goals
   - files, logs, screenshots, or evidence already reviewed
   - what counts as success

2. Spawn a read-only `explorer` agent unless the user explicitly asked for implementation work.

3. Give the agent a focused prompt:
   - explain the problem and tentative solution
   - ask what is risky, insufficient, or overbuilt
   - ask for a better minimal plan
   - ask what should be tested now and what should be deferred
   - tell it not to edit files

4. Review the agent response yourself. Do not pass it through raw.

5. Send a second message to the same agent with your revised solution:
   - state which objections you accept
   - state which objections you reject and why
   - ask for final warnings or improvements

6. Repeat one more round only if the agent raises a new material risk. Stop after three critique rounds unless the user explicitly asks for deeper debate.

7. Report the synthesized result to the user:
   - what changed from the original plan
   - final recommended solution
   - what will be done now
   - what is intentionally deferred
   - risks or checks that still matter

8. If the debate materially changes a solution the user already approved, get user approval again before editing code.

## Prompt Template

```text
You are a critical engineering reviewer. Do not edit files.

Problem:
[short problem statement]

Tentative solution:
[current solution]

Constraints:
[user constraints and non-goals]

Evidence reviewed:
[files/screenshots/logs/commands]

Please challenge this solution:
- What is risky, insufficient, or overbuilt?
- Is there a safer or simpler approach?
- What should be implemented now?
- What should be deferred?
- What tests or verification are required?

Return a concise critique and revised recommendation.
```

## Common Mistakes

| Mistake | Correct behavior |
|---|---|
| Asking the second agent for analysis once | Run at least one critique-and-revision exchange |
| Letting the agent edit files during debate | Keep it read-only unless implementation was explicitly requested |
| Sending the entire thread without focus | Send a compact problem, tentative solution, constraints, and evidence |
| Accepting every objection blindly | Decide, explain, and send the revised plan back for final critique |
| Returning raw subagent output | Synthesize the final decision for the user |
| Continuing debate forever | Stop when objections are resolved or tradeoffs are explicit |

## Quality Bar

The final answer should make it clear that a real debate happened. It should name the accepted changes, rejected objections, final plan, and deferred work. If all you have is a second opinion, the skill was not completed.
