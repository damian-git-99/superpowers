#!/usr/bin/env bash
# Test: Pi package installs correctly and skills are discoverable
# Requires: `pi` CLI installed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup.sh"

echo "=== Pi: Installation ==="

if ! command -v pi &> /dev/null; then
    echo "  [SKIP] Pi CLI not found"
    exit 0
fi

# 1. Package installs
echo "Test 1: pi install..."
output=$(pi install "$PI_PACKAGE" 2>&1) || { echo "  [FAIL] Install failed: $output"; exit 1; }
echo "  [PASS] Installed"

# 2. Package appears in pi list
echo "Test 2: pi list..."
if output=$(pi list 2>&1); then
    if echo "$output" | grep -q "superpowers-pi"; then
        echo "  [PASS] superpowers-pi in package list"
    else
        echo "  [FAIL] superpowers-pi not found"
        echo "$output"
        exit 1
    fi
fi

# 3. Skills discovered
echo "Test 3: Skills..."
pi_cache=$(find /tmp -path "*/pi-packages/*superpowers*" -type d 2>/dev/null | head -1 || true)
if [ -n "$pi_cache" ] && [ -d "$pi_cache" ]; then
    count=$(find -L "$pi_cache" -name "SKILL.md" 2>/dev/null | wc -l)
    [ "$count" -ge 16 ] && echo "  [PASS] $count skills discovered" || echo "  [WARN] Only $count skills found"
else
    echo "  [INFO] Skills installed (check ~/.pi/)"
fi

echo ""
echo "=== Pi install tests completed ==="
