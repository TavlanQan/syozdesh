SÖZDEŞ — Dependencies
Status: Phase 5.5-A validation baseline
Scope: repository bootstrap and dependency/supply-chain controls only.
Phase 6 implementation work is intentionally excluded.
1. Purpose
This document records the dependency decisions that are already frozen for the bootstrap baseline, the concrete immutable revisions verified for security-critical Git dependencies, and the validation rules that must hold before Phase 5.5-A can be declared PASS.
This document is not a claim that the dependency set is secure in isolation. Security properties are established only by the corresponding architecture, protocol, implementation, and validation evidence.
2. Dependency policy
The project follows these rules:
1.Security-critical dependencies are explicitly identified and reviewed.
2.Critical Git dependencies use immutable commit SHAs, not floating branches or tags.
3.The root Cargo.lock is committed and participates in the bootstrap reproducibility/supply-chain baseline.
4.The independent fuzz/Cargo.lock is also a committed bootstrap artifact.
5.New dependencies are not added merely for implementation convenience; they require a documented architectural/dependency decision.
6.Dependency upgrades are deliberate changes. They are not performed implicitly by CI.
7.myapp-crypto is the only crate allowed to depend directly on libsignal-protocol.
8.myapp-core must not depend directly on libsignal-protocol.
9.Security failures remain fail-closed; dependency or API convenience must not introduce crypto downgrades.
10.Manifest version requirements and lockfile-resolved versions are distinct pieces of evidence and must not be conflated.
3. Internal dependency graph
The frozen normal-dependency graph is:
myapp-canonical
    └── no internal dependencies
myapp-protocol
    └── no internal dependencies
myapp-core
    ├── myapp-protocol
    └── myapp-canonical
myapp-crypto
    ├── myapp-core
    └── myapp-canonical
myapp-storage
    └── myapp-core
myapp-transport
    ├── myapp-core
    └── myapp-protocol
myapp-discovery
    ├── myapp-core
    └── myapp-protocol
myapp-media
    ├── myapp-core
    └── myapp-protocol
myapp-client
    ├── myapp-core
    ├── myapp-crypto
    ├── myapp-storage
    ├── myapp-transport
    ├── myapp-discovery
    ├── myapp-media
    ├── myapp-protocol
    └── myapp-canonical
myapp-relay
    ├── myapp-canonical
    ├── myapp-protocol
    ├── myapp-transport
    └── myapp-storage
myapp-cli
    └── myapp-client
myapp-desktop
    └── myapp-client
myapp-tools
    ├── myapp-canonical
    └── myapp-protocol
 
The graph is checked by scripts/check-deps.sh. The checker is intended to compare the actual normal internal dependency set against the frozen set, including detection of missing and unexpected edges.
4. Security-critical dependencies
The following dependencies are part of the frozen cryptographic foundation. They require deliberate review when changed.
DependencyBootstrap specificationRole
libsignal-protocolGit revision pinned belowSignal/PQXDH protocol engine; isolated in myapp-crypto
ed25519-dalek3, default-features = false, rand_coreEd25519 signing / verification
x25519-dalek3, default-features = false, static_secrets, zeroizeX25519 key agreement
hkdf0.13Domain-separated key derivation
sha20.11SHA-256 hashing / identifiers / transcripts
chacha20poly13050.11AEAD building block
argon20.6Password-derived recovery/backup key material
rand_core0.10Cryptographic randomness interface
 
Additional support dependencies such as zeroize and subtle are security-relevant, but are not substituted for the primary cryptographic protocol implementation.
5. Pinned libsignal-protocol
5.1 Immutable revision
Repository:
https://github.com/signalapp/libsignal
 
Pinned revision:
e8cc2dddd578859b4a029c9c94670b24ce2b616a
 
The actual dependency declaration is:
libsignal-protocol = {
    git = "https://github.com/signalapp/libsignal",
    rev = "e8cc2dddd578859b4a029c9c94670b24ce2b616a"
}
 
No floating branch (main or otherwise) and no invented/placeholder SHA are permitted for this dependency.
5.2 Dependency isolation
libsignal-protocol is isolated inside:
myapp-crypto
 
