#!/usr/bin/env bash
# Run the nrk8s-diag.sh test suite.
# Requires bats-core: https://github.com/bats-core/bats-core
#   brew install bats-core   (macOS)
#   apt-get install bats     (Debian/Ubuntu)

set -euo pipefail

if ! command -v bats >/dev/null 2>&1; then
    echo "Error: bats is not installed."
    echo ""
    echo "Install with:"
    echo "  brew install bats-core    # macOS"
    echo "  apt-get install bats      # Debian/Ubuntu"
    echo "  npm install -g bats       # via npm"
    exit 1
fi

cd "$(dirname "$0")"
bats test_nrk8s_diag.bats
