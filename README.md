# dev-team

A reusable, documentation-first development organization for [Claude Code](https://code.claude.com), packaged as a plugin. Seven specialized agents move feature work from requirements to reviewed code through explicit human approval gates:

**Product Owner → product-manager → designer** *(UI features only)* **→ principal-engineer → task-planner → senior-developer → reviewer → Owner approval**, coordinated by an **orchestrator**.

## Install (per project)

```
/plugin marketplace add J-T-McC/dev-team     # private repo: SSH auth is used automatically
/plugin install dev-team@dev-team
```

Then scaffold the project workspace (creates `docs/`, seeds standards/stack, project CLAUDE.md section):

```
run the dev-team:bootstrap skill
```

Fill in `docs/stack/stack.md` and customize `docs/standards/*.md` — agents stop and ask rather than guess while placeholders remain. Commit the scaffolded files to your project repo. Nothing from your project ever flows back into this repo.

Keep the project `CLAUDE.md` lean — it is loaded every session, while skills and `docs/` load on demand. See [`CLAUDE.md.example`](CLAUDE.md.example) for the recommended minimal shape.

Project-level skills (`.claude/skills/`) work out of the box: every dev-team agent carries the `Skill` tool and is instructed to consult relevant domain skills (e.g. a `laravel` skill) before deciding or implementing — no plugin changes needed.

## Update (per project)

```
/plugin marketplace update dev-team    # refresh marketplace metadata from GitHub
/plugin update dev-team@dev-team       # then update the plugin itself
```

Every commit to this repo is a new version (no version pinning). Seeded files (`docs/standards/`, `docs/stack/`, `CLAUDE.md` section) are project-owned and are **not** touched by updates. After updating, run `/dev-team:sync` to pull in any seed files your project is missing and see which existing standards have new seed sections (appended only with your approval — never overwritten).

## Develop the framework locally

```
/plugin marketplace add /path/to/dev-team    # local checkout as a second marketplace
# after edits:
/plugin marketplace update dev-team
/reload-plugins
```

Validate with `claude plugin validate .`

## Layout

| Path | What | Updatable |
|---|---|---|
| `agents/`, `skills/` | The seven roles + bootstrap skill | ✅ via plugin update |
| `templates/`, `workflow/` | Document templates, pipeline/handoff/communication rules | ✅ via plugin update |
| `seeds/` | Copied into projects once by bootstrap | ❌ project-owned after copy |
| `examples/user-authentication/` | Worked example of the full pipeline | ✅ via plugin update |
