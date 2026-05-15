# LEARN — Claude Code subagents 101

If you're new to subagents, read this before using arya. It explains the mental model, the tradeoffs, and when orchestration is the right tool — and when it isn't.

## How Claude Code subagents work

1. **A subagent is a markdown file with frontmatter.** Lives in `~/.claude/agents/<name>.md` (user-scope) or `<project>/.claude/agents/<name>.md` (project-scope). Frontmatter declares `name`, `description`, optional `tools` allowlist. The body is the system prompt.
2. **Subagents have their own context window.** When dispatched via the Agent tool, they start cold — they do NOT see the parent conversation. Brief them with everything they need: file paths, prior decisions, what's been tried.
3. **They return ONE message back.** That summary is all the parent sees. Long internal logs stay inside the subagent. This is why orchestration scales: context isolation.
4. **`description` is the routing key.** Claude matches user intent against descriptions to auto-suggest agents. Vague description = never gets picked. Write it like a job posting: when to use, when NOT to use.
5. **`tools:` is an allowlist, not a denylist.** Omit it → inherits all parent tools. Specify it → only those tools are available. Use this for least-privilege (reviewers read-only).
6. **Subagents can spawn subagents** but each level loses observability. Keep nesting shallow (max 2 in practice).
7. **Parallelism happens at the Agent tool call level** — multiple Agent calls in a single assistant message run concurrently.

## Pros and cons

**Pros**

- **Context preservation** — specialists keep noisy tool output out of the main session.
- **Specialization** — tight prompts → higher quality output per lane.
- **Parallelism** — independent reviews (Security + UI/UX + QA) run concurrently.
- **Least privilege** — reviewers can be tool-locked to read-only.
- **Repeatability** — a captured orchestrator turns "build a feature" into a known pipeline.

**Cons / gotchas**

- **Cold-start cost** — each dispatch re-reads files the parent already had cached. Tokens add up.
- **Lossy handoffs** — subagents return one message; nuance gets compressed.
- **Debugging is harder** — you see the summary, not the trace. Add `report verbatim` for critical steps.
- **Over-engineering trap** — for a typo fix, orchestration is pure overhead. Reserve it for multi-phase work.
- **Prompt drift** — specialists can recommend "best practices" that don't fit the codebase. Always brief with concrete paths and constraints.

## When to orchestrate vs not

| Use orchestration | Skip it |
| --- | --- |
| New feature spanning FE + BE | Single typo |
| Refactor touching 5+ files | One-line config tweak |
| Pre-release verification (security + QA + UX in parallel) | Quick code question |
| Anything you want a record of | Throwaway exploration |

## Things to consider before adopting

- **Handoff contract.** What artifacts pass between phases? See `ORCHESTRATION.md`.
- **Tool scopes per role.** Reviewers read-only; engineers Edit/Write/Bash; DevOps needs deploy MCPs.
- **Output format.** Reviewers use `[CRITICAL] path:line` so the orchestrator can parse and decide.
- **Context budget.** Long parent transcripts + many dispatches = compaction. Keep specialist prompts focused.
- **Retry policy.** What if QA fails? The orchestrator loops back to the engineer with the failing report (max 2 iterations).

## Customizing arya

- Edit any `agents/*.md` in place — symlinks resolve to the current source, no re-install needed.
- Add a new specialist: drop a new `<name>.md` in `agents/`, re-run `./install.sh`.
- Change the orchestrator's pipeline: edit `agents/fullstack-orchestrator.md` and `ORCHESTRATION.md` together so they stay in sync.
- Lock a reviewer down further: tighten its `tools:` allowlist in the frontmatter.
