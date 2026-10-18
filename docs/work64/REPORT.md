# Work 6.4 — verified milestone C

Runtime commit: `28b13499d1e37660a21913bf86541102922b6170`. Godot 4.7.2; preview 0.6.4 / Android code 641. Main and Game Factory untouched. Development branch: feature/work-6-2-1-full-game-experience.

## Delivered behavior
Two real armor variants (Astral and Eclipse), a separate sentinel circlet, separate sky wings, an Astral cape palette and the first awakened evolution. Acquire, equip, unequip and upgrade use actual saved gold/shards and XP gates. Character controls compare numerical HP/defense, show current equipment, attack and power, and expose real skill descriptions. Evolution unlock costs 150 gold/8 shards at level 5; its earned +20 HP/+5 attack stay when the cosmetic form is toggled. Cosmetic overrides remain distinct from stats; swaps preserve missing HP and never revive a defeated hero.

Four alpha production cutouts are documented in assets/equipment/manifest.json. The existing canonical white-haired masked body, cape and all five separate swords are retained. Pose-local chest, head and wing pivots work in the shared combat/preview rig. Foreground arm keeps the armor behind the hand; weapons retain world foreground layers. Wings sit behind the body; headpiece clears eyes. Existing shoulder/back/accessory sockets remain prepared rather than exposed as fake items. Golden awakened seal is a separate effect layer, respecting full/reduced/off settings.

A single 1-second manual intent buffer fixes missed skill taps during AUTO recovery. It stores only an explicitly requested skill, revalidates availability, and spends resources/starts cooldown only on actual session acceptance. Navigation, encounters, expiry and defeat cancel pending intent. AUTO continues to request basic attacks only.

Old V1/V2 saves use additive versioned equipment/evolution domains. Future or invalid domains are retained and block automatic writeback; existing journal/backup/import/export support is preserved.

## Acceptance evidence
- 645/645 deterministic checks in 14 suites, all passed in CI, plus actual main-scene import/start.
- CI run 39125590504: Web and ARM64 Android debug exports succeeded. Development package/key unchanged, preserving the preview save boundary.
- Actual native Godot Compatibility captures at 360×800, 720×1280, 720×1560 and 1280×720; both armor variants across all six poses, equipped skill combat and native evolution/upgrade dialogs. Seeded level-8 fixture is used for equipment pose captures, not presented as naturally earned loot. Screenshots under screenshots/final are actual renders, WebP-compressed for review.
- Exported Chromium 155 touch playthrough: fresh five-encounter run through boss victory; real drops unlock all five swords; weapon/look changes; three V1 imports and immediate reloads retain exact currency/weapon level.
- Separate explicitly seeded old-V2 compatibility fixture imported through the public UI: four actual purchases debit exact currency, evolution unlock/toggle preserves earned stats, head unequip/re-equip changes HP correctly, all saved state survives reload. No page/GDScript errors. Desktop landscape input also checked.
- Active equipped AUTO fight on hosted Linux SwiftShader: 209 browser rAF samples in 10.0042s, median 50ms, p95 66.8ms. Simulation advanced ~9.98s and real kills progressed. Three different manually requested skills were accepted while AUTO ran. This is browser rAF telemetry on a software renderer, not certified Godot FPS or physical Android performance. 60 FPS target is not established here.
- Physical Android-device/video QA remains open; APK was exported, not tested on a handset.

## Downloads
- [CI/checks](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39125590504)
- [Android archive containing APK](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39125590504/artifacts/12136525036)
- [Playable Web export ZIP](https://github.com/Broosskyy/Realm-Alliance/actions/runs/39125590504/artifacts/12135823139)
- [Exact runtime source](https://github.com/Broosskyy/Realm-Alliance/archive/28b13499d1e37660a21913bf86541102922b6170.zip)

GitHub artifact downloads require sign-in and expire 2027-01-16. Web export needs an HTTP server; opening index.html directly from a ZIP/file URL is not a hosted game.

## Explicit remaining work
Work 6.5 world-stage selection, expanded inventory, real quests/achievements, skill/talent progression and second-region content are next. No shop, online economy, dailies or multiplayer authority is simulated. Additional armor pose sets and the final Android visual/performance review remain later quality work.
