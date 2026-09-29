<!-- SPDX-License-Identifier: AGPL-3.0-only -->
# Phase 5.5-A — Local Bootstrap Validation

> **Status:** runbook. Execute after Phase 5 bootstrap.
> **Gate:** all 17 steps of `scripts/phase5_5.sh` pass.

## §1 Prerequisites (mandatory)

| Tool         | Minimum   | How to install                                 |
|--------------|-----------|------------------------------------------------|
| git          | 2.40      | distro package                                 |
| rustup       | 1.27      | https://rustup.rs                              |
| bash         | 5.2       | distro package                                 |
| jq           | 1.7       | distro package                                 |
| cargo-deny   | see §3    | cargo install --locked cargo-deny@<ver> (§3)   |

    git --version && rustup --version && bash --version | head -n1 && jq --version

## §2 Rust toolchain

`rust-toolchain.toml` pins `1.98.1`. Activate:

    rustup show

## §3 Tool-version pinning + cargo-deny install (mandatory)

### §3.1 Fill in scripts/tool-versions.sh

    CARGO_DENY_VERSION   — current stable from https://crates.io/crates/cargo-deny
    CARGO_DENY_DATE      — today, YYYY-MM-DD

### §3.2 Install cargo-deny at that exact version

    source scripts/tool-versions.sh
    cargo install --locked "cargo-deny@${CARGO_DENY_VERSION}"
    cargo deny --version

## §4 libsignal revision selection

Manual step. Follow the two-stage inspection procedure with the
working AI assistant. Do not guess SHAs.

### §4.1 Obtain candidate SHA and inspection report

    rm -rf /tmp/libsignal-inspect
    git clone --filter=blob:none --no-checkout \
        https://github.com/signalapp/libsignal /tmp/libsignal-inspect
    cd /tmp/libsignal-inspect
    SHA=$(git ls-remote https://github.com/signalapp/libsignal refs/heads/main | awk '{print $1}')
    git checkout "${SHA}"
    echo "SHA=${SHA}"

Send the SHA and the workspace layout (`ls rust/protocol/src/`) to the
assistant for analysis.

### §4.2 Compatibility probe

The assistant drafts a probe at `/tmp/libsignal-probe/` against the
actual public API of the chosen revision. Run `cargo check` there.
Paste the result back.

### §4.3 Pin the SHA

Edit `crates/crypto/Cargo.toml`:

    libsignal-protocol = {
        git = "https://github.com/signalapp/libsignal",
        rev = "<40-hex SHA>"
    }

Remove the `# BLOCKING(Phase 5.5-A):` comment above it.

### §4.4 Record evidence

Add a capability table to `docs/DEPENDENCIES.md` (see runbook draft).

## §5 LICENSE

Replace the placeholder body of `LICENSE` with the full AGPL-3.0-only
text from https://www.gnu.org/licenses/agpl-3.0.txt.

## §6 Run the gate

    ./scripts/phase5_5.sh

Expected tail:

    [Phase 5.5] ALL 17 STEPS PASSED — Phase 5.5-A VALIDATED

Commit the artifacts produced by 5.5-A:

    crates/crypto/Cargo.toml       (real rev)
    Cargo.lock                     (generated)
    fuzz/Cargo.lock                (generated)
    scripts/tool-versions.sh       (real versions)
    LICENSE                        (full text)
    docs/DEPENDENCIES.md           (evidence table)

## §7 If a step fails

Do NOT edit frozen ADRs, invariants, or architecture to make a check
pass. Each failure is environment, a manual prerequisite not yet done,
or a real bootstrap issue. Fix only the second kind.

## §8 Next

After 5.5-A PASS, proceed to Phase 5.5-B (Forgejo CI validation).
