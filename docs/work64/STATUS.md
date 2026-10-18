# Work 6.4 — implementation complete, final export/browser gates pending

Candidate runtime: 0.6.4 / Android code 641. This is not yet the final milestone acceptance report. Work 6.3 and the previous 6.4 armor preview remain available as immutable CI artifacts. Main and Game Factory untouched.

## Implemented
- Two real armor variants, a separate sentinel headband and a separate wing pair. Canonical body, white hair, black mask, original cape, all five separate swords and six canonical poses retained.
- Four production alpha cutouts, catalogued hashes, source provenance and normalized pivots. Correct alpha compositing confirms clean transparent backgrounds, including headband interior and feather gaps. Hidden RGB in fully transparent source pixels has no visible effect.
- Pose-local armor/foreground-arm rig, diadem forehead pivot and wing clasp pivot. Wings render behind the body; headpiece and hand remain correctly layered. Separate prepared slots for shoulder/back/wings/accessories; only four backed items are exposed.
- Real acquire/equip/unequip/upgrade dialogs, exact saved gold/shard costs, XP level gates and numerical comparison with current gear. Cosmetic overrides are separate from gameplay stats.
- Third functional cape palette (Astral); first actual awakened evolution unlock. +20 HP/+5 attack are permanent progression bonuses; active form is cosmetic and switches a separate golden seal layer. Reduced/off effects reach both hero instances.
- Character page: central hero, active equipment, real HP/attack/defense/power, five compact sword selectors, four native skill-information controls using actual definitions, and an XP/progression panel when tall-screen space allows.
- Existing V1/V2 save envelopes remain supported with additive versioned gear/evolution domains. Invalid/future domains preserve their data and block automatic writeback.

## Validation to date
625/625 deterministic checks across 13 suites. Includes XP/resource gates, no duplicate spend, no swap healing, real mitigation, form invariance, native purchases, attachment pivots, six poses in combat and preview, and mobile touch targets in 360×800, 720×1280, 720×1560, 1280×720. Actual Godot 4.7.2 Compatibility captures use an isolated seeded level-8 equipment fixture. Combat capture uses real model-timed skill damage.

Final CI Web/APK exports, exported-browser playthrough, rapid save/reload, performance telemetry and downloadable QA bundle are pending. No physical Android-device test or 60 FPS guarantee claimed.

Work 6.5 world/inventory/quest/content expansion is next; it is not implemented here.
