# Multi-Agent Parallel Development Workshop

How to structure a codebase so multiple AI agents (and humans) can work on it simultaneously without stepping on each other.

## Workshop Materials

| File | What It Covers |
|------|---------------|
| [why-it-works.md](./why-it-works.md) | The 7 architectural patterns that enable parallel agent work |
| [anatomy.md](./anatomy.md) | Annotated tour of the agent infrastructure |
| [exercises.md](./exercises.md) | Hands-on exercises for the workshop |
| [run-sheet.md](./run-sheet.md) | Step-by-step presenter script with copy-paste prompts |

## Core Thesis

Most codebases aren't bad for AI agents — they're just **not structured for parallelism**. The same patterns that make a codebase good for a team of 10 developers make it good for a team of 10 agents:

1. **Clear boundaries** — agents can work without touching each other's files
2. **Self-contained context** — each agent loads only what it needs
3. **Safety rails** — agents can't accidentally destroy production
4. **Independent verification** — each agent can test its own work

The difference: agents benefit from these patterns *more* than humans because they can't coordinate informally ("hey, I'm working on X, don't touch it").

## Quick Start

```bash
git clone https://github.com/zeratul9911/multi-agent-workshop.git
cd multi-agent-workshop
bun install
bun run build
bun run dev:api   # starts on port 3000
```

Open in Conductor — each workspace gets its own agent and port.

## Structure

```
CLAUDE.md                        ← root agent instructions
conductor.json                   ← multi-worktree port isolation
.claude/
├── settings.json                ← format-on-write + guard hooks
├── hooks/guard.sh               ← blocks dangerous ops
├── agents/general-agent-opus.md ← default subagent
└── skills/
    ├── plan/                    ← 3 parallel subagents for planning
    ├── review/                  ← 3 parallel subagents for review
    ├── simplify/                ← pre-PR cleanup
    └── pull-request/            ← create PR + offer review
packages/
├── api/                         ← Hono API (own CLAUDE.md)
├── ui/                          ← React frontend (own CLAUDE.md)
└── shared/                      ← Shared Zod schemas
```
