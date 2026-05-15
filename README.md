# arya

An 11-agent team for fullstack feature work. Runs a 7-phase pipeline: PM, design, implement, verify, code review, tech lead, ship. Stack-agnostic.

## Install

```sh
git clone https://github.com/mountaintew/arya.git
cd arya
./install.sh
```

`install.sh` symlinks `agents/*.md` into `~/.claude/agents/`. Idempotent. Re-run after editing source files. To remove:

```sh
./install.sh --uninstall
```

## Usage

Invoke the orchestrator for any multi-phase work:

```
Use the fullstack-orchestrator to add a /healthz endpoint and a status page.
```

The orchestrator detects your stack (Next, Vite, Remix, Express, Supabase, Prisma, etc.) and dispatches specialists in order, running independent phases in parallel.

Specialists can also be invoked directly:

```
Use the security-reviewer on my current diff.
Use the overengineering-checker on this PR.
```

## Pipeline

```
1. intake          product-owner
2. design          ui-ux-reviewer (advisory, optional)
3. implement       backend-engineer + frontend-engineer  (parallel if independent)
4. verify          qa-engineer + security-reviewer + ui-ux-reviewer  (parallel)
5. code review     code-reviewer + overengineering-checker  (parallel)
6. final review    tech-lead  (merge gate)
7. ship            devops-engineer
```

See [ORCHESTRATION.md](./ORCHESTRATION.md) for the handoff contract and retry policy.

## The team

| Agent | Role | Tools |
| --- | --- | --- |
| `fullstack-orchestrator` | Conductor. Dispatches the team, aggregates results. | Agent, Read, Bash, Grep, Glob |
| `product-owner` | Turns requests into testable specs. | Read, Grep, Glob, WebFetch |
| `frontend-engineer` | Implements UI and client logic. | Read, Edit, Write, Bash, Grep, Glob |
| `backend-engineer` | Implements API, server, DB, migrations. | Read, Edit, Write, Bash, Grep, Glob, Supabase MCP |
| `ui-ux-reviewer` | Layout, a11y, design-system fit. Read-only. | Read, Grep, Glob, Figma MCP |
| `qa-engineer` | Writes and runs tests against acceptance criteria. | Read, Edit, Write, Bash, Grep, Glob |
| `security-reviewer` | OWASP-style audit. Read-only. | Read, Grep, Glob, Bash |
| `code-reviewer` | Line-by-line correctness. Read-only. | Read, Grep, Glob, Bash |
| `overengineering-checker` | Karpathy-principle simplicity audit. Read-only. | Read, Grep, Glob, Bash |
| `tech-lead` | Final merge gate, architecture review. Read-only. | Read, Grep, Glob, Bash |
| `devops-engineer` | Deploy and smoke verify. | Read, Bash, Vercel MCP, Supabase MCP |

Reviewers are tool-locked to read-only. They audit, they never edit.

## Customizing

- Edit `agents/*.md` in place. Symlinks resolve to the current source, no reinstall needed.
- Add a specialist: drop a new `<name>.md` in `agents/` and re-run `./install.sh`.
- Tighten a role's permissions: shrink its `tools:` allowlist in the frontmatter.
- Change the pipeline: edit `agents/fullstack-orchestrator.md` and `ORCHESTRATION.md` together so they stay in sync.

## Layout

```
arya/
├── README.md
├── LEARN.md           subagents 101, pros/cons, when to orchestrate
├── ORCHESTRATION.md   pipeline, handoff contract, retry policy
├── agents/            the 11 specialists
├── templates/         spec.md, review-report.md, handoff.md
└── install.sh
```

## Credits

`overengineering-checker` is built around the four principles from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills). Full attribution in `agents/overengineering-checker.md`.
