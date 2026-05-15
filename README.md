# arya

A team of 11 Claude Code subagents that runs a 7-phase pipeline for fullstack feature work — PM → design → implement → verify → code-review → tech-lead → ship. Stack-agnostic.

## Install

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and `~/.claude/agents/` writable.

```sh
git clone <this-repo> arya
cd arya
./install.sh
```

`install.sh` symlinks `agents/*.md` into `~/.claude/agents/`. It's idempotent — re-run after editing. To uninstall:

```sh
./install.sh --uninstall
```

## Usage

In any Claude Code session:

```
Use the fullstack-orchestrator to add a /healthz endpoint and a status page.
```

The orchestrator detects your stack (Next, Vite, Remix, Express, Supabase, Prisma, …), then dispatches specialists in order, running independent phases in parallel.

You can also call any specialist directly:

```
Use the security-reviewer on my current diff.
Use the overengineering-checker on this PR.
```

## The team

| Agent | Role | Tools |
| --- | --- | --- |
| `fullstack-orchestrator` | Conductor — dispatches the team, aggregates results | Agent, Read, Bash, Grep, Glob |
| `product-owner` | Turns requests into testable specs | Read, Grep, Glob, WebFetch |
| `frontend-engineer` | Implements UI / client logic | Read, Edit, Write, Bash, Grep, Glob |
| `backend-engineer` | Implements API, server, DB, migrations | Read, Edit, Write, Bash, Grep, Glob, Supabase MCP |
| `ui-ux-reviewer` | Layout, a11y, design-system fit (read-only) | Read, Grep, Glob, Figma MCP |
| `qa-engineer` | Tests against acceptance criteria | Read, Edit, Write, Bash, Grep, Glob |
| `security-reviewer` | OWASP-style audit (read-only) | Read, Grep, Glob, Bash |
| `code-reviewer` | Line-by-line correctness (read-only) | Read, Grep, Glob, Bash |
| `overengineering-checker` | Karpathy-principle simplicity audit (read-only) | Read, Grep, Glob, Bash |
| `tech-lead` | Final merge gate, architecture review (read-only) | Read, Grep, Glob, Bash |
| `devops-engineer` | Deploy + smoke verify | Read, Bash, Vercel MCP, Supabase MCP |

Reviewers are tool-locked to read-only — they can audit but never edit.

## Layout

```
arya/
├── README.md          ← you are here
├── LEARN.md           ← Claude Code subagents 101 + pros/cons + when to orchestrate
├── ORCHESTRATION.md   ← pipeline, handoff contract, retry policy
├── agents/            ← the 11 specialists
├── templates/         ← spec.md, review-report.md, handoff.md
└── install.sh
```

## Docs

- **[LEARN.md](./LEARN.md)** — how Claude Code subagents work, when to orchestrate, pros/cons. Read this if you're new to subagents.
- **[ORCHESTRATION.md](./ORCHESTRATION.md)** — the 7-phase pipeline, handoff contract, retry/escalation policy. Read this to understand what the orchestrator actually does.

## Credits

`overengineering-checker` is built around the four Karpathy principles from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills). Full attribution in `agents/overengineering-checker.md`.
