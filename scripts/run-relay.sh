#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# Run a local relay instance for development.

set -euo pipefail
cd "$(dirname "$0")/.."

export RUST_LOG="${RUST_LOG:-myapp=debug,info}"

exec cargo run --locked -p myapp-relay -- "$@"
