// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-transport
//!
//! Frame-oriented transport over `rustls` (TLS 1.3 only).

#![forbid(unsafe_code)]

/// Client-side connection driver.
pub mod client {
    // Phase 6.
}

/// Relay-side listener and per-connection driver.
pub mod server {
    // Phase 6.
}

/// Length-prefixed framing.
pub mod framing {
    // Phase 6.
}

/// TLS 1.3 configuration helpers.
pub mod tls {
    // Phase 6.
}

/// Pluggable transport errors.
pub mod error {
    // Phase 6.
}
