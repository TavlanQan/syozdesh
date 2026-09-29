// SPDX-License-Identifier: AGPL-3.0-only

//! # myapp-client
//!
//! Client composition root.

#![forbid(unsafe_code)]

/// Client runtime: task supervision, relay connection lifecycle.
pub mod runtime {
    // Phase 6.
}

/// Send path.
pub mod send {
    // Phase 6.
}

/// Receive path.
pub mod receive {
    // Phase 6.
}

/// Session establishment (PQXDH) orchestration.
pub mod session_setup {
    // Phase 6.
}

/// Group state machine driver.
pub mod groups {
    // Phase 6.
}

/// Recovery orchestration.
pub mod recovery {
    // Phase 6.
}