myapp-core must not take a direct dependency on libsignal-protocol. Higher layers use the project-owned crypto abstraction rather than exposing libsignal types through the core API.
The final Phase 5.5-A gate verifies this with cargo tree.
5.3 Compatibility evidence
An external compatibility probe was run outside the SÖZDEŞ repository against the exact revision above.
The probe passed the following runtime checks:
PASS 1: PreKeyBundle construction
PASS 2: invalid signed-pre-key signature rejected with SignatureValidationFailed
PASS 3: Alice PQ session established
PASS 4: SessionRecord serialization round-trip
PASS 5: PQXDH-derived session encrypted a PreKey message
PASS 6: legacy X3DH pre-key message rejected
PASS 7: tampered ciphertext rejected
PASS 8: valid ciphertext decrypted correctly
PASS 9: pre-key lifecycle matches expected behavior
PASS 10: Bob session has persistent PQ state
RESULT: COMPATIBILITY PROBE PASS
 
This evidence establishes compatibility of this exact revision with the required MVP integration scenario. It does not establish the complete security of SÖZDEŞ, the entire Signal protocol stack as integrated by the application, filesystem security, multi-device isolation, relay failover, group security, recovery security, or production deployment security.
In particular, the tampering check demonstrates rejection in the tested serialized-message/ciphertext path; it must not be restated as a mathematical proof about a particular Kyber ciphertext transformation.
5.4 PQXDH requirement
For MVP-0, PQXDH is mandatory.
The application must not silently downgrade to legacy X3DH when PQXDH is unavailable. An implementation path that cannot satisfy the required PQXDH capability is a STOP condition for the bootstrap/security decision; the architecture is not weakened to make the dependency easier to use.
The compatibility probe also confirmed that the tested legacy X3DH pre-key message path is rejected by the selected revision.
6. Resolved SparsePostQuantumRatchet revision
The selected libsignal-protocol revision resolves the SPQR dependency from:
https://github.com/signalapp/SparsePostQuantumRatchet.git
 
with:
 tag = v1.6.0
 
and the lockfile resolves that Git source to the immutable commit:
06959b4708f9b7b1e94d0f8cc835f3958c077e94
 
The root Cargo.lock contains the corresponding source entry. This is important because the Git dependency is not left at an abstract tag resolution: the lockfile records the resolved revision.
7. Workspace dependency baseline
The frozen workspace specification currently declares these external dependencies.
Async / runtime
 tokio              1.53   (workspace requirement)
 
Core
 thiserror           2.0
 bytes               1.12
 tracing             0.1.44
 tracing-subscriber  0.3.23  [env-filter]
 
Wire
 prost               0.14
 prost-types         0.14
 
prost-build is a build dependency of myapp-protocol and is intentionally distinct from the normal internal dependency graph checked by scripts/check-deps.sh.
Canonical representation
 ciborium            0.2.2
 
ciborium is only the encoder backend. Canonicality is defined by the project's protocol restrictions and by the project's own canonical decoder/validation rules; canonicality is not delegated blindly to the library.
Current frozen canonical restrictions include:
 deterministic CBOR subset
 fixed-order arrays
 maps forbidden for signing representation
 floats forbidden
 indefinite-length encodings forbidden
 explicit integer widths
 golden vectors
 
Storage
 rusqlite             0.38   [bundled]
 
The current baseline deliberately uses rusqlite 0.38 rather than 0.40 because the frozen MSRV is Rust 1.93.1 and the latter was identified as incompatible with that MSRV in the bootstrap design.
Transport
 rustls               0.23.34 [ring, std]
 tokio-rustls         0.26.5
 
TLS 1.2 is not enabled by the frozen rustls feature set; the bootstrap specification targets TLS 1.3 only.
Discovery
 hickory-resolver     0.26.3
 
Cryptography
 ed25519-dalek        3       [rand_core; default features off]
 x25519-dalek         3       [static_secrets, zeroize; default features off]
 hkdf                 0.13
 sha2                 0.11
 chacha20poly1305     0.11
 argon2               0.6
 rand_core            0.10
 zeroize              1.9
 subtle                2.6
 
Test support
 proptest              1.11
 tokio-test            0.4.5
 
The entries above record the manifest requirements. Exact transitive/resolved crate versions belong to Cargo.lock and must not be inferred from this table.
8. Rust toolchain and validation tooling
Bootstrap toolchain:
Rust toolchain: 1.98.1
 
