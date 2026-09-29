// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-relay
//!
//! Relay server binary. Separate composition root — MUST NOT depend on
//! `myapp-client`. Holds NO E2E keys, sees NO plaintext.

#![forbid(unsafe_code)]

fn main() {
    // Phase 6: parse config, init tracing, bind rustls listener.
    eprintln!("myapp-relay: Phase 5 bootstrap stub — no runtime yet.");
}
