# Workshop Exercises

Hands-on exercises, ordered by complexity. Each can be done independently.

---

## Exercise 1: Hierarchical CLAUDE.md (15 min)

**Goal**: Experience how package-level context scoping works.

1. Open the playground scaffold
2. Create a root `CLAUDE.md` with 3 rules:
   - All code uses TypeScript strict mode
   - Use `bun` not `npm`
   - Commit messages use conventional format
3. Create `packages/api/CLAUDE.md` with API-specific rules:
   - Use Hono for HTTP
   - All routes must validate input with Zod
4. Create `packages/ui/CLAUDE.md` with UI-specific rules:
   - Use React + Tailwind
   - No inline styles
5. Start two agents (Conductor workspaces):
   - Agent A: "Add a GET /health endpoint to the API"
   - Agent B: "Add a Button component to the UI"
6. **Observe**: Each agent follows global + package-specific rules, but doesn't load the other package's rules.

---

## Exercise 2: Safety Hooks (15 min)

**Goal**: Set up production guards that prevent agents from doing dangerous things.

1. Create `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/guard.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Write(**/*.{ts,tsx})",
      "hooks": [{
        "type": "command",
        "command": "bunx biome format --write {file_path} 2>/dev/null || true"
      }]
    }]
  }
}
```

2. Create `.claude/hooks/guard.sh`:
```bash
#!/bin/bash
COMMAND="$CLAUDE_BASH_COMMAND"
if echo "$COMMAND" | grep -qE 'rm -rf /|drop database|force push'; then
  echo "BLOCKED: Dangerous operation detected."
  exit 2
fi
exit 0
```

3. Ask an agent to "delete all files in the project"
4. **Observe**: Hook blocks the operation, agent adapts.

---

## Exercise 3: Parallel Subagent Fan-Out (20 min)

**Goal**: Create a skill that launches parallel subagents for code review.

1. Create `.claude/skills/review/SKILL.md`:
```yaml
---
name: review
description: Launch 3 parallel reviewers
allowed-tools: [Read, Grep, Glob, Bash, Task]
---

# Review Skill

Launch 3 subagents in parallel:

1. **Correctness**: "Review git diff for logic bugs, off-by-ones, missing edge cases"
2. **Style**: "Review git diff for naming, formatting, pattern consistency"
3. **Security**: "Review git diff for injection, auth bypass, data leaks"

Launch ALL 3 using a single message with multiple Task tool calls.
Synthesize into a summary with PASS/NEEDS WORK verdict.
```

2. Make some code changes in the playground
3. Invoke `/review`
4. **Observe**: 3 subagents run simultaneously, each focused on one dimension.

---

## Exercise 4: Independent Package Work (25 min)

**Goal**: Run 2 agents modifying different packages simultaneously with zero conflicts.

1. Using the playground scaffold, start 2 Conductor workspaces on the same repo
2. Agent A task: "Add a `multiply(a, b)` function to packages/math with tests"
3. Agent B task: "Add a `capitalize(str)` function to packages/strings with tests"
4. Both agents work at the same time on different packages
5. After both finish, merge their branches
6. **Observe**: No merge conflicts because the packages are isolated.

**Bonus**: Try having both agents add a function to the SAME package. Observe what happens.

---

## Exercise 5: Skill-Driven SDLC (30 min)

**Goal**: Experience the full plan → build → review pipeline with skills.

1. Set up the playground with these skills:
   - `/plan` — creates a spec document
   - `/build` — implements from the spec
   - `/review` — reviews the implementation
2. Ask an agent: "Plan adding a cache layer to the API"
3. Agent follows `/plan` skill → produces spec with diagrams
4. Review the spec, provide feedback
5. Agent follows `/build` skill → implements the cache
6. Invoke `/review` → 3 parallel subagents review the code
7. **Observe**: Each phase has clear inputs/outputs. An agent can pick up at any phase.

---

## Exercise 6: Multi-Worktree with Conductor (20 min)

**Goal**: Run multiple agents on different branches, each with its own dev server.

1. Create 3 Conductor workspaces from the same repo
2. Each workspace gets:
   - Its own git worktree (isolated branch)
   - Its own port via `$CONDUCTOR_PORT`
   - Its own running dev server
3. Tasks:
   - Workspace 1: "Add dark mode toggle"
   - Workspace 2: "Add search functionality"
   - Workspace 3: "Fix the layout bug on mobile"
4. All 3 run simultaneously
5. **Observe**: `conductor.json` scripts handle port isolation automatically.

---

## Discussion Questions

After exercises, discuss:

1. **When does parallelism help vs hurt?** (independent tasks vs tightly coupled changes)
2. **What's the minimum setup for multi-agent work?** (just CLAUDE.md + package boundaries? Or do you need the full skill system?)
3. **How do you handle the coordination points?** (shared schemas, database migrations, lock files)
4. **Cost tradeoffs**: Opus for everything vs model-tiered agents — when does it matter?
5. **How do you debug when 3 agents are running simultaneously?** (observability, git blame, structured outputs)
