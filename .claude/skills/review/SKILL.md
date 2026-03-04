---
name: review
description: Launch 3 parallel subagents to review code changes for correctness, style, and security.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

# Code Review Skill

Review code changes using 3 parallel subagents, each focused on one dimension.

## Workflow

### Phase 1: Get the diff

```bash
git diff --stat HEAD~1
git diff HEAD~1
```

### Phase 2: Launch 3 parallel subagents

**CRITICAL: Launch ALL 3 in a single message with multiple Task tool calls.**

#### Subagent 1: Correctness
```
Review the git diff (run `git diff HEAD~1`) for correctness issues:
1. Logic bugs, off-by-one errors
2. Missing edge cases (null, empty, boundary values)
3. Async/await mistakes (floating promises, race conditions)
4. Type safety issues
Provide specific file:line references.
```

#### Subagent 2: Style & Patterns
```
Review the git diff (run `git diff HEAD~1`) for style consistency:
1. Naming conventions match the rest of the codebase
2. Code follows existing patterns (check surrounding files)
3. No unnecessary abstractions or over-engineering
4. Dead code or unused imports
Provide specific file:line references.
```

#### Subagent 3: Security
```
Review the git diff (run `git diff HEAD~1`) for security issues:
1. Input validation on all external inputs
2. No secrets in code or logs
3. Injection risks (SQL, command, path traversal)
4. Auth/authz gaps
Provide specific file:line references.
```

### Phase 3: Synthesize

Combine findings into:

```
## Review: PASS / NEEDS WORK

### Correctness: [findings]
### Style: [findings]
### Security: [findings]

### Issues (if any):
- BLOCKER: [issue] at file:line
- Should fix: [issue] at file:line
```

## Anti-Patterns

- DON'T skip subagents for "small" changes (bugs hide in small diffs)
- DON'T use haiku/sonnet for review subagents (need deep reasoning)
- DO launch all 3 in parallel (faster)
- DO provide specific file:line references
