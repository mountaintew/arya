# Orchestration — Pipeline and Handoff Contract

The `fullstack-orchestrator` runs a 7-phase pipeline. Each phase dispatches one or more specialists in series or parallel. This document is the **contract** between the orchestrator and the specialists — what each phase passes, expects back, and how failures escalate.

## The pipeline

```
                         ┌────────────────┐
                         │  user request  │
                         └────────┬───────┘
                                  ▼
            Phase 1  ───  product-owner            ──► spec.md
                                  │
                                  ▼
            Phase 2  ───  ui-ux-reviewer (advisory, optional)
                                  │
                                  ▼
            Phase 3  ───  backend-engineer  ║  frontend-engineer   (parallel if independent)
                                  │
                                  ▼
            Phase 4  ───  qa-engineer  ║  security-reviewer  ║  ui-ux-reviewer   (parallel)
                                  │
                                  ▼  ◄── if [CRITICAL] from phase 4 → loop back to phase 3 (max 2 iterations)
                                  │
            Phase 5  ───  code-reviewer  ║  overengineering-checker   (parallel)
                                  │
                                  ▼  ◄── if [CRITICAL] from phase 5 → loop back to phase 3 (max 2 iterations)
                                  │
            Phase 6  ───  tech-lead                ──► approve / changes-requested
                                  │
                                  ▼
            Phase 7  ───  devops-engineer          ──► deploy URL + smoke results
                                  │
                                  ▼
                         ┌────────────────┐
                         │  final summary │
                         └────────────────┘
```

## Handoff contract

Every dispatch follows the briefing template in `templates/handoff.md`. The orchestrator MUST include:

- **stack** — detected framework/runtime/DB (e.g. `next@14 / supabase / tailwind`).
- **repo_root** — absolute path.
- **prior_artifacts** — paths to spec, diff, prior review reports.
- **scope** — files in scope for this phase. Specialists must not touch out-of-scope files.
- **success_criteria** — verifiable conditions for the specialist's return.

## Phase-by-phase contract

### Phase 1 — product-owner

- **Inputs:** raw user request, repo overview.
- **Output:** `spec.md` written somewhere in the repo or returned inline. Contains: problem statement, scope (in/out), acceptance criteria (Given/When/Then), task breakdown (FE tasks, BE tasks).
- **Gate:** acceptance criteria are testable. If any criterion is "make it work" or "it should be nice", reject and re-run with clarifying questions.

### Phase 2 — ui-ux-reviewer (advisory, optional)

- **Inputs:** spec.md, any Figma URLs from the request.
- **Output:** layout / IA / accessibility notes BEFORE implementation. Read-only.
- **Skip when:** request is backend-only.

### Phase 3 — backend-engineer + frontend-engineer

- **Inputs:** spec.md, scope (file paths), stack.
- **Output:** list of changed files + one-paragraph rationale per file. No long internal logs.
- **Parallel rule:** dispatch both in the same orchestrator message if their scopes don't overlap. If FE depends on BE contracts (e.g. new API route), run BE first and pass the route signature to FE.

### Phase 4 — qa-engineer, security-reviewer, ui-ux-reviewer

Dispatched in parallel. Each returns findings in `review-report.md` format:

```
[CRITICAL] path/to/file.ts:42  — <description>
[WARNING]  path/to/file.ts:108 — <description>
[MINOR]    path/to/file.ts:7   — <description>
```

- **qa-engineer** writes tests, runs them, returns pass/fail + new test file paths.
- **security-reviewer** read-only OWASP-style audit on the diff.
- **ui-ux-reviewer** read-only check vs spec / design system.

### Phase 5 — code-reviewer + overengineering-checker

Dispatched in parallel. Same severity format. The overengineering-checker uses the four Karpathy principles (see its agent file) and adds an `[OVERENG]` tag plus a one-line verdict.

### Phase 6 — tech-lead

- **Inputs:** spec.md, diff, all review reports from phases 4 and 5.
- **Output:** `approve` / `changes-requested` with rationale. This is the merge gate.

### Phase 7 — devops-engineer

- **Inputs:** approved diff.
- **Output:** deploy URL + smoke-test results (curl the new endpoint, hit the new page, etc.).
- **Skip when:** the project has no deploy target wired.

## Retry / escalation policy

- A `[CRITICAL]` finding from phase 4 or 5 → orchestrator loops back to phase 3 with a focused brief: "fix these specific findings, do not touch anything else."
- Maximum 2 retry iterations per phase. After that, escalate to the user with a summary of remaining issues.
- `[WARNING]` does not block by default. Orchestrator surfaces them to the user with the final summary.
- `[MINOR]` is informational only.

## Stack detection (orchestrator responsibility)

Before phase 1, the orchestrator does a quick repo scan:

1. `cat package.json` — if it exists, read `dependencies` for framework signals (`next`, `react`, `vue`, `svelte`, `remix`, `astro`, `express`, `fastify`).
2. Check for `requirements.txt`, `pyproject.toml`, `Gemfile`, `go.mod`, `Cargo.toml` for non-JS stacks.
3. Look for `supabase/`, `prisma/`, `drizzle/`, `migrations/` for DB layer.
4. Look for `.env.example` for runtime hints.
5. If nothing conclusive, **ask the user** — do not guess.

The detected stack string is included in every specialist briefing.

## End-of-run summary (orchestrator output)

```
Feature: <one-line>
Stack: <detected>

Spec:           <path or inline summary>
Files changed:  <count> (<list>)
Tests added:    <count>
Reviews:
  qa:                 ✅ / ❌  (<n> critical / <n> warning)
  security:           ✅ / ❌  (...)
  ui-ux:              ✅ / ❌  (...)
  code:               ✅ / ❌  (...)
  overengineering:    aligned / minor bloat / significant bloat
Tech-lead:      approve / changes-requested
Deploy:         <URL or skipped>

Open warnings: <list, if any>
```
