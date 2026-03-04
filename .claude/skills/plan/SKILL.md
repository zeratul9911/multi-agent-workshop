---
name: plan
description: Plan a feature with parallel subagent analysis before writing any code.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
  - Write
---

# Feature Planning Skill

**MANDATORY**: Research and plan before writing any code.

## Workflow

### Phase 1: Research

1. Explore the codebase — find existing patterns
2. Read package CLAUDE.md files for conventions
3. Identify which packages will be touched

### Phase 2: Launch 3 parallel subagents

**Launch ALL 3 in a single message with multiple Task tool calls.**

#### Subagent 1: Coding Practices & Tech Fit
```
Analyze how [feature] fits with existing patterns in this codebase:
- Does it follow existing conventions? (check CLAUDE.md files)
- Are we using the right libraries?
- What existing code can we reference?
Search the codebase thoroughly.
```

#### Subagent 2: Security Analysis
```
Think through security implications for [feature]:
- Input validation needs
- Auth/authz concerns
- Data exposure risks
- Injection vectors
```

#### Subagent 3: Production Quality
```
Evaluate production readiness for [feature]:
- Error handling strategy
- Logging needs
- Performance implications
- Testing strategy
```

### Phase 3: Write spec

Create a spec document in `.context/specs/`:

```markdown
# Feature: [Name]

## Problem
What we're solving and why.

## Proposed Solution
High-level approach with diagram.

## Implementation Plan
1. Step 1
2. Step 2

## Files to Modify
- `path/to/file.ts` — what changes

## Edge Cases
- What if X fails?

## Open Questions
- Question 1?
```

### Phase 4: Get user approval before building

Present the spec. Ask clarifying questions. Don't code until approved.
