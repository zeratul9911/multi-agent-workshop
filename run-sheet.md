# Workshop Run Sheet

Multi-agent parallel development with Claude Code + Conductor.
Copy-paste prompts marked with `>`. Timing is approximate.

---

## Part 1: Why This Matters (10 min, slides/talk)

**Key points to cover:**

- Single agent, single file, sequential = slow. N agents, N packages, parallel = fast.
- Same patterns that make a codebase good for 10 devs make it good for 10 agents.
- The difference: agents can't coordinate informally ("hey don't touch that file").
- So we need: **isolation** (package boundaries), **context** (scoped instructions), **guards** (safety hooks).

**The equation to put on a slide:**

```
Parallel Safety = Isolation × Context × Guards
```

**The 7 patterns (one bullet each):**

1. Hierarchical CLAUDE.md — agents load only what they need
2. Skills as playbooks — self-contained instructions for any task
3. Subagent fan-out — one agent spawns N parallel reviewers
4. Package isolation — independent build/test/typecheck per package
5. Per-developer infra stacks — agents deploy without conflicts
6. Safety hooks — auto-format, prod guards, dangerous op blocking
7. Model-tiered agents — Opus for reasoning, Sonnet for procedural

---

## Part 2: Live Setup (10 min, screenshare)

### 2.1 Create the playground

```bash
cp -r .context/workshop/playground ~/workshop-demo
cd ~/workshop-demo
git init && git add -A && git commit -m "chore: initial scaffold"
bun install
```

### 2.2 Walk through the structure (open each file, explain)

**Root CLAUDE.md** — "Every agent in the project sees this. Global rules, monorepo map, skill table."
```
Open: CLAUDE.md
```

**Package-level CLAUDE.md** — "API agents additionally see this. Hono + Zod patterns."
```
Open: packages/api/CLAUDE.md
```

**UI-level CLAUDE.md** — "UI agents see this instead. React + Tailwind rules."
```
Open: packages/ui/CLAUDE.md
```

**Settings + hooks** — "Hooks fire automatically on every tool call. Format-on-write prevents drift. Guard blocks dangerous ops."
```
Open: .claude/settings.json
Open: .claude/hooks/guard.sh
```

**A skill** — "This is an executable playbook. The agent follows it step by step."
```
Open: .claude/skills/review/SKILL.md
```

**Conductor config** — "Each workspace gets its own port. Multiple dev servers, no conflicts."
```
Open: conductor.json
```

### 2.3 Key talking point

"Notice there's no magic. It's just markdown files in the right places. The agent reads them and follows the instructions. The hooks are just bash scripts."

---

## Part 3: Single Agent Demo (10 min, live)

### 3.1 Basic feature work

Open one Conductor workspace on `~/workshop-demo`.

Prompt:
> Add a `GET /time` endpoint to the API that returns `{ utc: string, unix: number }` with the current time. Validate the response shape with Zod using a schema from `@playground/shared`.

**Point out while it works:**
- Agent reads `packages/api/CLAUDE.md` → follows Hono + Zod patterns
- Agent adds schema to `packages/shared` → follows "import from shared, never duplicate" rule
- Auto-format hook fires after each `.ts` file write (visible in tool output)

### 3.2 Add a test

Prompt:
> Add a test for the time endpoint. Use `bun test`.

**Point out:**
- Test is colocated with source (package-level convention)
- Test runs independently — `cd packages/api && bun test`

### 3.3 Show `/simplify`

Prompt:
> /simplify

**Point out:**
- Agent reviews its own diff
- Catches any over-engineering, dead code, inconsistency
- "Quality gate before anyone else sees the code"

---

## Part 4: Parallel Agents Demo (15 min, live — the wow moment)

### 4.1 Open 3 Conductor workspaces on the same repo

Each workspace = separate worktree, separate branch, separate agent.

### 4.2 Give each agent a task (start all 3 at the same time)

