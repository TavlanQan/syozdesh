// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-core
//!
//! Trait definitions for composition roots. `core` MUST NOT depend on
//! any adapter crate.

#![forbid(unsafe_code)]

/// Cryptographic provider trait.
pub mod crypto_provider {
    // Phase 6.
}

/// Persistent storage trait (record-level AEAD).
pub mod storage {
    // Phase 6.
}

/// Frame transport trait.
pub mod transport {
    // Phase 6.
}

/// Relay discovery trait (seeds → DNS SRV → cache).
pub mod discovery {
    // Phase 6.
}

/// Media routing trait (MVP-0: types only).
pub mod media_router {
    // Phase 6.
}

/// OS-backed secure key store (libsecret / Android Keystore).
pub mod secure_key_store {
    // Phase 6.
}

/// Time and randomness sources (injectable for tests).
pub mod clock {
    // Phase 6.
}
pub mod rng {
    // Phase 6.
}

/// Identifier newtypes (`AccountId`, `DeviceId`, `SessionId`, `GroupId`).
pub mod ids {
    // Phase 6.
}
