# Technology Stack

> **Placeholder** — fill in when adopting this organization for a project. The Principal Engineer designs within this stack; changes require an Owner-approved ADR. `TBD` means the Senior Developer and Principal Engineer must ask the Project Owner before choosing.

| Area | Choice | Notes |
|---|---|---|
| Languages | _TBD_ | versions included |
| Frameworks | _TBD_ | web, API, frontend |
| Infrastructure | _TBD_ | containers, orchestration |
| Cloud | _TBD_ | provider, regions |
| CI/CD | _TBD_ | pipeline, environments |
| Database | _TBD_ | engine, migration tool |
| Testing | _TBD_ | frameworks per test type |
| Static Analysis | _TBD_ | linters, type checkers |
| Formatting | _TBD_ | formatter, config location |
| Package Managers | _TBD_ | lockfile policy |
| Security | _TBD_ | secret management, dependency scanning |
| Performance | _TBD_ | budgets, profiling tools |
| Deployment | _TBD_ | strategy, rollback |

> **Optional — semantic code tools:** the development roles use symbol-level code navigation and editing automatically when a matching MCP server is configured in this project. Two supported options — configure either, named exactly `serena` or `jetbrains` in `.mcp.json`:
> - [Serena](https://github.com/oraios/serena) (`uv tool install serena-agent`, then `serena init`) — free, headless; works whenever agents run
> - JetBrains MCP server — richer IDE-grade analysis, but requires the IDE running with this project open
