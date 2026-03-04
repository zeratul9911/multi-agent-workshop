# Multi-Agent Parallel Development Workshop

How to structure a codebase so multiple AI agents (and humans) can work on it simultaneously without stepping on each other.

**Source project**: Temper (this repo) — a monorepo that routinely runs 5+ agents in parallel across different packages, stacks, and concerns.

## Workshop Materials

| File | What It Covers |
|------|---------------|
| [why-it-works.md](./why-it-works.md) | The 7 architectural patterns that enable parallel agent work |
| [anatomy.md](./anatomy.md) | Annotated tour of this repo's agent infrastructure |
| [exercises.md](./exercises.md) | Hands-on exercises for the workshop |
| [playground/](./playground/) | Minimal scaffold to bootstrap a new multi-agent-ready project |

## Core Thesis

Most codebases aren't bad for AI agents — they're just **not structured for parallelism**. The same patterns that make a codebase good for a team of 10 developers make it good for a team of 10 agents:

1. **Clear boundaries** — agents can work without touching each other's files
2. **Self-contained context** — each agent loads only what it needs
3. **Safety rails** — agents can't accidentally destroy production
4. **Independent verification** — each agent can test its own work

The difference: agents benefit from these patterns *more* than humans because they can't coordinate informally ("hey, I'm working on X, don't touch it").

## Quick Start

```bash
# To try the playground scaffold:
cp -r .context/workshop/playground ~/my-workshop-project
cd ~/my-workshop-project
bun install
# Open in Conductor — each workspace gets its own agent
```
