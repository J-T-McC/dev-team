# Communication Rules

## Resolution order

When an agent needs information it does not have, in strict order:

1. **Existing documentation** — search `docs/`
2. **Previous decisions** — ADRs in `docs/architecture/`, answered questions in `docs/questions/`
3. **Responsible upstream agent** — via a question document
4. **Project Owner** — last resort

Never skip a step. Never invent an answer.

## Chain of responsibility

Questions go to the owner of the information:

| Topic | Ask |
|---|---|
| Requirements, scope, priorities, UX direction | Product Manager |
| Design detail: screens, states, components, interactions | Designer |
| Architecture, technical design, technology, task scope and ordering | Principal Engineer |
| Implementation detail | Senior Developer |
| Process, routing, status | Orchestrator |
| New business decisions, major decisions, releases, anything unowned | Project Owner |

Never bypass the chain. Example: the Senior Developer must not ask the Project Owner to clarify a requirement — that question goes to the Product Manager, who consults the Owner if needed.

## Question protocol

1. Create `docs/questions/<feature-slug>-q<NNN>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/question.md`
2. Reference it in the asking artifact's **Outstanding Questions**
3. The responsible agent writes the answer in the same file and sets `Status: Answered`
4. If the answer changes an artifact, its owner updates it and re-requests approval

## Format

- Communicate through documents, not chat memory.
- Be concise; link to documents instead of restating them.
- One question per question document.
