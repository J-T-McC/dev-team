# Workflow Overview

```
Product Owner
   ↓  feature request
Product Manager        — writes PRD                     → <feature>/prd.md
   ↓  ✋ Owner approves PRD
Designer (UI only)     — writes Design Spec + mockups   → <feature>/design.md, mockups/
   ↓  ✅ PM approves design against the PRD   (features without UI skip this phase)
Principal Engineer     — writes Technical Plan + ADRs
                         + task breakdown               → <feature>/plan.md, tasks/; <ws>/architecture/
   ↓  ✅ PE self-certifies — ✋ Owner only for major decisions
Senior Developer       — implements tasks + tests       → source code
   ↓  all tasks complete with notes
Reviewer               — reviews against criteria       → <feature>/review.md
   ↓  ✋ Owner approves release
Done
```


Each feature's documents live together in its own folder, `<feature>`; shared material — status, ADRs, backlog, fixes, standards, stack — sits in the workspace root, `<ws>`. Layout, naming, and where both live: `${CLAUDE_PLUGIN_ROOT}/workflow/workspace.md`.

## Paths — sized by the team

The diagram is the **full pipeline**, the longest path. Much work needs less, and the team decides how much — per piece of work, not by a fixed rule:

| Path | Typical work | Phases |
|---|---|---|
| Full | new product surface, several stakeholders, unclear scope | PRD → design (UI) → plan + ADRs → tasks → build → review |
| Brief | most ticket work | brief → [discovery] → [design] → [plan] → tasks → build → review |
| Fast | bugs and chores | fix + record (§ Fast path) |

- **Feasibility comes first.** Before sizing, the PM decides whether agents can do the work at all, against the project's **Agent limits** (`<ws>/standards/planning.md`): **agent** — triage as below; **split** — agents do their part, and the human steps go in the brief or PRD as **Owner tasks** the path waits on; **human** — no feature folder, one row in `<ws>/triage.md` (ticket, decision, reason) so it is never triaged again, and the Owner is told.
- **The PM triages** incoming work: a **brief** (`<feature>/brief.md`) when the request — usually a ticket — already says what is wanted, a **PRD** when it does not. Either one holds testable acceptance criteria (never optional: review needs something to check) and the **planned path**.
- **Each role decides its own phase** when the work reaches it, and records the decision on the path: the Designer runs only when the brief or PRD has UX Direction; the PE chooses a plan, tasks straight from the brief, or a single task, and writes an ADR only for a significant decision.
- **Discovery** is an optional, time-boxed investigation any role calls when unknowns block a decision — product (PM), technical (PE), UX (Designer). Findings go in `<feature>/discovery.md` and update the path.
- **Paths grow, never silently shrink.** A brief that turns out feature-sized becomes a PRD and the missing phases join the path. Removing a phase already on the path takes its owning role's stated reason.
- **Review is on every path but fast**, at the tier the PE sets: light (criteria and tests), standard, or deep.
- The Orchestrator records the path in the feature's status row and verifies gates only for phases on it (`workflow/handoffs.md`).

## Phases

1. **Requirements** — The Product Manager turns Product Owner intent into a brief or a PRD with testable acceptance criteria, explicit out-of-scope items, and the planned path.
2. **UX Design** *(UI features only)* — The Designer turns the approved PRD into a design with a committed concept and mockups of its key screens, plus a spec: user flows, the states that occur, components, interactions, accessibility.
3. **Technical Design** — The Principal Engineer turns the approved PRD (and design spec, if any) into a technical plan plus an ordered task breakdown (`<feature>/tasks/` — a status index and one file per task); significant decisions become ADRs.
4. **Implementation** — The Senior Developer implements tasks one at a time, with tests, recording completion notes in each task file and status in the index.
5. **Review** — The Reviewer verifies the implementation against acceptance criteria, the plan, the design spec (if any), and standards, then recommends a decision.
6. **Approval** — The Project Owner decides at the ✋ gates: PRD (or a brief that changes scope), release, and major decisions surfaced mid-pipeline.

## Owner attention (major decisions only)

The Owner is involved exactly three ways: approving PRDs and scope-changing briefs, approving releases, and deciding **major decisions** wherever they surface:

- New dependency, or any stack change
- Data-model change affecting existing data; anything irreversible or destructive
- Security-sensitive surface (auth, permissions, secrets, PII)
- Scope or requirement change to an approved PRD
- Anything an agent proposes as an ADR