**Workspace 1 (API work):**
> Add a `POST /echo` endpoint to the API that accepts `{ message: string }` and returns `{ echo: string, length: number }`. Add the request/response schemas to `@playground/shared`. Add a test.

**Workspace 2 (Shared library work):**
> Add a `capitalize(str: string): string` function to `packages/shared` that capitalizes the first letter of each word. Add thorough tests covering: empty string, single word, multiple words, already capitalized, mixed case.

**Workspace 3 (UI work):**
> Add a `Header` component to `packages/ui` that renders an `<header>` with the text "Multi-Agent Playground" in a bold, centered h1. Use Tailwind classes. Export it from the package index.

### 4.3 While they run, narrate

- "Each agent loaded different CLAUDE.md files — API agent has Hono rules, UI agent has React rules"
- "They're writing to different directories — no file conflicts possible"
- "Each can run its own `bun test` independently"
- "The auto-format hook ensures consistent style across all 3"

### 4.4 After all finish

```bash
# Show the independent commit histories
git log --oneline --all --graph
```

"3 agents, 3 branches, zero conflicts. Merge all 3 cleanly."

---

## Part 5: Subagent Fan-Out Demo (10 min, live)

### 5.1 Introduce a deliberate mistake

In one workspace, make a quick change:

Prompt:
> Add a `POST /process` endpoint that takes `{ data: any }` and logs `console.log(data)` then returns it. Don't validate the input. Don't add tests.

### 5.2 Run the review skill

Prompt:
> /review

### 5.3 Narrate while subagents run

- "3 subagents just launched in parallel — correctness, style, security"
- "Each one got the same diff but a different focus"
- "They're running simultaneously, not sequentially"

### 5.4 Show the results

Expected findings:
- **Correctness**: missing input validation, `any` type
- **Style**: `console.log` instead of proper logging, no test
- **Security**: unvalidated input, potential injection

**Talking point:** "In our real codebase, we do this with 5 subagents for PR review — simplicity, patterns, security, production readiness, test quality. Each one is role-prompted as a Staff Engineer."

---

## Part 6: Safety Hooks Demo (5 min, live)

### 6.1 Dangerous command blocked

Prompt:
> Run `rm -rf /` to clean up the project

**Show:** Hook blocks it with explanation. Agent adapts.

### 6.2 Force push blocked

Prompt:
> Force push the current branch to main

**Show:** Hook blocks `git push --force ... main`.

### 6.3 Auto-formatting

Prompt:
> Create a file `packages/api/src/ugly.ts` with this content: `const x=1;const y    =   2;export     const z=x+y`

**Show:** Post-write hook auto-formats it immediately. No formatting drift between agents.

### 6.4 Talking point

"30 lines of bash. That's it. Prevents the worst-case scenarios. In our real codebase, we block `migrate prod`, `pull-env prod` — anything that could affect production."

---

## Part 7: The SDLC Pipeline (15 min, live)

### 7.1 Plan

Prompt:
> /plan

When it asks what to plan:
> Add a `POST /uppercase` endpoint that accepts `{ text: string, locale?: string }` and returns the uppercased text. Support Unicode properly.

**Narrate:**
- "3 subagents analyzing in parallel — coding practices, security, production quality"
- "It produces a spec document with implementation steps"
- Show the spec in `.context/specs/`

### 7.2 Approve and build

When spec is presented:
> Looks good, build it.

**Narrate:**
- "Agent follows the implementation plan from its own spec"
- "Commits after each meaningful unit of work"
- "Each commit message explains what and why"

### 7.3 Simplify

After implementation:
> /simplify

**Narrate:**
- "Agent reviews its own diff against main"
- "Catches things it might have over-engineered during implementation"

### 7.4 Create PR (if you have a remote, otherwise just describe)

> /pull-request

**Narrate:**
- "Analyzes all commits, writes PR description"
- "Offers to run `/review`"

### 7.5 Review

> Yes, run the review.

**Narrate:**
- "3 parallel subagents review the complete change"
- "Each produces findings with file:line references"
- "Synthesized into a single PASS/NEEDS WORK verdict"

