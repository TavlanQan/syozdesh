// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-desktop (Tauri 2)
//!
//! Linux desktop application.

#![forbid(unsafe_code)]

/// Tauri command surface.
pub mod commands {
    // Phase 6.
}

/// Application entry point.
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    // Phase 6: tauri::Builder::default()...run(...)
}
