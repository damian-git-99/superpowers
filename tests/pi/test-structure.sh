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
grep -q '"skills"' "$pkg" && echo "  [PASS] Has skills entry" || { echo "  [FAIL] No skills"; exit 1; }
grep -q '"extensions"' "$pkg" && echo "  [PASS] Has extensions entry" || { echo "  [FAIL] No extensions"; exit 1; }

# 2. Extension file exists
echo "Test 2: Extension..."
ext="$PI_PKG/extensions/register-agents.ts"
[ -f "$ext" ] && echo "  [PASS] register-agents.ts" || { echo "  [FAIL] Missing"; exit 1; }

# 3. Agent files exist
echo "Test 3: Agents..."
expected_agents=("code-reviewer" "implementer" "spec-reviewer" "spec-document-reviewer" "plan-document-reviewer")
for a in "${expected_agents[@]}"; do
    [ -f "$PI_PKG/agents/$a.md" ] && echo "  [PASS] $a" || { echo "  [FAIL] $a missing"; exit 1; }
done

# 4. All agent frontmatter is valid (name + description)
echo "Test 4: Agent frontmatter..."
for f in "$PI_PKG/agents/"*.md; do
    name=$(basename "$f" .md)
    grep -q "^name: $name" "$f" && echo "  [PASS] $name: name" || { echo "  [FAIL] $name: missing name"; exit 1; }
    grep -q "^description:" "$f" && echo "  [PASS] $name: description" || { echo "  [FAIL] $name: missing description"; exit 1; }
done

# 5. Skills exist (18 total)
echo "Test 5: Skills..."
skill_count=$(find -L "$PI_PKG/skills" -name "SKILL.md" | wc -l)
[ "$skill_count" -ge 16 ] && echo "  [PASS] $skill_count skills found (expected >=16)" || { echo "  [FAIL] Expected >=16, got $skill_count (try: find -L)"; exit 1; }

# 6. Critical pi-specific skills exist
echo "Test 6: Critical pi skills..."
for skill in superpowers superpowers-openspec using-superpowers brainstorming brainstorming-openspec \
             subagent-driven-development dispatching-parallel-agents; do
    [ -f "$PI_PKG/skills/$skill/SKILL.md" ] && echo "  [PASS] $skill" || { echo "  [FAIL] $skill missing"; exit 1; }
done

# 7. Pi-specific skill references exist
echo "Test 7: Pi references..."
[ -f "$PI_PKG/skills/using-superpowers/references/pi-tools.md" ] && \
    echo "  [PASS] pi-tools.md" || { echo "  [FAIL] pi-tools.md missing"; exit 1; }

# 8. Symlinks resolve correctly
echo "Test 8: Symlinks..."
for f in "$PI_PKG/skills/"*; do
    if [ -L "$f" ]; then
        target=$(readlink "$f")
        [ -e "$(dirname "$f")/$target" ] && echo "  [PASS] $(basename "$f")" || { echo "  [FAIL] Broken symlink: $f -> $target"; exit 1; }
    fi
done

echo ""
echo "=== All Pi structure tests passed ==="
