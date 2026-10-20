# Work 6.7 — implementation and CI passed; device/playtest approval pending

The interrupted draft was lost in the environment restart. It has now been reconstructed on the verified Work 6.6 source. The 24 true-alpha hero/companion assets, normalization manifest and exact imagegen prompts are secured separately in commit 76ea5f223fdf17b6d251a9923962dc353931d985.

Implemented: owned hero roster with independent training after first collection unlock; canonical guardian retained; Kaela rune tank, true block healing and class skill definitions; two companions with model-clock windup/cooldowns and separate actor/action IDs; actual damage or bounded healing; combat XP and paid evolution with distinct art; per-pose modular weapon/equipment sockets; interactive collection and confirmation before a new run. Switching never heals a running boss encounter; it begins the region again. Account XP, existing saves, inventory and appearance domains remain compatible.

Local gates: 1,024 existing checks plus 84 new roster/companion checks. Dedicated tests cover real costs and duplicate rejection, individual XP, class stats, block-only heal, deterministic partial pet action JSON reload, no resource/charge farming, death/transition cancellation, evolved effectiveness/art, unknown-schema read-only protection, pose/sword layer checks and four touch viewports.

Visual scene review, physical Android testing, and end-to-end exported-browser progression remain pending. Web/Android export and automated tests now pass; this is not yet a visually accepted 6.7 release. 6.8–7.0 and online systems are not claimed complete. Main and Game Factory remain untouched.

## Continuation QA — 2026-10-18

- Source under test: `75f40703ce23c724e2976ee7b495cedf50be8c0f` (test-only extension after the last gameplay fix `9456883b59163f8e34a0dc4e0e8c13bdc7827205`).
- [GitHub Actions run 39161548610](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39161548610): **success**. Roster/Pets tests: **91/91**, including six extra JSON save/reload assertions for Kaela, equipped companions, evolved-pet effectiveness, inventory currencies and no duplicate evolution costs. Previous regression suites, headless scene smoke, Web export and Android debug export all passed.
- CI artifacts: `realm-alliance-work67-web` and `realm-alliance-work67-android`; both ZIPs and the extracted Android APK passed archive-integrity checks. The actual 6.7 APK is therefore buildable, but this does **not** establish device visual quality or runtime performance.
- Browser testing here was attempted on the exported Web artifact but the local Chromium environment blocked local and intercepted origins (`ERR_BLOCKED_BY_ADMINISTRATOR`). Therefore **no browser playthrough is claimed** for the continuation QA.
- Manual acceptance still required: fresh-save run to boss; real-gold purchase and equipping of Himmelsfuchs; combat XP and evolution; unlock and select Kaela after completing prerequisites; 5 separate swords / 6 Kaela poses with wings and pet visually present; app quit/relaunch and save preservation; Android touch targets and FPS/overdraw on-device.
- Main and Game Factory unchanged; no merge. Work 6.8 should follow only after this acceptance gate or with explicit risk acknowledgement.
