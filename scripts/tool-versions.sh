#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# Pinned tool versions for myapp bootstrap and CI.
# Phase 5.5 scope: only tools actually used by Phase 5.5-A and 5.5-B.
#
# Update procedure: see docs/DEPENDENCIES.md §Tooling.

# ---- Rust toolchain (rustup-managed) ------------------------------------
readonly RUST_TOOLCHAIN="1.98.1"
readonly RUST_TOOLCHAIN_DATE="2026-09-03"
readonly RUST_TOOLCHAIN_SOURCE="rustup / static.rust-lang.org"

# ---- Cargo-installed tools ----------------------------------------------
# BLOCKING(Phase 5.5-A): fill in with real versions before running
# scripts/phase5_5.sh.
readonly CARGO_DENY_VERSION="0.0.0"
readonly CARGO_DENY_DATE="YYYY-MM-DD"

# ---- External binaries ---------------------------------------------------
readonly EXTERNAL_JQ_MIN_VERSION="1.7"

# ---- Runner-provided tools ----------------------------------------------
readonly RUNNER_GIT_MIN_VERSION="2.40"
readonly RUNNER_RUSTUP_MIN_VERSION="1.27"
readonly RUNNER_BASH_MIN_VERSION="5.2"