Bootstrap dependency-audit tooling verified in the current environment:
cargo-deny: 0.20.2
 
The project previously had a Cargo alias named deny that recursively shadowed the external cargo-deny command. That alias is intentionally absent. Validation uses the external command directly:
cargo-deny check
 
Tool versions are controlled by scripts/tool-versions.sh; versions in that manifest are changed deliberately and must be revalidated after a bump.
9. Lockfile policy
Root workspace
The required procedure is:
cargo generate-lockfile
cargo fetch --locked
 
cargo generate-lockfile creates the lockfile.
cargo fetch --locked verifies that the existing lockfile can be used without modifying dependency resolution.
The current root lockfile has already been generated, and cargo fetch --locked has completed successfully.
Independent fuzz workspace
fuzz/ is excluded from the main workspace and has its own lockfile.
Required procedure:
cd fuzz
cargo generate-lockfile
cargo fetch --locked
cd ..
 
fuzz/Cargo.lock must be verified as an independent bootstrap artifact before Phase 5.5-A is declared PASS.
Critical Git source checks
For the bootstrap gate, the lockfile must contain the exact immutable revisions:
libsignal-protocol
  e8cc2dddd578859b4a029c9c94670b24ce2b616a
SparsePostQuantumRatchet / spqr
  06959b4708f9b7b1e94d0f8cc835f3958c077e94
 
10. Validation commands
Phase 5.5-A validates the dependency baseline using the following command families:
# lockfile / dependency resolution
cargo fetch --locked
# workspace structure and compilation
cargo check --workspace --all-targets --locked
# exact frozen internal graph
./scripts/check-deps.sh
# formatting / lints / tests
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features --locked
# dependency policy
cargo-deny check
# libsignal isolation
cargo tree -p myapp-crypto --edges normal | grep -i libsignal
cargo tree -p myapp-core   --edges normal | grep -i libsignal
cargo tree -p myapp-client --edges normal | grep -i libsignal
 
Expected isolation result:
myapp-crypto  → exactly one direct libsignal match
myapp-core    → zero libsignal matches
myapp-client  → libsignal only transitively through myapp-crypto
 
The exact tree output still belongs to the final Phase 5.5-A run; it must not be claimed here merely because the dependency declaration is correct.
11. Supply-chain restrictions
The following practices are not allowed for security-critical project dependencies:
floating Git branches
invented commit SHAs
placeholder SHAs at gate completion
unversioned CI tool installation when a pinned version is required
automatic dependency updates without deliberate review
direct libsignal dependency outside myapp-crypto
crypto downgrade/fallback introduced solely for dependency convenience
 
The project also avoids unnecessary external services in the architecture. In particular, Firebase/BaaS/cloud-provider services are not part of the mandatory messaging/relay design.
12. What this document does not claim
This document does not claim that:
·the complete application protocol is implemented;
·the complete Signal/PQXDH protocol integration has been implemented in myapp-crypto;
·forward secrecy or post-compromise security has been proven for the entire application;
·filesystem/at-rest security has been completed;
·multi-device security has been completed;
·groups are cryptographically complete;
·calls/media are production-ready;
·relay metadata privacy is solved;
·supply-chain risk is eliminated;
·the repository is production-deployable;
·the project has passed external security audit.
Those are separate implementation and validation matters.
13. Phase 5.5-A status
Verified before the final gate:
libsignal immutable revision selected             PASS
libsignal runtime compatibility probe             PASS
PQXDH required path exercised                     PASS
legacy X3DH path rejected in probe                PASS
root Cargo.lock generated                         PASS
root Cargo.lock contains libsignal SHA            PASS
root Cargo.lock contains SPQR resolved SHA         PASS
cargo fetch --locked                              PASS
cargo-deny version pinned/verified                PASS
 
Still required for the final Phase 5.5-A PASS:
fuzz/Cargo.lock actual presence/validation
full repository working-tree verification
tool-version manifest consistency check
final cargo check --workspace --all-targets --locked
final scripts/check-deps.sh
final cargo fmt --check
final cargo clippy
final cargo test
final cargo-deny check
final libsignal dependency-tree isolation checks
final bootstrap gate script execution
 
Phase 5.5-A is not declared PASS by this document alone. The gate is PASS only after the complete validation sequence succeeds on the actual checkout.
