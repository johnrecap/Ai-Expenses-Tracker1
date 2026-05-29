---
name: agent-tooling-audit
description: Use before adding new agent skills, MCP servers, CLIs, or automation tools. Checks necessity, install method, security risk, token/context impact, and project fit.
---
# Agent Tooling Audit

## Checklist
1. Is this a real project need or just a shiny tool?
2. Is it an instruction skill, an executable tool, a Flutter package, or a reference repo?
3. Does it require secrets, broad filesystem access, browser control, or network access?
4. Can it be installed per-project instead of globally?
5. Does it duplicate an existing skill?
6. Add it to `docs/agent-playbooks/tooling-inventory.md` with install command, purpose, verification, and uninstall command.