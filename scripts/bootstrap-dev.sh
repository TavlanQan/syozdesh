#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# Bootstrap a local dev environment for myapp.

set -euo pipefail
cd "$(dirname "$0")/.."

echo "[bootstrap-dev] Phase 5 skeleton."

# TODO(Phase 6):
#   - rustup toolchain install $(grep channel rust-toolchain.toml | cut -d'"' -f2)
#   - cargo install --locked cargo-deny@<version>
#   - rustup component add rustfmt clippy rust-src
#   - print next steps: ./scripts/run-relay.sh, cargo run -p myapp-cli

exit 0
