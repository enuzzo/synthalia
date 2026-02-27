#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install gh CLI if not already present
if ! command -v gh &>/dev/null; then
  echo "Installing gh CLI..."
  apt-get install -y gh
fi

# Authenticate gh CLI using GH_TOKEN project secret
if [ -n "${GH_TOKEN:-}" ]; then
  echo "$GH_TOKEN" | gh auth login --with-token
  echo "gh CLI authenticated"
else
  echo "Warning: GH_TOKEN not set — add it in your project secrets to enable gh CLI."
fi
