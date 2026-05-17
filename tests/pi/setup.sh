#!/usr/bin/env bash
# Setup: isolated environment for Pi tests
set -euo pipefail

export REPO_ROOT
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Pi package root
export PI_PACKAGE="$REPO_ROOT/pi"

cleanup_test_env() {
    [ -n "${TEST_HOME:-}" ] && [ -d "$TEST_HOME" ] && rm -rf "$TEST_HOME" 2>/dev/null || true
}
export -f cleanup_test_env
