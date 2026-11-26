# Picking a new project's stack

How the Principal Engineer chooses the stack for a new project: at setup, when the Owner lets the team pick, and at the first feature, when the stack was left for later. Canonical for these rules; other files reference it in ≤1 line. An existing project's stack is harvested from its code instead (`workflow/adoption.md`).

## Facts first

A stack picked without these facts is a guess. Ask the Owner for each one the description leaves out, in one round, each with a suggested answer and room for their own. Choose nothing until they are answered.

| Fact | Why it matters | Suggest |
|---|---|---|
| **Where it runs:** web, phone, desktop, an API or service, a command-line tool | the platform decides most of the stack | what the description implies; a web app when it only says "an app" |
| **Where it's hosted** | deploy, database, and running cost | one or two managed hosts with a free tier that fit; "on my machine" for a tool |
| **Who uses it, and how many** | sign-in, data, scale | "me and a few people" for a first version |
| **What it stores** | accounts, offline use, sensitive data (health, money, children's data) | what the description implies |
| **What it must use or connect to** | an existing service or account, a language the Owner reads, a company rule | nothing |

## Defaults for judgement

The goal is the most maintainable, scalable and hostable stack for this product, built from what already exists. These are defaults for judgement, not a ranking.

- **The platform comes first.** Choose what the product's platform needs, then apply the defaults below within it.
- **Backends and cores are compiled and strictly typed:** Rust first; Go is also fine.
- **UIs are TypeScript** on an established UI framework.
- **Desktop apps:** Tauri (Rust) or Wails (Go), with a TypeScript frontend.
- **One codebase while the product is simple.** A simple phone app plus a web app is React Native with shared TypeScript, not native Swift plus Kotlin.
- **No slow interpreted backends** (PHP, Python, Ruby), unless the Owner wants to read the code and knows the language, or the product needs that ecosystem (machine learning, data work).
- **Don't reinvent the wheel.** Established frameworks and libraries over custom code; managed services over running your own, where they fit the hosting answer.
- **Current.** Every choice is maintained today, and its version is the latest stable release, checked at pick time from its registry or official site, never from memory.
- **Local development is part of the stack:** how to install, run and test it on the Owner's machine. Use what `setup-detect` found installed when it fits; otherwise name what the first task installs.

## Recording it

- **`<ws>/stack/stack.md`:** the Product line and every row. A row the product doesn't need yet says `not needed yet`, not `_open_`.
- **`<ws>/architecture/adr-001-stack.md`**, from the plugin's `templates/adr.md`: the facts as the Question, the choice, one line per alternative weighed, and the reasoning tied to the facts. When the Owner let the team pick, it reads `Status: Accepted` and `Approved by: Principal Engineer (Owner delegated the stack at setup)`. Otherwise it is a major decision for the Owner (`workflow/handoffs.md` § Autonomy).
- **Money stays with the Owner** at every level (§ Autonomy, the floor). The ADR names the free option or the monthly cost of each paid one, and nothing is bought or signed up for until the Owner says yes.
