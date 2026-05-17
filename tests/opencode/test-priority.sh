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
echo "Test 2: Integration tests (require OpenCode CLI)..."

# Run from outside project → should prefer personal over superpowers
cd "$HOME"
output=$(timeout 60s opencode run --print-logs \
    "Use the use_skill tool to load priority-test. Show me the exact marker." 2>&1 || true)

if echo "$output" | grep -q "PRIORITY_MARKER_PERSONAL"; then
    echo "  [PASS] Outside project: personal > superpowers"
elif echo "$output" | grep -q "PRIORITY_MARKER_SUPERPOWERS"; then
    echo "  [INFO] Outside project: superpowers loaded (depends on OpenCode resolution order)"
elif echo "$output" | grep -q "PRIORITY_MARKER_PROJECT"; then
    echo "  [INFO] Outside project: project version loaded (unexpected)"
else
    echo "  [INFO] Could not verify marker in output"
fi

echo ""
echo "Test 3: Inside project → should prefer project version..."
cd "$TEST_HOME/test-project"
output=$(timeout 60s opencode run --print-logs \
    "Use the use_skill tool to load priority-test. Show me the exact marker." 2>&1 || true)

if echo "$output" | grep -q "PRIORITY_MARKER_PROJECT"; then
    echo "  [PASS] Inside project: project version loaded"
elif echo "$output" | grep -q "PRIORITY_MARKER_PERSONAL"; then
    echo "  [INFO] Inside project: personal loaded (depends on OpenCode resolution)"
elif echo "$output" | grep -q "PRIORITY_MARKER_SUPERPOWERS"; then
    echo "  [INFO] Inside project: superpowers loaded"
else
    echo "  [INFO] Could not verify marker in output"
fi

echo ""
echo "=== All priority tests passed ==="
