// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-crypto
//!
//! Cryptographic primitives and providers.

#![forbid(unsafe_code)]

/// Identity hierarchy: Account, Authority, Device keys.
pub mod identity {
    // Phase 6.
}

/// Device certificate issuance/verification.
pub mod device_cert {
    // Phase 6.
}

/// HKDF-based domain-separated subkeys.
pub mod kdf {
    // Phase 6.
}

/// AEAD wrapper (ChaCha20-Poly1305).
pub mod aead {
    // Phase 6.
}

/// PQXDH session establishment (mandatory; no X3DH fallback).
pub mod session {
    // Phase 6.
}

/// Recovery Capsule.
pub mod recovery {
    // Phase 6.
}

/// Safety number computation (60 digits).
pub mod safety_number {
    // Phase 6.
}
