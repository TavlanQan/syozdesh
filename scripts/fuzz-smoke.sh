#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# Short fuzz smoke. Requires nightly + cargo-fuzz. NOT used in Phase 5.5.

set -euo pipefail
cd "$(dirname "$0")/../fuzz"

for target in canonical_decode envelope_decode; do
    echo "[fuzz-smoke] $target (60s)"
    cargo +nightly fuzz run "$target" -- -max_total_time=60
done
