#!/usr/bin/env bash
# OpenCode test suite runner
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "==================================="
echo " OpenCode Plugin Test Suite"
echo "==================================="
echo ""

tests=(
    "test-plugin-loading.sh"
    "test-priority.sh"
)

passed=0; failed=0
for test in "${tests[@]}"; do
    echo "--- Running: $test ---"
    if output=$(bash "$test" 2>&1); then
        echo "  RESULT: PASS"
        passed=$((passed+1))
    else
        echo "  RESULT: FAIL"
        echo "$output"
        failed=$((failed+1))
    fi
    echo ""
done

echo "==================================="
echo " Passed: $passed  Failed: $failed"
echo "==================================="
[ "$failed" -eq 0 ]
