# Handoffs

Every artifact ends with a **Handoff** section containing exactly:

- **Inputs** — documents consumed to produce this artifact
- **Outputs** — what this artifact delivers
- **Dependencies** — external or cross-feature dependencies
- **Related** — other features by folder name, and the ADRs the work made or follows, so agents follow links instead of searching
- **Outstanding Questions** — open question documents blocking downstream work
- **Next Agent** — who consumes this artifact

## Handoff chain

| From → To | Artifact | Must contain | Gate |
|---|---|---|---|
| Product Owner → Product Manager | Feature request | Problem statement, target users | — |
| Product Manager → Designer *(UI)* or Principal Engineer *(no UI)* | PRD | Goals, user stories, testable acceptance criteria, out of scope, planned path | ✋ Owner approves PRD |
| Product Manager → next role on the path | Brief | The request (ticket link), testable acceptance criteria, out of scope, planned path | ✅ PM self-approves when it restates the request; ✋ Owner when it adds, cuts, or reinterprets scope |
| Any role → the role that called it | Discovery | The question, findings, recommendation, path change | — (feeds the caller's decision) |
| Designer → Principal Engineer | Design Spec + mockups | Concept, mockups of key screens, user flows, the states that occur, components, interactions, accessibility | ✅ PM approves against the PRD or brief |
| Principal Engineer → Senior Developer | Technical Plan (+ ADRs) when the PE chooses one, and task directory `<feature>/tasks/` | Architecture, data model, API, validation, risks; ordered task files with dependencies, files, acceptance criteria, testing | ✅ PE self-certifies; ✋ Owner decides any major decision it contains |
| Senior Developer → Reviewer | Implementation | Code + tests per task; completion notes in task files; statuses and a complete Review manifest (tier, base/head commits, test command) in the index | All tasks complete |
| Reviewer → Project Owner | Review | Summary, severity-classified findings, recommendation | ✋ Owner approves release |
| Product Owner → Senior Developer *(fast path: bugs/chores)* | Request | Observed vs. expected behavior | — (fix record written with the fix) |

## Rules

- A handoff is **invalid** if its approval gate has not passed. The receiving agent must refuse it.
- Exception, once per project: work adopted from before this organization carries `pre-adoption` in `<ws>/status.md` — its upstream gates are waived, its downstream gates are not (`workflow/adoption.md`).
- **The recorded path decides which gates apply.** A phase on the feature's path is required, and a handoff past it before its gate passes is invalid; a phase not on the path is not required. Acceptance criteria are required on every path except fast — in the brief or the PRD.
- A PRD or brief containing a **UX Direction** section must flow through the Designer: any downstream handoff (plan, tasks, implementation) for it without a PM-approved design spec is invalid. This rule is canonical here — other documents reference it.
- Outstanding Questions must be empty — or explicitly waived by the gate's approver — before downstream work starts.
- The receiving agent verifies the Handoff section before starting; anything missing goes back to the producing agent as a question document, not a guess.
- **Approval covers a commit, not a branch.** A review approves the head of its Reviewed range. Any commit pushed after it gets a delta review of that diff — the tests for what changed, not the whole suite — before release or merge. The release approver checks that the reviewed head is the head being released.

## Autonomy

How involved the Project Owner is, set per project by one line in the project `CLAUDE.md`: `Autonomy: supervised | standard | autonomous`. No line means **standard** — the gates in the chain above. Change it any time; it applies from the next gate and never reopens an approved one.

| Gate | supervised | standard | autonomous |
|---|---|---|---|
| PRD, or a brief that changes scope | ✋ Owner | ✋ Owner | ✅ PM self-approves; gaps it filled are listed under **Assumptions** |
| Design spec | ✋ Owner | ✅ PM | ✅ PM |
| Plan + task breakdown | ✋ Owner | ✅ PE self-certifies | ✅ PE self-certifies |
| Major decision (`workflow/overview.md`) | ✋ Owner | ✋ Owner | ✅ the owning role — PE in an ADR, PM in a PRD revision — the floor excepted |
| Each completed task | ✋ Owner checks before the next starts | — | — |
| Requirement question | ✋ Owner (PM drafts the answer) | ✅ PM as proxy | ✅ PM as proxy |
| A standard or stack row a plan or spec proposes (an _open_ section, or a change) | ✋ Owner | ✋ Owner | ✅ whoever signs that plan or spec |
| Release (feature → Done) | ✋ Owner | ✋ Owner | ✅ Orchestrator, on *Approve* or *Approve with follow-ups* (follow-ups filed as backlog items) |

- **The floor stays with the Owner at every level**: anything irreversible or destructive (including data-model changes affecting existing data), security-sensitive surfaces (auth, permissions, secrets, PII), anything that spends money, any action leaving the repository (deploy, publish, external messages), and recording the Owner or their surroundings (microphone, camera, screen). Roles use fake devices by default; a command that switches a browser or emulator to the host's microphone counts as recording. A real recording needs the Owner's go for that one recording — what, where, how long — asked through the coordinator. Release means *Done in `<ws>/status.md`*, never a deploy. Ticket-system writes that `<ws>/standards/tickets.md` allows are pre-authorized by that config (`workflow/tickets.md`), and Owner-board writes by turning the board on (`workflow/board.md`).
- **Overrides** follow the level: `Autonomy: autonomous; Owner keeps: PRD, release` holds named gates at ✋; `Owner waives: floor` delegates the floor too and must be written out explicitly.
- **Record who decided**: an approval made because of the level reads `Approved by: <role> (autonomy: <level>)` in the artifact, which is the record; `<ws>/status.md`'s Approvals cell only names the gates passed, with no history. At Done the orchestrator lists these lines from the feature's artifacts, so the Owner can audit everything decided without them.
- **Surface what was decided without the Owner.** When a feature reaches Done at any level below *supervised*, the Orchestrator's report lists, in a few lines, every decision the Owner did not sign for that feature: brief or PRD Assumptions, major decisions made by a role, and gates the level delegated. The audit trail is useless if nobody reads it.
- Autonomy never removes a gate, the independent review, or a role boundary — it only changes who signs. Fewer Owner checkpoints raise the bar on **Assume mistakes** below.

## Next work

Whether the team starts something new without being asked, and where it comes from: one line in the dev-team section, `Next work: owner | product | tickets | steered`. No line means **owner**. It is separate from the autonomy level, which decides who signs each gate; change either any time.

| Value | What the team starts next | When it stops |
|---|---|---|
| `owner` | only what the Owner hands it | after each piece of work |
| `product` | the next feature of the product the Owner described: the backlog items the PM filed from that description (`Source: the Owner's product description`, quoted in the first PRD), in the index's order | when all of them are Done; the Orchestrator then reports what was built and what the PM would do next |
| `tickets` | the next ticket the work query returns, in the ticket system's own order (`workflow/tickets.md`) | when the query has nothing new; a new ticket starts it again |
| `steered` | what the PM picks from the work query's tickets, if there's a ticket system, and the backlog, the team's own ideas included, balancing new features against cleanup and bugs by `<ws>/standards/planning.md` § Steering | when nothing above low priority is left, or the Owner says stop |

- **The Orchestrator asks for the next item** when a feature reaches Done, or when the team has room: no more items in flight than the team has developers (one, running in this conversation). The PM names it with one line of why; the Orchestrator routes it like any request.
- **The fence stays the Owner's.** `tickets` and `steered` take only what the work query returns, never a ticket outside it: the query's breadth is how much the team may choose. `product` builds only what was filed from the description; ideas the team files on the way wait in the backlog and never extend the run.
- **The backlog index's order is the queue** (`<ws>/standards/planning.md` § Backlog): an item at the top is ready whatever its promotion trigger says, since a trigger like "the Owner asks" can't fire while the Owner is away. Items parked on the Owner sit last and hold nothing up.
- **Gates and the floor still apply.** Every item passes the gates the autonomy level holds. An item waiting on the Owner holds only itself: the team carries on with the others.
- **Waking up.** Under Orca with check-ins, `groom` notices new tickets and `advance` starts the next item (`workflow/orca.md` § Check-ins). Otherwise the team keeps going while the coordinator's conversation runs, and picks up what arrived when the Owner next speaks.
- **Stopping:** the Owner says stop, or sets `owner`. Work in flight finishes; nothing new starts.

## Working hours

When the team works on its own, so the Owner can spread usage across the week: one line in the dev-team section, `Hours: <windows>`, in the machine's local time, e.g. `Hours: Mon–Fri 09:00–17:00`. Windows are separated by `;`, each `[<days>] <start>–<end>`: days like `Mon–Fri`, `Sat,Sun`, `weekdays` or `daily` (the default), and an end at or before its start runs past midnight. No line, or `any`, means any time. `${CLAUDE_PLUGIN_ROOT}/bin/hours` says whether the team is open now, and until when.

- **Outside hours the team starts nothing on its own:** no new item from Next work, no next task, review or follow-up, no check-in run.
- **The Owner's own asks still run.** Something the Owner asks for directly, at any hour, runs to its end, review included: it is spending they chose. Then the team stops again.
- **At closing, work in flight wraps up:** each role finishes at its next clean point with a hand-over note (§ Assume mistakes), as at the size limit, and stops. The next opening picks up from `<ws>/status.md` and those notes.
- Under Orca the plugin holds this (`workflow/orca.md` § Coordinator loop); in the conversation, the Orchestrator does.

## Assume mistakes

Every agent — you included — makes mistakes, and long sessions drift from their task. Treat your own output and every input as possibly wrong.

- **Before handing off, self-review against the source, not memory.** Re-read the assignment from disk (task file, PRD criteria, request) and check the output against each item. Look for: a criterion claimed without evidence; work beyond what was assigned; an assumption never confirmed; a placeholder or TODO left in; a contradiction with an upstream artifact or earlier decision; a test that would still pass if the code were wrong. State what you could not verify (`Unverified: …`) in the completion notes or Handoff — never hide it.
- **On receipt, question what smells.** An assignment can be wrong too — a request, a dispatch, a task, an upstream artifact. Smells: criteria that are untestable or contradict each other; a task that conflicts with the code, the plan, the standards, or the PRD's scope; a missing approval; a step that seems unnecessary or unexplained; an instruction that contradicts the documents (documents win). Blocking smell → question document to the owner (`workflow/communication.md`) and pause that item only; non-blocking → proceed and record it. Questioning is expected; deciding stays with the owner.
- **Watch for drift.** Cannot state the acceptance criteria without looking, editing files the task does not name, or reversing an earlier decision → stop, re-read the sources, and if the session is long, end at a clean boundary so a fresh context continues.
- **Hand over when you end mid-work.** Commit or push what is done, then write a **hand-over note** — done / state / left, a few lines each — in the task file's completion notes (fast path: the fix record), marked `partial`. The next session starts from that note, not from your context.
- **Close what you start, as soon as the step that needed it is done** — emulators and simulators, dev servers, browser windows, containers, volumes, worktrees, test data, tokens — not at the end of the task. Before reporting done, check that nothing you started still runs, and list what you closed or who still uses it.
- **Never open another maker's app on the Owner's machine** for a test or a probe (Excel, Numbers, Preview): a first launch can stop on a dialog no script answers, and its window lands on the Owner's screen. Make test files in code. The project's own app runs for its checks only while the Owner isn't using the machine, sends no input to any other window, and is quit after.
- **Stop at what you can't do.** Missing access, a step that needs a person, anything on the Agent limits list: mark the feature **blocked on Owner** with the exact ask (`<ws>/status.md` Blockers) — never guess, work around it, or fake the step.
- **Approving is verifying.** A delegated or self-approval gets the same scrutiny as an Owner approval — never a rubber stamp.

## Evidence

- **Claims about code cite the code.** Every statement a brief, plan, task, or review makes about how existing code or a library behaves names the file and line it was read from, followed through the state it is about: early returns, the function's other branches, a fixed list of copied keys. A helper, factory, or test utility is named only after opening it. A claim nobody read is written as an assumption, for the next role to check.
- **Open what you cite.** Before a hand-off, open every criterion, section, mockup note, list, or file the document cites, and check it says what your sentence needs. Something not written yet is cited as "once <role> adds it". A field is named by its key on the default branch, never by a question's word for it.
- **No hypothetical scope.** A requirement, acceptance criterion, task, or bug needs proof that it happens in a real flow: a reproduction, a log or data, or a code path a real user action reaches. Anything unproven gets one line — a note or question saying what would prove it — and is not built.
- **The smallest thing that does the job.** Planning roles propose it. An extra — a dashboard, a kill switch, a new system — goes in as one optional line with its cost, never as a criterion or the recommended answer. This trims scope, not thinking: say when there is a better way.

## Outside services

Paid services, and any third party that would start receiving requests from the project's environment:

- **Not needed → blocked.** A task that does not need one runs with outbound calls blocked (an internal network, or the hosts blocked), and proves the block works before it starts.
- **Needed → capped.** A task that does need one carries a request cap in its task file or spec, enforced by a counter in the script that refuses past the cap.
- **Both report actual request counts.**
- **Paid jobs run once or twice** on the Owner's go (the floor, § Autonomy), never in a retry loop.
