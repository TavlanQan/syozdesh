// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-protocol
//!
//! Wire-protocol types and framing. Owns `EnvelopeV1`, framing,
//! `ProtocolVersion`, `PaddingPolicy`, and the application `Message`.
//! Has NO internal myapp dependencies (leaf crate).

#![forbid(unsafe_code)]

/// Framing: `length | frame_kind | protocol_version | payload`.
pub mod framing {
    // Phase 6.
}

/// Envelope wire type.
pub mod envelope {
    // Phase 6.
}

/// Application `Message` type (inside `E2EPayload.ciphertext`).
pub mod message {
    // Phase 6.
}

/// Protocol version and downgrade rejection (Invariant #10).
pub mod version {
    // Phase 6.
}

/// ACK types (relay send ACK, recipient transport ACK, delivery receipt).
pub mod ack {
    // Phase 6.
}

/// `PaddingPolicy` variants: `None | Bucketed | Fixed`.
pub mod padding {
    // Phase 6.
}

/// Relay-side and E2E-related errors.
pub mod error {
    // Phase 6.
}
