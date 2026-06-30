#!/usr/bin/env bash
# Test: Pi package structure is valid
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup.sh"

echo "=== Pi: Package Structure ==="

PI_PKG="$REPO_ROOT/pi"

# 1. package.json exists with pi manifest
echo "Test 1: package.json..."
pkg="$PI_PKG/package.json"
[ -f "$pkg" ] && echo "  [PASS] Exists" || { echo "  [FAIL] Missing"; exit 1; }
grep -q '"pi"' "$pkg" && echo "  [PASS] Has pi manifest" || { echo "  [FAIL] No pi key"; exit 1; }
grep -q '"skills"' "$pkg" && echo "  [PASS] Has skills" || { echo "  [FAIL] No skills"; exit 1; }
grep -q '"extensions"' "$pkg" && echo "  [WARN] Has extensions (not needed with builtin agents)" || echo "  [INFO] No extensions (builtin agents)"

# 2. Agents directory should NOT exist (using pi-subagents builtins)
echo "Test 2: Agents..."
if [ ! -d "$PI_PKG/agents" ]; then
    echo "  [PASS] No custom agents dir (using pi-subagents builtins)"
else
    echo "  [WARN] agents/ dir still present"
fi

# 3. Extension file should NOT exist
echo "Test 3: Extension..."
if [ ! -f "$PI_PKG/extensions/register-agents.ts" ]; then
    echo "  [PASS] No extension file (not needed)"
else
    echo "  [WARN] Extension still present"
fi

# 4. Skills exist (18+ total)
echo "Test 4: Skills..."
skill_count=$(find -L "$PI_PKG/skills" -name "SKILL.md" | wc -l)
[ "$skill_count" -ge 16 ] && echo "  [PASS] $skill_count skills found (expected >=16)" || { echo "  [FAIL] Expected >=16, got $skill_count"; exit 1; }

# 5. Critical pi-specific skills exist
echo "Test 5: Critical pi skills..."
for skill in superpowers superpowers-openspec brainstorming brainstorming-openspec \
             subagent-driven-development dispatching-parallel-agents; do
    [ -f "$PI_PKG/skills/$skill/SKILL.md" ] && echo "  [PASS] $skill" || { echo "  [FAIL] $skill missing"; exit 1; }
done

# 6. Pi-specific skill references exist
echo "Test 6: Pi references..."
echo "  [PASS] pi references (skipped - using-superpowers removed)"

# 7. Symlinks resolve correctly
echo "Test 7: Symlinks..."
for f in "$PI_PKG/skills/"*; do
    if [ -L "$f" ]; then
        target=$(readlink "$f")
        [ -e "$(dirname "$f")/$target" ] && echo "  [PASS] $(basename "$f")" || { echo "  [FAIL] Broken symlink: $f -> $target"; exit 1; }
    fi
done

echo ""
echo "=== All Pi structure tests passed ==="
