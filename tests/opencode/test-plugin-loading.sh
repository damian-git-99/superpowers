#!/usr/bin/env bash
# Test: Plugin loads correctly and skills/agents are discoverable
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup.sh"
trap cleanup_test_env EXIT

echo "=== OpenCode: Plugin Loading ==="

# 1. Verify plugin symlink exists
echo "Test 1: Plugin registration..."
plugin_link="$OPENCODE_CONFIG_DIR/plugins/superpowers.js"
[ -L "$plugin_link" ] && echo "  [PASS] Plugin symlink exists" || { echo "  [FAIL]"; exit 1; }
[ -f "$(readlink -f "$plugin_link")" ] && echo "  [PASS] Plugin target exists" || { echo "  [FAIL]"; exit 1; }

# 2. Verify skills are present
echo "Test 2: Skills directory..."
skill_count=$(find "$SUPERPOWERS_SKILLS_DIR" -name "SKILL.md" | wc -l)
[ "$skill_count" -ge 16 ] && echo "  [PASS] $skill_count skills found" || { echo "  [FAIL] Expected >=16, got $skill_count"; exit 1; }

# 3. Verify critical skills exist
echo "Test 3: Critical skills..."
for skill in brainstorming subagent-driven-development test-driven-development systematic-debugging; do
    [ -f "$SUPERPOWERS_SKILLS_DIR/$skill/SKILL.md" ] && echo "  [PASS] $skill" || { echo "  [FAIL] $skill missing"; exit 1; }
done

# 4. Plugin JS is valid
echo "Test 4: Plugin syntax..."
node --check "$SUPERPOWERS_PLUGIN_FILE" 2>/dev/null && echo "  [PASS] Valid syntax" || { echo "  [FAIL]"; exit 1; }

echo ""
echo "=== All plugin loading tests passed ==="
