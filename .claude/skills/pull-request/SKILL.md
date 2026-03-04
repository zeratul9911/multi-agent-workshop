---
name: pull-request
description: Create a PR with a proper description, then offer to run review.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

# Pull Request Skill

Create a PR, then optionally run the review skill.

## Workflow

### Phase 1: Analyze changes

```bash
git fetch origin main
git log --oneline origin/main..HEAD
git diff --stat origin/main...HEAD
```

### Phase 2: Create PR

```bash
gh pr create --title "feat: short description" --body "$(cat <<'EOF'
## Summary
- What changed and why

## Test plan
- [ ] How to verify

EOF
)"
```

Title rules:
- Under 70 chars
- Conventional commit prefix: `feat`, `fix`, `refactor`, `chore`
- Lowercase, imperative mood

### Phase 3: Offer review

Ask the user: "Want me to run `/review` on this PR?"

If yes, invoke the review skill (3 parallel subagents).
