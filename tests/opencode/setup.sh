#!/usr/bin/env bash
# Setup: isolated environment for OpenCode tests
# Creates a sandboxed HOME so tests never touch real config
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

export TEST_HOME
TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export OPENCODE_CONFIG_DIR="$TEST_HOME/.config/opencode"

# Simulate the installed plugin layout:
#   <config>/superpowers/                   ← package root
#   <config>/superpowers/skills/             ← copy of ./skills
#   <config>/superpowers/.opencode/plugins/superpowers.js ← copy of plugin
#   <config>/plugins/superpowers.js          ← symlink OpenCode reads
SUPERPOWERS_DIR="$OPENCODE_CONFIG_DIR/superpowers"
SUPERPOWERS_SKILLS_DIR="$SUPERPOWERS_DIR/skills"
SUPERPOWERS_PLUGIN_FILE="$SUPERPOWERS_DIR/.opencode/plugins/superpowers.js"

mkdir -p "$SUPERPOWERS_DIR"
cp -r "$REPO_ROOT/skills" "$SUPERPOWERS_DIR/"
mkdir -p "$(dirname "$SUPERPOWERS_PLUGIN_FILE")"
cp "$REPO_ROOT/.opencode/plugins/superpowers.js" "$SUPERPOWERS_PLUGIN_FILE"
mkdir -p "$OPENCODE_CONFIG_DIR/plugins"
ln -sf "$SUPERPOWERS_PLUGIN_FILE" "$OPENCODE_CONFIG_DIR/plugins/superpowers.js"

# Personal test skill
mkdir -p "$OPENCODE_CONFIG_DIR/skills/personal-test"
cat > "$OPENCODE_CONFIG_DIR/skills/personal-test/SKILL.md" <<'EOF'
---
name: personal-test
description: Test personal skill for verification
---
# Personal Test Skill

PERSONAL_SKILL_MARKER_12345
EOF

# Project test skill
mkdir -p "$TEST_HOME/test-project/.opencode/skills/project-test"
cat > "$TEST_HOME/test-project/.opencode/skills/project-test/SKILL.md" <<'EOF'
---
name: project-test
description: Test project skill for verification
---
# Project Test Skill

PROJECT_SKILL_MARKER_67890
EOF

echo "Setup: $TEST_HOME"
echo "Config: $OPENCODE_CONFIG_DIR"
echo "Skills: $SUPERPOWERS_SKILLS_DIR ($(find "$SUPERPOWERS_SKILLS_DIR" -name SKILL.md | wc -l) skills)"

cleanup_test_env() {
    [ -n "${TEST_HOME:-}" ] && [ -d "$TEST_HOME" ] && rm -rf "$TEST_HOME" 2>/dev/null || true
}

export -f cleanup_test_env
export REPO_ROOT SUPERPOWERS_DIR SUPERPOWERS_SKILLS_DIR SUPERPOWERS_PLUGIN_FILE
