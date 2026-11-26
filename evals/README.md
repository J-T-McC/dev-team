# Setup evals

Paid evals for dev-team's setup flow, run with [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals.md). Each run is a full Claude session on your own plan, so the suite runs only at the points below, and only the cases that cover what changed. `tests/evals.sh` checks the suite for free on every PR: its case files and graders use only documented fields, its fixtures build what its cases grade, and this README maps every case.

The cases describe the **v1 setup flow**: one question about whose project it is, suggested answers from `bin/setup-detect`, and a `dev-team/` workspace. Until v1 lands, most of them fail on today's setup, which is the baseline.

## When to run

| When | What | How often |
|---|---|---|
| A new machine, or a Claude Code update | `env-git` (about $0.20) | once, before any other case |
| The baseline | every case, on `main`, 1 run | once, when the suite lands, and again when the suite changes |
| A PR that changes what setup does | the cases [mapped below](#which-cases-to-run) to the files it changes | once, at the end, before merge |
| Choosing a model to recommend | a few cases on 2–3 models | once |

Never in CI. Never for a change to docs, to scripts only (their free tests cover them), or to wording no grader reads. Never mid-development to see whether something got better. When a case fails, read the transcript of the run that failed (`--keep-temp`) before running anything again.

**Every run is agreed with the maintainer first: the exact cases, the number of runs, and a cost cap.**

## How to run

```bash
CLAUDE_CODE_SHELL_PREFIX="$PWD/tests/eval-shell-prefix" \
claude plugin eval . --scaffold --ablation none --allow-tools Bash Write Edit --no-publish \
  --max-cost-usd <cap> --case '<name>' [--runs <n>] [--keep-temp]
```

- **`CLAUDE_CODE_SHELL_PREFIX`**: for git on macOS ([below](#what-a-case-can-check)). It does nothing elsewhere.
- **`--scaffold`** builds each case's test repository from its `scaffold.sh`.
- **`--ablation none`**: without it, every case also runs without the plugin, at twice the cost, as a comparison that means nothing for setup.
- **`--allow-tools Bash Write Edit`**: setup runs scripts and writes files.
- **`--no-publish`** keeps the report on your machine.
- **`--case`** takes one name or glob. A second `--case` replaces the first, so run separate cases one command at a time.
- **`--keep-temp`** keeps each run's folder and transcript, to read why a case failed.
- **`--trust-plugin`** skips the first-run trust question, for unattended runs only.

## What a case can check

- **No answers mid-run.** The question tool doesn't exist in eval runs, so setup asks in plain text and ends its turn. Stage-1 cases give no answers and grade the questions in the final message, plus that nothing was written. Stage-2 cases give every answer in the prompt and grade the files setup wrote.
- **git on macOS.** `/usr/bin/git` and `/usr/bin/python3` are xcrun stubs, and they fail in the run's sandbox: they can't write their cache under `/var/folders`, or look the tool up through `xcodebuild`. Setting `PATH` before the run doesn't help. Each Bash command starts from a snapshot of a login zsh when one exists, and macOS's `path_helper` puts `/usr/bin` first in that snapshot. The fix has three layers:
  - every scaffold writes `git` and `python3` wrappers to the run's home and puts that folder first in the startup files the snapshot is taken from;
  - `tests/eval-shell-prefix` puts the wrappers first for commands that run without a snapshot;
  - the prefix also points the stubs at the Command Line Tools.

  The prefix lives outside `evals/`, because a run can't read `evals/`. Run `env-git` first on a new machine: its output shows which layer reached the shell.
- **No new repository.** The sandbox blocks writes to a new repository's `.git/hooks` and `.git/config`, so `git init` fails in a run. A guest workspace's own history can't be created there, so `guest-all-answers` grades the attempt and what the user is told. Users with Claude Code's sandbox turned on will hit the same block.
- **"Writes nothing"** means no Write or Edit call and no new `.md` file. Setup also writes with `cp` and `sed`, which only the second check catches. A file it changes in place with Bash isn't caught.
- **No environment per case.** A case can't set `PATH` or variables other than `EVAL_*`, so running inside Orca, the plan sizes and a missing Python are tested by `tests/setup-detect.sh` instead.

## Cases

| Case | Fixture | Checks |
|---|---|---|
| `env-git` | one commit | the run's shell has a working git; its output shows which macOS fix reached the shell. Not a setup case |
| `new-no-answers` | empty | runs `setup-detect`; asks whose project (3 answers), autonomy and commit style, each with a meaning and a recommended answer; plain words; writes nothing |
| `existing-no-answers` | ts-shop | recommends the project's own commit style, quoting a real `ENG-` commit; writes nothing |
| `stack-missing-facts` | empty | "let the team pick" without saying where it runs: asks where it runs and is hosted before picking; no ADR, writes nothing |
| `new-all-answers` | empty | writes `dev-team/status.md` (not `docs/`); a committed `dev-team` Workspace line; ends with a next step, no TBD homework |
| `existing-all-answers` | ts-shop | the coding standard names Biome and cites `package.json` or `biome.json`, not Prettier or Oxlint; the mismatch is in the backlog; the project's commit style and its own `CLAUDE.md` line are kept |
| `guest-all-answers` | ts-shop | their `CLAUDE.md` and `.gitignore` untouched; the section in `CLAUDE.local.md` with a `.dev-team`, not-committed Workspace line; `.dev-team` in `.git/info/exclude`; tries `git init` for its own history and tells the user if that failed |
| `rerun` | set-up | says it's already set up, shows the settings, offers changes; writes nothing |
| `checkins-plain-words` | set-up | "can you set up check-ins" reaches the check-ins setup and explains that it needs Orca; writes nothing |

Fixtures are each case's `scaffold.sh`. Cases that share one keep identical copies, and `tests/evals.sh` fails if they drift:

- **empty**: a new repository with one commit.
- **ts-shop**: a TypeScript storefront. Biome runs from its scripts and CI, Prettier is configured but never run, its README mentions Oxlint, and it has 20 conventional commits with `ENG-` IDs, its own `CLAUDE.md` and a `.gitignore`.
- **set-up**: a project dev-team already set up, outside Orca.

## Which cases to run

| A change to | Run |
|---|---|
| `skills/bootstrap/`, `workflow/adoption.md`, `workflow/workspace.md` | every case tagged `setup` |
| `bin/setup-detect` | none (`tests/setup-detect.sh`), unless it changes what setup shows: then the `stage-1` cases |
| `seeds/CLAUDE.project.md`, `seeds/standards/`, `seeds/stack.md` | the `stage-2` cases |
| the commit format in `seeds/standards/coding.md` | `new-no-answers`, `existing-no-answers`, `existing-all-answers` |
| harvest or stack-pick rules in `skills/principal-engineer/`, `workflow/stack-pick.md` | `existing-all-answers`, `stack-missing-facts` |
| `skills/orchestrator/` routing, `commands/` | `checkins-plain-words` |
| anything else | none |

## Cost

Measured on Opus 5.5, at API prices (on a subscription, runs count against your usage limits instead of costing money):

- a run that only asks: $0.13–0.25, 4–8 turns, under a minute;
- a run that writes the workspace: $0.22–0.61, 6–21 turns, up to about two minutes;
- the `llm` judges: under $0.01 a run.

All 9 cases once: about $2.40. Three runs each: about $7.

## Baseline

**Run 2** (2026-11-26, `main` at `4a2b02b` plus this suite's fixes, Opus 5.5, 1 run per case, $2.35): today's setup, before v1. `guest-all-answers` comes from a re-run after its history graders changed.

| Case | Score | Turns | Cost | What today's setup does |
|---|---|---|---|---|
| `env-git` | 1.00 | 2 | $0.13 | git and python3 work in the run |
| `new-no-answers` | 0.50 | 4 | $0.14 | asks about folders, root and naming; uses jargon; no `setup-detect` |
| `existing-no-answers` | 0.67 | 6 | $0.18 | quotes a real commit but offers no commit-style choice |
| `stack-missing-facts` | 0.80 | 5 | $0.16 | asks about folders and extras, not where the app runs |
| `new-all-answers` | 0.00 | 6 | $0.22 | writes `docs/`; leaves placeholders as homework |
| `existing-all-answers` | 0.20 | 21 | $0.61 | writes `docs/`, so the `dev-team/` checks fail; keeps the commit style |
| `guest-all-answers` | 1.00 | 10 | $0.36 | does everything asked; reports that the history couldn't be created |
| `rerun` | 0.50 | 8 | $0.25 | runs a sync, copying files, instead of offering changes |
| `checkins-plain-words` | 1.00 | 5 | $0.13 | reaches check-ins and explains Orca |

**Run 1** (2026-11-26, $1.81) wasn't valid. git failed in every run, one case didn't load (its `llm` graders used `target`, which only `regex` accepts; `llm` takes `focus`), and Bash writes passed "writes nothing". Three probe runs of `env-git` ($0.42) found the git fix.
