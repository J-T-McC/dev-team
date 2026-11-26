# Recommended Orca setup (optional)

A preset for the Orca runtime (`workflow/orca.md`) that held up through weeks of daily use, so a new project's team runs well from the first day. A project opts in with `/dev-team:orca recommended [small | medium | large]`, or at setup, which offers it sized for the Owner's plan when it finds Orca. It writes the Runtime line and a **Team setup** section from `${CLAUDE_PLUGIN_ROOT}/seeds/orca-recommended.md` into the dev-team section. Every value stays the project's to change afterwards; `/dev-team:sync` reports Team setup rules added to the plugin later. This file says why each value is there. Where the plugin already does something, it points there instead of repeating it.

## Models, effort, advisor

- **Team model: claude-opus-5-5, for every role.** On the Claude Max plan this was tuned on, it is the strongest model without a weekly cap of its own, so the whole team can run all week on it.
- **Fallback model: none.** A fallback only helps if it has capacity left when the team model runs out. On that plan only claude-fable-5-2 has its own weekly cap, so a fallback pointing at it would spend the advisor's share. A project whose team model is the capped one sets the uncapped one as fallback (team model claude-fable-5-2, fallback claude-opus-5-5); everyone else leaves it at none. Check your own plan's limits.
- **Advisor: claude-fable-5-2, for the product-manager and principal-engineer.** The capped model goes where a wrong call costs most: hard questions other roles bring those two, and hard calls in their own plans, never routine work. The roles, the routing of hard questions, and the advisor staying off while its usage is out (`peer limits`) are plugin behaviour: `workflow/orca.md` § Launch settings.
- **Effort by role** is the plugin default, so the preset writes nothing for it: xhigh for the product-manager, designer, principal-engineer, reviewer, and the coordinator; high for senior developers (`workflow/overview.md` § Models per role). The thinking roles' calls shape everyone else's work; developers work from a plan that already made the hard calls.
- **Pinned on every launch.** `peer dispatch` already does this (`workflow/orca.md` § Launch settings): a side session's `/model` or `/effort` never reaches a peer.
- **Never a smaller model to save usage** (Team setup § Models). A weaker model's misses come back as review rounds and rework, which spend the usage it saved. Cut usage by keeping fewer peers awake, reading less, and running only the tests that matter.
- **Peer size limit 400k, worktree cards off, Owner board on, 2 slots.** 400k and 2 slots (`DEV_TEAM_SLOTS`) are the plugin defaults. The Owner board is the fuller view, so the cards stay off; `/dev-team:orca` offers `/dev-team:board`.

## Team shape

- **One home per role, each in its own worktree named after it** (Team setup § Homes), in three sizes by plan, since every home is another session drawing on the same usage limits:

  | Size | Plan | Homes |
  |---|---|---|
  | small | Pro | one of each: product, designer, architect, reviewer, developer |
  | medium | Max 5x | small plus a second developer |
  | large | Max 20x | two reviewers, four developers |

  `bin/setup-detect` suggests the size from the plan it reads (`suggest.runtime`); an unknown plan, an API key, or a Team or Enterprise plan is asked, with small suggested. On Pro, setup recommends running in the conversation instead, with small second: each Orca task starts a fresh session, and Pro's limits run out fast. A second reviewer means one review never waits behind another. A home's own worktree means no peer works in another's half-finished checkout; `peer dispatch` reuses a home's worktree when no `--worktree` is given. This replaces the plugin default of one worktree per feature and a child worktree per stream (`workflow/orca.md` § Topology, § Parallel streams).
- **A new home needs the Owner's yes.** Each home is another session on the machine and another share of usage. Without the preset, the coordinator adds developer homes itself (`workflow/orca.md` § Coordinator loop).
- **A fresh session per task, `--keep` only for a follow-up on the same PR,** and the coordinator waking and sleeping homes without asking: plugin defaults (`workflow/orca.md` § Peer lifetime, § Machine resources).

## Roles and git

