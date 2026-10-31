# Communication Rules

## Resolution order

When an agent needs information it does not have, in strict order:

1. **Existing documentation** — search the workspace (`<ws>/` and the feature folders)
2. **Previous decisions** — ADRs in `<ws>/architecture/`, answered questions in `<feature>/questions/` (and related features' folders)
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

1. Create `<feature>/questions/q<NNN>-<slug>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/question.md`
2. Reference it in the asking artifact's **Outstanding Questions**
3. The responsible agent writes the answer in the same file and sets `Status: Answered`
4. If the answer changes an artifact, its owner updates it and re-requests approval

## Format

- Communicate through documents, not chat memory.
- Be concise; link to documents instead of restating them.
- One question per question document.

## Relaying the Owner

- **The Owner's words travel verbatim.** When passing an Owner observation, decision, or answer to a role, quote it exactly, then add any interpretation separately and mark it as yours. A paraphrase sends the role after the wrong cause.
- **The Owner as the hands.** When a check needs the Owner — a device, an account, a physical step — the role writes exact steps: device and build, what to do or say, for how long, what to look for, and what to send back. The coordinator relays them unchanged. One thing per round. The role collects logs itself wherever it can (for example, a local-only diagnostic build that writes to a file) rather than asking the Owner to read them.

## Plain language

Everything a role writes — artifacts, notes, questions, summaries, commit messages — is read by people and re-read by agents. Neither needs padding.

- Short sentences, common words. Say what was done or what is needed, then stop.
- No filler ("it is important to note"), no hedging, no restating the question or the upstream doc.
- Lead with the point; details after, only if they change what the reader does.
- Plain is not vague: names, numbers, criteria, and decisions stay exact.

**Code comments** follow the same rule. Comment only what the code cannot say: why a non-obvious choice was made, a constraint or workaround, a link to the issue or spec behind it. Never narrate what the code does, restate a name, log history ("changed X to Y"), or leave commented-out code. Most code needs no comments.
