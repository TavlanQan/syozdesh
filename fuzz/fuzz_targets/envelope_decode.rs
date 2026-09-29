// SPDX-License-Identifier: AGPL-3.0-only
#![no_main]

use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    // Phase 6: myapp_protocol::envelope::decode_bounded(data).
    let _ = data;
});