- **Document roles never branch** (Team setup § Git). Their output is specs in the workspace; they need the code only to read, at the default branch's latest commit. An uncommitted workspace is reached from any worktree by its absolute path (`workflow/workspace.md` § Guest mode).
- **Each developer starts each task on a new branch from the default branch, and owns its branches.** Two peers on one branch overwrite each other's pushes, and a branch per task keeps each PR to one change. Streams no longer merge into a shared feature branch (`workflow/orca.md` § Parallel streams): each task is its own PR.
- **Reviews are read-only.** A reviewer that checks out a developer's branch can leave changes on it or move it under the developer. Fetch and diff, and test the reviewed commit, detached, in the reviewer's own worktree. That a reviewer never reviews a change it implemented is a plugin rule (`workflow/orca.md` § Peer lifetime).
- **Peers never merge a PR.** The merge puts a change on the branch everyone builds on, so it stays with the Owner.
- **The workspace is its own repository and is pushed** (Team setup § Workspace), so the specs reach every machine the team uses. `not committed` on the Workspace line makes it its own repository (`workflow/workspace.md` § The Workspace line, § Guest mode). The plugin's Stop hook commits it after each turn that changed it, and pushes it once it has an upstream.

## PR flow

- **A draft while building, every finished commit pushed, the body kept current** (Team setup § PRs). The Owner and the reviewer see real progress at any time, and nothing is lost with a session.
- **Ready only after our reviewer approves, at least a minute after the last push.** Ready asks people to review. The wait makes sure the PR they open is the commit our reviewer approved, with its checks already running.
- **Ready PRs batch their pushes.** Each push to a ready PR restarts its checks and moves the code under anyone reviewing it.
- **Each developer keeps its own PRs green and free of conflicts,** checking them between tasks. While its owner is not working, `peer watch` also tells the coordinator about a failing check or a conflict (`workflow/orca.md` § PRs).
- **One PR per ticket to start.** Splits and stacks are the team's call, each with a one-line reason in the plan. Stack mechanics: `<ws>/standards/coding.md` § Stacked PRs.

## Tests

- **Mid-work, only the tests for what changed, by explicit file list, checking the list is not empty** (Team setup § Tests). Many test runners treat an empty list as "run everything".
- **Related suites once, at the end; the full suite only when the coordinator's spec says so.** Several peers running full suites at once stall the machine. `/dev-team:orca` changes the seed testing standard's full suite for every task to match. The plugin has no guard that blocks a full run; the rule and the spec hold it.
- **Heavy jobs share 2 slots** (`workflow/orca.md` § Machine resources).
- **A local pass means zero failures.** A run with one known failure is not a pass, or the next real failure hides behind it.
- **A CI job that times out is run locally, not re-run.** A re-run waits out the whole timeout again; a local run shows where it hangs.

## Safety rails

The Owner fills each `⟨…⟩` in Team setup § Outside services. The plugin already blocks or caps third-party calls and has tasks report their counts (`workflow/handoffs.md` § Outside services), and has every role close what it starts (§ Assume mistakes). The preset adds:

- **Automated tests never call paid services,** whatever the cap: they run often and unattended.
- **New services and installs need the Owner's yes,** except reinstalling what the lockfiles already pin. Each one is a cost, an account, or new code from outside that the Owner should choose.
- **Production is queried only when an action depends on the result.** Every other read adds load to production and may touch real people's data.

## Owner attention, friction, writing

These are plugin rules already, so the preset adds nothing:

- Questions that stand alone, a numbered **Waiting on you** list, and sorting a real decision from a tooling gap from agent work: `workflow/communication.md` § Talking to the Owner. Gates the Owner parks go to `held` on the board, and nobody asks again: `workflow/board.md` § Rules. The coordinator hands hands-on work to peers: `workflow/orca.md` § Topology.
- The friction log, its counts, the `Friction:` line, fixing as maintenance, and changes to checked-in agent files going to the Owner first: `workflow/friction.md`.
- Plain, short English, and claims that cite the file and line: `workflow/communication.md` § Plain language, `workflow/handoffs.md` § Evidence.