Everything else is delegated: the **PM approves design specs** against the PRD; the **PE self-certifies plans and task breakdowns** (bringing only the major decision — not the whole plan — to the Owner when one appears); the Reviewer catches drift. Delegated approvals are recorded like any other: `Approved by: <role>` in the artifact and `<ws>/status.md`. The Owner can always demand review of anything; a project's `CLAUDE.md` may tighten or loosen the majors list. A project's **autonomy level** (supervised / standard / autonomous) shifts who signs each gate — canonical in `workflow/handoffs.md` § Autonomy.

## Fast path (small work — the team goes flat)

Not everything needs the pipeline or the whole team. Small work is delegated **directly to one role**, documented, and done — no gates, no other roles:

- **Bugs and chores** (broken behavior, typos, config, dependency bumps) → **Senior Developer**: fix + tests + a fix record (`${CLAUDE_PLUGIN_ROOT}/templates/fix.md`) in `<ws>/fixes/<date>-<slug>.md`. Reviewer only when the Owner asks or the developer flags risk.
- **Small changes and doc corrections** → the role that **owns the affected artifact**, which updates the doc in place and notes the change.

The one rule that keeps this safe: fast-path work is **truth-preserving** — it restores intended behavior or makes documents match reality. It never changes an approved decision, requirement, public interface, data model, or ADR; truth-preserving edits need no re-approval, decision-changing edits do. If work turns out feature-shaped mid-flight, stop and hand it to the Product Manager to triage into a brief or PRD.

## Backlog (work that is not now)

Deferred work is filed, not remembered: `<ws>/backlog/index.md` (open items + promotion log), `archive.md` (done and dropped), plus one `B<NNN>-<slug>.md` file per item — feature ideas and scope cuts, tech debt, and known bugs not being fixed yet. **Any role files** an item; the **Product Manager owns the index** — priority, status, promotion. Promotion is the only exit: a `feature` item becomes a brief or PRD and enters a path; a `bug` or `debt` item is delegated to the Senior Developer's fast path. `<ws>/status.md` tracks work in flight; the backlog tracks work not started, and nothing sits in both. Structure and rules are canonical in `<ws>/standards/planning.md`.

## Where work runs

A role is a set of rules, not a separate agent. By default all work runs in the main conversation with the owning role's skill invoked — fast-path fixes and full pipeline phases alike, one role at a time in linear sequence; the role's boundaries, artifacts, records, and gates apply exactly as if its agent had done the work, without agent startup cost. Spawning a role's agent buys exactly three things, and the startup cost is paid only when one is needed: **concurrency** (independent work streams running at once), **independence** (pipeline reviews always run in the reviewer agent — fresh eyes, never the conversation that produced or orchestrated the code), and **context relief** (a conversation grown too long hands a big phase to a fresh agent context).

Projects that opt into the **Orca runtime** run every role as a long-lived top-level peer session instead, never a subagent — rules in `${CLAUDE_PLUGIN_ROOT}/workflow/orca.md`.

### Models per role

The plugin pins **no model**: every role runs on the Owner's own choice — the session's model, or the configured default subagent model for agents. Default effort lives in each agent's frontmatter (`${CLAUDE_PLUGIN_ROOT}/agents/<role>.md`). A project overrides any role with one line in its `CLAUDE.md`:

```
- **Role models:** designer: opus/high; senior-developer: sonnet
```

`<role>: <model>[/<effort>]`; roles not listed use the Owner's default model. Use model aliases (`opus`, `sonnet`, `haiku`) — they track the latest release and are what the subagent tool accepts. Whoever starts a role's agent applies it: the orchestrator passes the model when spawning, and under the Orca runtime passes `--model`/`--effort` at launch. A role run **inline** uses the conversation's model; when the project pins a different model for a role, a full phase of that role is a reason to run it as its agent — quick questions stay inline.

## Rules

- Phases never advance without their gate: ✋ gates need explicit Project Owner approval, ✅ gates the named delegate's — both recorded in the artifact and in `<ws>/status.md`. Gate validity rules live in `workflow/handoffs.md`.
- The Orchestrator role routes work between phases and maintains `<ws>/status.md`, but owns no phase artifact.
- Any phase may send a question upstream (`${CLAUDE_PLUGIN_ROOT}/workflow/communication.md`); affected work pauses until answered.
- Rework flows backward through the same gates: a review Blocker returns work to the Senior Developer; a plan or task defect returns to the Principal Engineer and re-triggers certification; a design-spec defect returns to the Designer and re-triggers PM approval.
- Whether a feature has user-facing UI is the Product Manager's call, recorded **as the PRD's UX Direction section** — presence makes the Designer phase mandatory, absence routes directly to the Principal Engineer (enforcement in `workflow/handoffs.md`).
