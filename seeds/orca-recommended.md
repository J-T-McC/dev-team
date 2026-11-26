# Recommended Orca setup

Written into the project's dev-team section by `/dev-team:orca` (dev-team `commands/orca.md`): the Runtime line goes under Rules, replacing the project's; the Team setup section goes at the end. Why each value: dev-team `workflow/orca-recommended.md`.

## Runtime line

- **Runtime: Orca.** Roles run as top-level Orca peers per the dev-team `workflow/orca.md`; never spawn subagents. Team model: claude-opus-5-5. Fallback model: none. Advisor: claude-fable-5-2. Peer size limit: 400k. Worktree cards: off.

## Team setup

The dev-team recommended Orca setup; why each rule is here: dev-team `workflow/orca-recommended.md`. Every value is the project's to change. `⟨…⟩` marks a value only the Owner can fill: until it is filled, ask before relying on it.

- **Models.** Never move a peer to a smaller model to save usage; cut usage another way: fewer peers awake, narrower reads, targeted tests.
- **Homes.** `dt-product`, `dt-designer`, `dt-architect`, `dt-reviewer`, `dt-reviewer-2`, `dt-dev-1` to `dt-dev-4` (size large; medium: `dt-reviewer` and `dt-dev-1`, `dt-dev-2` only; small: `dt-reviewer` and `dt-dev-1` only), each in its own worktree named after the home. The first dispatch creates it (`--worktree new-top-level --name <home>`); later dispatches reuse it. This replaces worktrees per feature and per stream. A new home needs the Owner's yes.
- **Git.** Document roles never branch: they read the code at the default branch's latest commit and write only in the workspace. Each developer starts each task on a new branch from the default branch, owns its branches, and never touches another peer's. Reviews are read-only: fetch and diff, and run tests or UI checks on the reviewed commit, detached, in the reviewer's own worktree. Never check out a developer's branch. Peers never merge a PR.
- **PRs.** A draft while building: push each finished commit and keep the PR body current. Ready only after our reviewer approves, at least a minute after the last push; once ready, batch pushes. Each developer keeps its own PRs green and free of conflicts, and checks them between tasks. One PR per ticket to start; a split or a stack gets a one-line reason in the plan.
- **Tests.** Mid-work, run only the tests for what changed, by explicit file list, and check the list is not empty first. Related suites run once, at the end. The full suite, `⟨command⟩`, runs only when the coordinator's spec says so: the end-of-work run and the reviewer's own run. A local pass means zero failures. A CI job that times out is run locally, not re-run.
- **Outside services.** Automated tests never call paid services. Approved services: `⟨list⟩`. Spending cap: `⟨amount, per task or per month⟩`. Test accounts and numbers: `⟨list⟩`. Any other new service, and any install beyond what the lockfiles pin, needs the Owner's yes. Production is queried only when an action depends on the result.
- **Workspace.** Not committed with the code: its own repository, pushed to `⟨remote⟩` by the plugin's Stop hook, so other machines can pull the specs.