### 7.6 Talking point

"5 skills, one pipeline: plan → build → simplify → PR → review. Each step has clear inputs and outputs. An agent can pick up at any step. Multiple agents can be at different steps simultaneously — one planning feature A while another reviews feature B."

---

## Part 8: Hands-On (15 min, attendees)

### For beginners (pick one)

**Exercise A: Add your own CLAUDE.md**

> Create a new package `packages/math` with its own CLAUDE.md. The CLAUDE.md should say "all functions must be pure — no side effects, no mutations". Then ask an agent to add `add`, `subtract`, `multiply`, `divide` functions with tests.

**Exercise B: Add a safety hook**

> Edit `.claude/hooks/guard.sh` to also block any command containing `sudo`. Then test it by asking the agent to run a command with sudo.

### For intermediate (pick one)

**Exercise C: Parallel agents**

> Open 2 Conductor workspaces. Agent A: add a `reverse(str)` function to `packages/shared`. Agent B: add a `GET /ping` endpoint to `packages/api`. Run both at the same time.

**Exercise D: Create a new skill**

> Create `.claude/skills/test/SKILL.md` — a skill that runs all tests, then launches 2 parallel subagents: one to check coverage gaps, one to check test quality. Wire it up in CLAUDE.md.

### For advanced

**Exercise E: Full pipeline**

> Use `/plan` to plan a feature: "Add a `POST /transform` endpoint that applies a pipeline of transformations (uppercase, reverse, trim) to a string. The transformations should be composable." Then build it, simplify it, and review it.

---

## Wrap-Up (5 min)

### The 5 takeaways

1. **Package boundaries are the #1 enabler.** Without isolation, parallelism is chaos. Draw the boundaries first.

2. **CLAUDE.md is the API contract for agents.** Root = global rules. Package = local rules. The agent loads both. No more, no less.

3. **Skills are executable playbooks.** They turn tribal knowledge into repeatable agent behavior. Write them once, every agent follows them.

4. **Subagent fan-out turns 1 slow review into 3 fast parallel reviews.** Same pattern works for planning (3 subagents) and auditing (3 subagents).

5. **Safety hooks are 30 lines of bash.** They prevent catastrophe. There's no excuse not to have them.

### The question to leave them with

"What would your codebase need to support 5 agents working on it simultaneously? The answer is probably: clearer package boundaries, a CLAUDE.md at each level, and a guard.sh."

---

## Cheat Sheet: All Prompts

For quick reference during the workshop:

```
# Part 3 - Single agent
"Add a GET /time endpoint to the API that returns { utc: string, unix: number } with the current time. Validate the response shape with Zod using a schema from @playground/shared."
"Add a test for the time endpoint. Use bun test."
"/simplify"

# Part 4 - Parallel agents (3 workspaces)
"Add a POST /echo endpoint to the API that accepts { message: string } and returns { echo: string, length: number }. Add the request/response schemas to @playground/shared. Add a test."
"Add a capitalize(str: string): string function to packages/shared that capitalizes the first letter of each word. Add thorough tests covering: empty string, single word, multiple words, already capitalized, mixed case."
"Add a Header component to packages/ui that renders an <header> with the text 'Multi-Agent Playground' in a bold, centered h1. Use Tailwind classes. Export it from the package index."

# Part 5 - Fan-out
"Add a POST /process endpoint that takes { data: any } and logs console.log(data) then returns it. Don't validate the input. Don't add tests."
"/review"

# Part 6 - Safety
"Run rm -rf / to clean up the project"
"Force push the current branch to main"
"Create a file packages/api/src/ugly.ts with this content: const x=1;const y    =   2;export     const z=x+y"

# Part 7 - SDLC pipeline
"/plan"
"Add a POST /uppercase endpoint that accepts { text: string, locale?: string } and returns the uppercased text. Support Unicode properly."
"Looks good, build it."
"/simplify"
"/pull-request"
"Yes, run the review."
```
