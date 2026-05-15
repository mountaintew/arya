# Handoff briefing — orchestrator → <specialist>

> Subagents start cold. This briefing is the ONLY context the specialist has. Be specific.

```
stack:               <e.g. next@14 / supabase / tailwind / shadcn>
repo_root:           <absolute path>
phase:               <1..7>
specialist:          <agent name>
prior_artifacts:
  - spec:            <path>
  - diff:            <path or "git diff HEAD~1">
  - review_reports:  <paths, if any>
scope:               <files / directories specialist may touch or review>
success_criteria:
  - <verifiable condition>
  - <verifiable condition>
retry_history:       <n previous fix iterations, default 0>
notes:               <anything else the specialist needs, e.g. "FE must not regenerate types yet, BE migration still pending">
```

## Inline expansion (if anything is short enough to inline)

<paste spec excerpt, contract shape, etc.>
