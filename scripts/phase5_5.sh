#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
#
# phase5_5.sh — myapp Bootstrap Validation gate (Phase 5.5-A).
#
# Exit codes:
#   0 — all checks passed (Phase 5.5-A PASS)
#   1 — a check failed
#   2 — environment error

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

readonly TOTAL_STEPS=17
step=0

step_start() {
    step=$((step + 1))
    printf '\n[Phase 5.5] STEP %d/%d: %s\n' "${step}" "${TOTAL_STEPS}" "$1"
}
pass() { printf '[Phase 5.5] PASS: %s\n' "$1"; }
fail() {
    local msg="$1" expected="$2" action="$3"
    printf '\n[Phase 5.5] FAILED: %s\n' "${msg}"
    printf 'Expected:\n  %s\n' "${expected}"
    printf 'Action:\n  %s\n' "${action}"
    exit 1
}
env_fail() { printf '\n[Phase 5.5] ENV ERROR: %s\n' "$1"; exit 2; }

printf '[Phase 5.5] myapp Bootstrap Validation (Phase 5.5-A)\n'
printf '[Phase 5.5] Repo root: %s\n' "${REPO_ROOT}"

# shellcheck disable=SC1091
source scripts/tool-versions.sh

step_start "Required tools present on PATH with sufficient versions"
check_present() { command -v "$1" >/dev/null 2>&1 || env_fail "missing required tool: $1"; }
check_min_ver() {
    local tool="$1" actual="$2" required="$3"
    if [[ "$(printf '%s\n%s\n' "${required}" "${actual}" | sort -V | head -n1)" != "${required}" ]]; then
        fail "${tool} ${actual} is older than required ${required}" \
            "${tool} >= ${required}" \
            "upgrade ${tool} (see docs/PHASE_5_5_A.md §1)"
    fi
}
for t in cargo rustc jq git bash rustup; do check_present "$t"; done
jq_ver="$(jq --version | sed 's/^jq-//')"
git_ver="$(git --version | awk '{print $3}')"
bash_ver="$(bash --version | head -n1 | awk '{print $4}' | cut -d'(' -f1)"
rustup_ver="$(rustup --version | head -n1 | awk '{print $2}')"
check_min_ver jq     "${jq_ver}"     "${EXTERNAL_JQ_MIN_VERSION}"
check_min_ver git    "${git_ver}"    "${RUNNER_GIT_MIN_VERSION}"
check_min_ver bash   "${bash_ver}"   "${RUNNER_BASH_MIN_VERSION}"
check_min_ver rustup "${rustup_ver}" "${RUNNER_RUSTUP_MIN_VERSION}"
pass "jq=${jq_ver} git=${git_ver} bash=${bash_ver} rustup=${rustup_ver} all meet minimums"

step_start "Rust toolchain matches rust-toolchain.toml"
expected_channel="$(grep -E '^channel' rust-toolchain.toml | head -n1 | cut -d'"' -f2)"
actual_channel="$(rustc --version | awk '{print $2}')"
if [[ "${actual_channel}" != "${expected_channel}" ]]; then
    fail "rustc version mismatch" \
        "rustc ${expected_channel}" \
        "run: rustup toolchain install ${expected_channel} && rustup override set ${expected_channel}"
fi
pass "rustc ${actual_channel} matches rust-toolchain.toml"

step_start "cargo-deny installed (mandatory prerequisite)"
if ! command -v cargo-deny >/dev/null 2>&1; then
    if [[ "${CARGO_DENY_VERSION}" == "0.0.0" ]]; then
        fail "cargo-deny not installed; CARGO_DENY_VERSION not yet set" \
            "cargo-deny on PATH at the version pinned in scripts/tool-versions.sh" \
            "1) choose a version from https://crates.io/crates/cargo-deny
2) edit scripts/tool-versions.sh (CARGO_DENY_VERSION + CARGO_DENY_DATE)
3) cargo install --locked cargo-deny@<version>
See docs/PHASE_5_5_A.md §3."
    fi
    fail "cargo-deny is not installed" \
        "cargo-deny on PATH (required before Phase 5.5-A)" \
        "install it now: cargo install --locked cargo-deny@${CARGO_DENY_VERSION}"
fi
pass "cargo-deny present: $(cargo-deny --version)"

step_start "libsignal-protocol revision is pinned (not placeholder)"
placeholder="0000000000000000000000000000000000000000"
if grep -q "rev = \"${placeholder}\"" crates/crypto/Cargo.toml; then
    fail "libsignal-protocol rev is still the Phase 5 placeholder" \
        "crates/crypto/Cargo.toml contains a real 40-hex SHA" \
        "follow docs/PHASE_5_5_A.md §4"
fi
pass "libsignal rev pinned"

step_start "scripts/tool-versions.sh has no placeholder values"
if grep -E 'readonly [A-Z_]+="0\.0\.0"' scripts/tool-versions.sh >/dev/null; then
    fail "tool-versions.sh contains placeholder 0.0.0 values" \
        "all version variables populated" \
        "follow docs/PHASE_5_5_A.md §3"
fi
if grep -E 'readonly [A-Z_]+_DATE="YYYY-MM-DD"' scripts/tool-versions.sh >/dev/null; then
    fail "tool-versions.sh contains placeholder YYYY-MM-DD dates" \
        "all *_DATE variables populated" \
        "follow docs/PHASE_5_5_A.md §3"
