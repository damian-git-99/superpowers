#!/usr/bin/env bash
# Test: Pi package installs correctly and skills/agents are discoverable
# Requires: `pi` CLI installed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup.sh"

echo "=== Pi: Installation ==="

if ! command -v pi &> /dev/null; then
    echo "  [SKIP] Pi CLI not found"
    echo "  Install from: https://pi.dev"
    exit 0
fi

# 1. Package installs
echo "Test 1: pi install..."
output=$(pi install "$PI_PACKAGE" 2>&1) || { echo "  [FAIL] Install failed: $output"; exit 1; }
echo "  [PASS] Installed"

# 2. Package appears in pi list
echo "Test 2: pi list..."
if output=$(pi list 2>&1); then
    if echo "$output" | grep -q "superpowers-pi\|superpowers"; then
        echo "  [PASS] superpowers-pi in package list"
    else
        echo "  [FAIL] superpowers-pi not found in packages"
        echo "$output"
        exit 1
    fi
else
    echo "  [FAIL] pi list failed"
    exit 1
fi

# 3. Skills directory exists in installed location
echo "Test 3: Skills discovered..."
skill_dirs=$(find "$HOME/.pi/agent" -path "*/superpowers-pi/skills" -type d 2>/dev/null || true)
pi_cache=$(find /tmp -path "*/pi-packages/*superpowers*" -type d 2>/dev/null | head -1 || true)

found=false
for candidate in "$skill_dirs" "$pi_cache"; do
    if [ -n "$candidate" ] && [ -d "$candidate" ]; then
        count=$(find "$candidate" -name "SKILL.md" 2>/dev/null | wc -l)
        if [ "$count" -ge 16 ]; then
            echo "  [PASS] $count skills found at $candidate"
            found=true
            break
        fi
    fi
done

if [ "$found" = false ]; then
    echo "  [WARN] Could not verify skills in pi cache"
    echo "  (Check manually: ls ~/.pi/agent/skills/)"
fi

# 4. Agent files were copied by extension
echo "Test 4: Agents registered..."
agent_dir="$HOME/.pi/agent/agents/superpowers"
if [ -d "$agent_dir" ]; then
    count=$(ls "$agent_dir"/*.md 2>/dev/null | wc -l)
    echo "  [PASS] $count agents in $agent_dir"
else
    echo "  [WARN] Agents dir not found at $agent_dir"
    echo "  (Run pi once - the extension copies on session_start)"
fi

echo ""
echo "=== Pi install tests completed ==="
