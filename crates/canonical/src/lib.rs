// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-canonical
//!
//! Deterministic CBOR canonical encoding for signed structures (ADR-013).
//! `ciborium` is the encoder backend; canonicality is enforced by our
//! restricted format (fixed-order arrays, no floats, explicit widths,
//! no indefinite-length items) plus a decoder that rejects non-canonical
//! input (Invariant #10).

#![forbid(unsafe_code)]

/// Canonical CBOR encoder (RFC 8949 §4.2.1 restricted subset).
pub mod encoder {
    // Phase 6.
}

/// Canonical CBOR decoder with strict bounded parsing.
pub mod decoder {
    // Phase 6.
}

/// `SigningInput { domain, version, fields }`.
pub mod signing_input {
    // Phase 6.
}

/// Golden test vectors.
pub mod golden {
    // Phase 6.
}
