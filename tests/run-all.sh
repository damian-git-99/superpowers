#!/usr/bin/env bash
# Root test runner - runs all platform test suites
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo " Superpowers Test Suite"
echo "========================================="
echo "Repository: $(cd "$SCRIPT_DIR/.." && pwd)"
echo "Test time: $(date)"
echo ""

passed=0
failed=0
results=()

run_suite() {
    local name="$1"
    local runner="$2"
    local opts="${3:-}"

    echo "----------------------------------------"
    echo " Suite: $name"
    echo "----------------------------------------"

    if bash "$runner" $opts 2>&1; then
        echo ""
        echo "  [PASS] $name"
        passed=$((passed + 1))
        results+=("✅ $name")
    else
        echo ""
        echo "  [FAIL] $name"
        failed=$((failed + 1))
        results+=("❌ $name")
    fi
    echo ""
}

# OpenCode tests
run_suite "OpenCode: plugin loading" "$SCRIPT_DIR/opencode/run-tests.sh"

# Pi tests
run_suite "Pi: package structure" "$SCRIPT_DIR/pi/run-tests.sh"

echo "========================================="
echo " Results"
echo "========================================="
for r in "${results[@]}"; do echo "  $r"; done
echo ""
echo "  Passed: $passed  Failed: $failed"
echo ""

[ "$failed" -eq 0 ]
