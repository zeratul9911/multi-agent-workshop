---
name: simplify
description: Clean up code after implementation, before creating a PR. Reviews diff for over-engineering, dead code, and inconsistency.
allowed-tools:
  - Read
  - Edit
  - Grep
  - Glob
  - Bash
---

# Simplify Skill

Pre-PR cleanup. Review your own work before asking for review.

## Workflow

### Phase 1: Get the diff

```bash
git diff --stat main...HEAD
git diff main...HEAD
```

### Phase 2: Check for

1. **Dead code** — unused imports, unreachable branches, commented-out code
2. **Over-engineering** — abstractions used only once, unnecessary generics, premature optimization
3. **Inconsistency** — naming that doesn't match surrounding code, different error handling style
4. **Redundancy** — duplicated logic that could use an existing util
5. **Missing cleanup** — console.logs left in, TODO comments that are now done

### Phase 3: Fix issues

Edit files directly. Keep changes minimal — only fix real issues, don't refactor for fun.

### Phase 4: Verify

```bash
bun run build
bun run test
bun run lint
```

Report: 1-3 sentence summary of what was cleaned up.
