// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-storage
//!
//! SQLite-backed encrypted record storage.

#![forbid(unsafe_code)]

/// Connection pool / transaction helpers.
pub mod connection {
    // Phase 6.
}

/// Master key management (wrapped by `SecureKeyStore`).
pub mod master_key {
    // Phase 6.
}

/// Schema migrations (persistence schema ≠ wire schema, Invariant #8).
pub mod schema {
    // Phase 6.
}

/// Domain-separated subkey derivation.
pub mod subkeys {
    // Phase 6.
}

/// Record-level AEAD with AAD binding.
pub mod record {
    // Phase 6.
}

/// Outbound queue persistence.
pub mod outbound_queue {
    // Phase 6.
}
