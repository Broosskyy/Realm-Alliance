# V1.59 — Canonical Asset Integration

- Bound 14 normal Greenvale production monsters and 3 rotating production bosses.
- Enforced four-state monster contract: Idle / Attack / Hit / Defeat.
- Boss special/shield visual resolves to authored Attack pose instead of requiring a fifth sprite.
- Replaced abstract P0 village building art with V4 production buildings.
- Added level-sensitive scale/tint treatment until dedicated tier art exists.
- Collapsed secondary persistent quick-actions behind one MODI button per Master V2.1.
- Hid redundant legacy TapPrompt and progress-image overlays on TAP.
- Added canonical asset catalog and exact duplicate audit.
- Preserved all source systems and fallback paths.
- Visual QA caught a previous monster-state crop defect (multiple poses in one PNG); all bound runtime monster states were re-cropped directly from original transparent 2×2 sheets.
