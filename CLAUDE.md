# Multi-Agent Playground

Minimal monorepo for practicing multi-agent parallel development.

## Stack
- **Runtime**: Bun
- **Language**: TypeScript (strict)
- **Linter**: Biome
- **Packages**: Bun workspaces

## Monorepo

```
packages/
├── api/       # HTTP API (Hono)
├── ui/        # React frontend
└── shared/    # Shared utilities and types
```

## Commands

```bash
bun install          # Install deps
bun run build        # Build all packages
bun run test         # Test all packages
bun run lint         # Lint everything
bun run dev:api      # Start API dev server
bun run dev:ui       # Start UI dev server
```

## Rules

- Use `bun`, never `npm` or `yarn`
- TypeScript strict mode everywhere
- Conventional commits: `feat`, `fix`, `refactor`, `chore`
- Import shared types from `@playground/shared`, never duplicate
- Each package has its own tests — run independently

## Subagents

Use subagents (Task tool) for parallel independent work. Don't use them for quick single-file reads.

## SDLC

1. **Plan** — invoke `/plan`. Research, launch 3 parallel subagents, write spec.
2. **Build** — implement from spec. Commit regularly.
3. **Simplify** — invoke `/simplify`. Clean up before PR.
4. **Pull Request** — invoke `/pull-request`. Creates PR, offers review.
5. **Review** — invoke `/review`. 3 parallel subagents review the diff.

## Skills

| Skill | Use For |
|-------|---------|
| `/plan` | Feature planning with 3 parallel analysis subagents |
| `/review` | Code review with 3 parallel subagents |
| `/simplify` | Pre-PR cleanup (dead code, over-engineering) |
| `/pull-request` | Create PR with description, offer review |
