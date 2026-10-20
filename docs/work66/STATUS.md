# Work 6.6 verification checkpoint — 2026-10-18

Runtime source: `c7f655836779a01276bdc990c815ba7078344ba4` on `feature/work-6-6-tap-combat`.
CI: https://github.com/Broosskyy/Realm-Alliance/actions/runs/39149460669 — successful; 1,024 checks in 18 suites, followed by Web and Android debug exports. Artifact bytes/hashes below refer to those exact exports. Documentation commits after this runtime do not modify the builds.

## Actual runtime evidence

- Final CI Web ZIP extracted unchanged and served locally in Chromium 155.0.8059.84 / SwiftShader with mobile touch enabled.
- Three immediate legacy import/reload cycles preserve gold and weapon upgrades. Then an explicit zero-gold starter save is imported; subsequent currency, XP and inventory are genuinely earned.
- Three complete five-encounter runs: Wolkgarten, Glutkern, Wolkgarten. 15 actual kills and both region boss victories, no seeded XP or purchase funds after the starter import.
- Real x2 unlock/selection, charged ultimate impact during AUTO, actual x4 unlock/selection at XP 606+, purchased/equipped sky wings, steel level 2, vitality talent, Himmelsklinge rank 2, one opened chest consumed once, first-five quest claimed once.
- Explicit AUTO policy enabled with only Arkanblick selected; third run contains no manual Arkanblick press and its actual cooldown proves AUTO used it. Reload preserves world, inventory, chest, quest and combat settings.
- All five main pages rendered in the final export at 360×800, 720×1280, 720×1560 and 1280×720; zero captured GDScript/browser errors.
- 48 native Godot 4.7.2 / X11 Mesa captures: 12 full views, 30 canonical pose/sword combinations and six action/option states. These use a clearly labelled equipment/XP fixture; the independent browser flow above proves earning.

## Performance and limits

Hosted software-rendered Web AUTO sample: 198 frame intervals over 10 seconds; median 50.0 ms, p95 66.7 ms, 49 intervals above 50 ms. This environment does **not** meet 60 FPS. This is a reproducible software-renderer measurement, not a physical Android result. Target-device performance and visual sign-off remain open. No Android device/video test claimed; debug APK export succeeded.

6.6 is a tested implementation checkpoint, not a declaration that 6.7–7.0 or multiplayer are complete. Those remain separate gates.

## Build files

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| REALM_ALLIANCE_Work_6_6.apk | 45517458 | `9a6bfb891b812bb367558564221786b416b05c34ca1039a6a670c6b3ab32dce7` |
| REALM_ALLIANCE_Work_6_6_Web.zip | 27361088 | `ad9852b96275c70b4e7184a9f7dd6ffd88e44fedbc7af31c81e4cef93730bae1` |
| REALM_ALLIANCE_Work_6_6_Android.zip | 45219110 | `3cdc214a7a483dba4a9835ebcfbe3474a7bd981eec15a17cc1a23f9c47ff190b` |
