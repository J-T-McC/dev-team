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

> **Optional — semantic code tools:** the development roles use symbol-level code navigation and editing automatically when the JetBrains MCP server is configured in this project. It gives IDE-grade analysis, but requires the IDE running with this project open. When the IDE registers the server itself it uses the product name (e.g. `phpstorm`); if configuring manually in `.mcp.json`, name it `jetbrains`. Both names are recognized (`phpstorm` covers PhpStorm; other JetBrains IDEs should use the manual `jetbrains` name).

> **Optional — browser automation:** the senior-developer and reviewer roles verify user-facing behavior in a real browser automatically when the Playwright MCP server is configured. Name it exactly `playwright` in `.mcp.json` (e.g. `npx @playwright/mcp`); any other name is not resolved by the agents' tool grants. Without it, roles fall back to CLI test runs via Bash.
