# Why This Codebase Works for Multi-Agent Parallel Development

7 patterns, extracted from production use.

---

## 1. Hierarchical Context Loading

**Problem**: A single CLAUDE.md with everything creates noise. Agents working on the frontend don't need database migration rules.

**Solution**: Cascading CLAUDE.md files at each package level.

```
CLAUDE.md                          ← global rules (always loaded)
├── apps/api/CLAUDE.md             ← tRPC patterns, error classes
├── apps/frontend/CLAUDE.md        ← React patterns, state management
└── packages/database/CLAUDE.md    ← migration rules, codegen mandate
```

Each agent gets: **global rules + package-specific rules**. No more, no less.

**Key design choices**:
- Root CLAUDE.md: monorepo map, SDLC workflow, hard rules, skills table
- Package CLAUDE.md: patterns specific to that package, "always do X before Y" rules
- AGENTS.md symlinked to CLAUDE.md for cross-tool compat (Codex, etc.)

---

## 2. Skills as Executable Playbooks

**Problem**: Agents lose context about how to do domain-specific tasks. Every session starts from scratch.

**Solution**: 32 skills in `.claude/skills/`, each a self-contained SKILL.md with YAML frontmatter.

```yaml
# .claude/skills/pr-review/SKILL.md
---
name: pr-review
description: 5 parallel opus subagents as Staff Engineers
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, Task]
---
# Phase 1: Run CI locally
# Phase 2: Analyze scope
# Phase 3: Launch 5 parallel subagents
# Phase 4: Synthesize
```

Skills are organized in 3 tiers:
- **SDLC** (workflow): plan → build → simplify → PR → review → babysit
- **Domain** (expertise): database, testing, frontend design
- **Operations** (runbooks): sandbox restart, workflow debugging, deploy verification

**Why this enables parallelism**: An agent loads one skill and has everything it needs. No cross-referencing, no asking "how do we do X here?"

---

## 3. Subagent Fan-Out Patterns

**Problem**: Complex tasks (planning, reviewing) need deep analysis across multiple dimensions, but a single agent bottlenecks.

**Solution**: Explicit fan-out patterns where one agent spawns N parallel subagents, each with a focused prompt.

### Planning Fan-Out (3 parallel)
```
Main Agent
├── Subagent 1: Coding Practices & Tech Fit
├── Subagent 2: Security Analysis
└── Subagent 3: Production Quality Assessment
→ Main agent synthesizes all 3 into spec
```

### PR Review Fan-Out (5 parallel)
```
Main Agent
├── Subagent 1: Simplicity (Staff Engineer persona)
├── Subagent 2: Patterns & Best Practices
├── Subagent 3: Security
├── Subagent 4: Production Readiness
└── Subagent 5: Test Quality
→ Main agent synthesizes into review summary
```

### Codebase Audit Fan-Out (3 parallel)
```
Main Agent
├── Subagent 1: Pattern Inventory (exhaustive search)
├── Subagent 2: Consolidation & Fragmentation
└── Subagent 3: Documentation Coverage
→ Main agent produces audit report
```

**Key**: Each subagent is role-prompted with a persona and focus area. They run in parallel (single message with multiple Task tool calls).

---

## 4. Package Isolation via Monorepo Boundaries

**Problem**: Two agents editing the same files = merge conflicts + broken code.

**Solution**: Monorepo where each package is self-contained with its own build, test, and type config.

```
packages/
├── schemas/          ← shared types (coordination point)
├── database/         ← migrations + Kysely types
├── infrastructure/   ← K8s provisioning
├── code-sandbox/     ← sandbox runtime (Bun + Hono)
├── ingress-service/  ← request routing
├── sdk/
│   ├── edi/          ← EDI parsing
│   ├── events/       ← event system
│   ├── logger/       ← logging
│   └── sftp/         ← SFTP client
└── shared/           ← utilities (coordination point)
```

Each package has:
- Own `package.json` with `build`, `test`, `typecheck` scripts
- Own `vitest.config.ts` for independent test runs
- Own `tsconfig.json` (no project references between packages)
- Barrel export via `src/index.ts`

**Conflict-prone areas** (identified and documented):
- `packages/schemas/` — shared types, imported everywhere
- `packages/database/migrations/` — sequential timestamps, CI-guarded
- Root `bun.lock` — dependency changes conflict

---

## 5. Per-Developer Isolated Environments

**Problem**: Two agents deploying to the same environment = chaos.

**Solution**: Each developer (and agent) gets a full isolated environment via separate infrastructure stacks.

Agent A deploys to their stack while Agent B deploys to theirs. Zero infrastructure conflicts.

Branch naming convention drives auto-env-pulling:
```bash
# Branch: rony/feature-x → auto-pulls rony stack env vars
"setup": "bun pull-env $(git branch --show-current | cut -d'/' -f1)"
```

**Conductor integration**: Dynamic port assignment via `$CONDUCTOR_PORT` enables multiple worktrees running dev servers simultaneously.

---

## 6. Safety Hooks and Guards

**Problem**: Agents can accidentally destroy production, create formatting drift, or bypass safety checks.

**Solution**: Three layers of safety.

### Layer 1: Pre-execution hooks
```bash
# .claude/hooks/prod-guard.sh (PreToolUse on all Bash commands)
# Blocks: pull-env prod, migrate prod, STACK=prod deploy
```

### Layer 2: Post-execution hooks
```json
// .claude/settings.json — auto-format any written TS/TSX file
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write(**/*.{ts,tsx})",
      "hooks": [{ "command": "bunx biome format --write {file_path}" }]
    }]
  }
}
```

### Layer 3: CI quality gates
- Migration timestamp ordering (prevents conflict in sequential migrations)
- Semantic PR titles (enforced format)
- Lint ratcheting (only new violations fail, existing grandfathered)
- Parallel CI jobs: lint, typecheck, test (all independent after install)

---

## 7. Model-Tiered Agent Hierarchy

**Problem**: Not all tasks need the most expensive model. Using Opus for everything wastes tokens.

**Solution**: Agent definitions with explicit model and tool constraints.

```
.claude/agents/
├── general-agent-opus.md       ← complex reasoning (model: opus)
├── workflow-code-review.md     ← focused review (model: opus, tools: Read,Grep,Glob,Bash)
└── workflow-prod-verify.md     ← procedural checks (model: sonnet, tools: Bash,Read)
```

**Principle**: Opus for reasoning, Sonnet for procedural work. Tool restrictions prevent agents from doing things they shouldn't.

---

## Summary: The Parallel Work Equation

```
Parallel Safety = Isolation × Context × Guards

Isolation:  package boundaries + per-stack infra + independent tests
Context:    hierarchical CLAUDE.md + self-contained skills + role-prompted subagents
Guards:     prod hooks + auto-formatting + CI gates + migration ordering
```

When all three are in place, you can run N agents in parallel with confidence proportional to N, not anxiety proportional to N.
