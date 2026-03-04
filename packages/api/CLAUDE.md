# API Package

HTTP API using Hono framework.

## Patterns
- All routes validate input with Zod
- Return typed responses
- Use `@playground/shared` for shared types
- Error responses follow `{ error: string, code: string }` shape
