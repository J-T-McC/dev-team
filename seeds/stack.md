# Technology Stack

> The Principal Engineer designs within this stack; changes require an ADR, approved as dev-team `workflow/handoffs.md` § Autonomy says. Setup fills it from the code (existing projects), from the Owner, or by the team when the Owner lets it pick (dev-team `workflow/stack-pick.md`). A row marked _open_ is chosen by the first plan that needs it, which proposes it for the approver § Autonomy names; never guess one.

**Product:** _open — what it is, who it's for, where it runs._

| Area | Choice | Notes |
|---|---|---|
| Languages | _open_ | versions included |
| Frameworks | _open_ | web, API, frontend |
| Infrastructure | _open_ | containers, orchestration |
| Cloud | _open_ | provider, regions |
| CI/CD | _open_ | pipeline, environments |
| Database | _open_ | engine, migration tool |
| Testing | _open_ | frameworks per test type |
| Static Analysis | _open_ | linters, type checkers |
| Formatting | _open_ | formatter, config location |
| Package Managers | _open_ | lockfile policy |
| Security | _open_ | secret management, dependency scanning |
| Performance | _open_ | budgets, profiling tools |
| Deployment | _open_ | strategy, rollback |
| Local development | _open_ | install, run and test on a developer's machine |

> **Optional — semantic code tools:** the development roles use symbol-level code navigation and editing automatically when the JetBrains MCP server is configured in this project. It gives IDE-grade analysis, but requires the IDE running with this project open. When the IDE registers the server itself it uses the product name (e.g. `phpstorm`); if configuring manually in `.mcp.json`, name it `jetbrains`. Both names are recognized (`phpstorm` covers PhpStorm; other JetBrains IDEs should use the manual `jetbrains` name).

> **Optional — browser automation:** the senior-developer and reviewer roles verify user-facing behavior in a real browser automatically when the Playwright MCP server is configured. Name it exactly `playwright` in `.mcp.json` (e.g. `npx @playwright/mcp`); any other name is not resolved by the agents' tool grants. Without it, roles fall back to CLI test runs via Bash.
