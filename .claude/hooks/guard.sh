#!/bin/bash
# Safety guard — blocks dangerous operations from agents.
# Add your own rules here for production projects.

COMMAND="$CLAUDE_BASH_COMMAND"

# Block recursive deletes of root or home
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/|~|\$HOME)'; then
  echo "BLOCKED: Recursive delete of root/home directory."
  exit 2
fi

# Block force push to main/master
if echo "$COMMAND" | grep -qE 'git\s+push.*--force.*(main|master)'; then
  echo "BLOCKED: Force push to main/master."
  exit 2
fi

# Block dropping databases
if echo "$COMMAND" | grep -qiE 'drop\s+(database|table)'; then
  echo "BLOCKED: Drop database/table operation."
  exit 2
fi

exit 0
