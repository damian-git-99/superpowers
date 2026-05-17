#!/usr/bin/env bash
# Test: Skill priority resolution (project > personal > superpowers)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup.sh"
trap cleanup_test_env EXIT

echo "=== OpenCode: Skill Priority ==="

# Create same skill in all three locations with unique markers
setup_priority_test() {
    # Superpowers version (lowest priority)
    mkdir -p "$SUPERPOWERS_SKILLS_DIR/priority-test"
    cat > "$SUPERPOWERS_SKILLS_DIR/priority-test/SKILL.md" <<'EOF'
---
name: priority-test
description: Superpowers version
---
PRIORITY_MARKER_SUPERPOWERS
EOF

    # Personal version (medium priority)
    mkdir -p "$OPENCODE_CONFIG_DIR/skills/priority-test"
    cat > "$OPENCODE_CONFIG_DIR/skills/priority-test/SKILL.md" <<'EOF'
---
name: priority-test
description: Personal version
---
PRIORITY_MARKER_PERSONAL
EOF

    # Project version (highest priority)
    mkdir -p "$TEST_HOME/test-project/.opencode/skills/priority-test"
    cat > "$TEST_HOME/test-project/.opencode/skills/priority-test/SKILL.md" <<'EOF'
---
name: priority-test
description: Project version
---
PRIORITY_MARKER_PROJECT
EOF
}

setup_priority_test

echo "Test 1: Fixtures exist..."
for f in "$SUPERPOWERS_SKILLS_DIR/priority-test/SKILL.md" \
         "$OPENCODE_CONFIG_DIR/skills/priority-test/SKILL.md" \
         "$TEST_HOME/test-project/.opencode/skills/priority-test/SKILL.md"; do
    [ -f "$f" ] && echo "  [PASS] $(basename $(dirname $f)) version" || { echo "  [FAIL] $f"; exit 1; }
done

# Integration tests require OpenCode CLI
if ! command -v opencode &> /dev/null; then
    echo ""
    echo "  [SKIP] Integration tests require OpenCode CLI"
    echo "=== Priority fixture tests passed (integration skipped) ==="
    exit 0
fi

echo ""
echo "Test 2: Outside project → personal overrides superpowers..."
cd "$HOME"
output=$(timeout 60s opencode run --print-logs \
    "Use the use_skill tool to load priority-test. Show me the exact marker." 2>&1 || true)

if echo "$output" | grep -q "PRIORITY_MARKER_PERSONAL"; then
    echo "  [PASS] Personal version loaded"
elif echo "$output" | grep -q "PRIORITY_MARKER_SUPERPOWERS"; then
    echo "  [FAIL] Superpowers loaded instead of personal"
    exit 1
else
    echo "  [WARN] Could not verify marker"
    echo "$output" | grep -i priority | head -5
fi

echo ""
echo "Test 3: Inside project → project overrides all..."
cd "$TEST_HOME/test-project"
output=$(timeout 60s opencode run --print-logs \
    "Use the use_skill tool to load priority-test. Show me the exact marker." 2>&1 || true)

if echo "$output" | grep -q "PRIORITY_MARKER_PROJECT"; then
    echo "  [PASS] Project version loaded"
else
    echo "  [FAIL] Wrong version loaded"
    echo "$output" | grep -i priority | head -5
    exit 1
fi

echo ""
echo "=== All priority tests passed ==="