fi
pass "tool versions populated"

step_start "LICENSE contains full AGPL-3.0-only text"
if grep -q 'Full AGPL-3.0-only text to be inserted here' LICENSE; then
    fail "LICENSE is still a placeholder" \
        "full AGPL-3.0-only text (https://www.gnu.org/licenses/agpl-3.0.txt)" \
        "replace the placeholder body in LICENSE with the full text"
fi
pass "LICENSE has full text"

step_start "cargo metadata resolves the workspace"
if ! cargo metadata --format-version=1 --no-deps >/dev/null 2>&1; then
    fail "cargo metadata failed" \
        "cargo resolves the workspace without network for --no-deps" \
        "run 'cargo metadata --format-version=1 --no-deps' and inspect"
fi
pass "workspace metadata resolved"

step_start "Frozen dependency graph respected (exact match)"
if ! ./scripts/check-deps.sh; then
    fail "check-deps.sh reported a violation" \
        "actual internal edges == ALLOWED_EDGES" \
        "fix the offending Cargo.toml, or file an ADR"
fi
pass "dependency graph exact-match"

step_start "Root Cargo.lock generation + locked fetch"
cargo generate-lockfile >/dev/null
if ! cargo fetch --locked >/dev/null 2>&1; then
    fail "cargo fetch --locked failed on the freshly generated root lockfile" \
        "resolution succeeds with the pinned libsignal rev" \
        "check crates/crypto/Cargo.toml rev, network, output"
fi
pass "root Cargo.lock generated and locked-fetch OK"

step_start "fuzz/Cargo.lock generation + locked fetch"
if ! ( cd fuzz && cargo generate-lockfile >/dev/null && cargo fetch --locked >/dev/null 2>&1 ); then
    fail "fuzz lockfile step failed" \
        "fuzz workspace resolves independently" \
        "run: cd fuzz && cargo generate-lockfile && cargo fetch --locked"
fi
pass "fuzz/Cargo.lock generated and locked-fetch OK"

step_start "cargo check --workspace --all-targets --locked"
if ! cargo check --workspace --all-targets --locked; then
    fail "cargo check failed" \
        "workspace compiles cleanly on the pinned toolchain" \
        "address the compiler errors shown above"
fi
pass "cargo check clean"

step_start "cargo fmt --all -- --check"
if ! cargo fmt --all -- --check; then
    fail "rustfmt found formatting issues" \
        "clean fmt output" \
        "run: cargo fmt --all"
fi
pass "fmt clean"

step_start "cargo clippy --workspace --all-targets --all-features -- -D warnings"
if ! cargo clippy --workspace --all-targets --all-features -- -D warnings; then
    fail "clippy reported warnings" \
        "no warnings with -D warnings" \
        "address lints shown above"
fi
pass "clippy clean"

step_start "cargo test --workspace --all-features --locked"
if ! cargo test --workspace --all-features --locked; then
    fail "cargo test failed" \
        "all workspace tests pass" \
        "address the failures shown above"
fi
pass "tests pass"

step_start "cargo deny check"
if ! cargo-deny check; then
    fail "cargo-deny reported an issue" \
        "advisories + licenses + bans + sources all pass" \
        "review deny.toml and the output above"
fi
pass "cargo deny clean"

step_start "libsignal-protocol is isolated inside myapp-crypto"
crypto_hits="$(cargo tree -p myapp-crypto --edges normal 2>/dev/null | grep -c 'libsignal' || true)"
core_hits="$(cargo tree -p myapp-core   --edges normal 2>/dev/null | grep -c 'libsignal' || true)"
client_hits="$(cargo tree -p myapp-client --edges normal 2>/dev/null | grep -c 'libsignal' || true)"
if [[ "${crypto_hits}" -lt 1 ]]; then
    fail "libsignal not reachable from myapp-crypto" \
        "≥ 1 'libsignal' line in: cargo tree -p myapp-crypto --edges normal" \
        "verify crates/crypto/Cargo.toml declares libsignal-protocol"
fi
if [[ "${core_hits}" -ne 0 ]]; then
    fail "libsignal leaked into myapp-core" \
        "0 'libsignal' lines in: cargo tree -p myapp-core --edges normal" \
        "core must not depend on libsignal"
fi
if [[ "${client_hits}" -lt 1 ]]; then
    fail "libsignal not reachable transitively through myapp-client" \
        "≥ 1 'libsignal' line in: cargo tree -p myapp-client --edges normal" \
        "verify myapp-client depends on myapp-crypto"
fi
pass "libsignal isolated (crypto=${crypto_hits}, core=${core_hits}, client=${client_hits})"

step_start "publish = false enforced on internal crates"
if cargo publish --dry-run -p myapp-canonical >/dev/null 2>&1; then
    fail "cargo publish --dry-run succeeded for an internal crate" \
        "non-zero exit (publish = false must be honored)" \
        "ensure 'publish.workspace = true' in crates/canonical/Cargo.toml"
fi
pass "publish = false enforced"

printf '\n[Phase 5.5] ====================================================\n'
printf '[Phase 5.5] ALL %d STEPS PASSED — Phase 5.5-A VALIDATED\n' "${TOTAL_STEPS}"
printf '[Phase 5.5] ====================================================\n'
printf '[Phase 5.5] Next: Phase 5.5-B (GitHub Actions CI validation).\n'
