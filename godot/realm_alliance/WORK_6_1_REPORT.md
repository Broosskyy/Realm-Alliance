# REALM ALLIANCE — Work 6.1

Combat presentation convergence on the existing Godot 4.7.2 foundation.

## Delivered

- Native portrait-first HUD: canonical portrait, kill-derived level/XP, real gold, reserved currency slots, utilities, Wolkgarten stage nodes and boss marker.
- Central Golem HUD with rank, level, exact HP and three themed trait glyphs. The old floating debug bar is hidden for production art.
- Transient victory/reward notices. No fabricated bonus multipliers or critical hits.
- One connected HP/Momentum/Rage strip, four illustrated skill slots and a separate AUTO toggle. New transparent skill art and twenty original scalable SVG glyphs are committed under `assets/ui/work61/`.
- Existing 2.8× skill retained; two small local skill actions use Momentum/Rage earned on valid hits. Cooldowns and costs are independent. AUTO still activates only standard attacks.
- Permanent five-tab navigation. Adventure, loot and more are explicitly limited shells. Wesen retains working independent weapon switching and real-gold upgrades.
- Canonical hero body, replaceable sword, four-state Golem and Wolkgarten plate retained. Idle sword angle corrected. Figures grow on tall phones; enemy outer silhouette may crop intentionally at the right edge, while the face and the hero remain visible.
- Android package identity retained, display name cleaned up, version `0.6.1` / code `61`. Web is explicitly single-threaded.

## Validation

Godot 4.7.2 imports and runs the real scene. Existing model/layout/visual/fallback/production tests pass (20 + 32 + 11 + 46 + 22 checks). The new native UI suite adds 65 checks for navigation, combat gating, weapon changes, upgrade spending, skill costs/cooldowns and responsive touch regions.

The actual `main.tscn` was rendered through Godot's OpenGL Compatibility renderer at 720×1280, 720×1560, 360×800 and 1280×720, plus the four shell pages. This is desktop software-rendered verification, not physical Android device testing. CI runs the regression suite before exporting Web and the ARM64 debug APK.

## Deliberately open

- HP remains a full 100/100 presentation slot: the inherited foundation has no incoming-damage/survival system. This pass does not imply that enemy attacks or player death are implemented.
- Level and XP summarize existing kill progress (10 kills per displayed level); they do not add a new stat progression or migration.
- Premium/shard balances are unavailable and shown as em dashes. No wallet, purchases, backend, multiplayer or item inventory was added.
- Trait icons describe the Golem's theme; combat resistances/status-effect rules are not implemented.
- Fourth skill, other regions, quests, events, mailbox and settings remain marked as unavailable. The locked slot has no invented unlock requirement.
- Local saves and the previous reward/weapon/upgrade rules are retained. Momentum/Rage are encounter-session state.
- The supplied canonical ZIP remains the source for production art. CI reconstructs `assets/production/`; the imported directory is not duplicated in Git.

## Build / review

Use the existing `.github/workflows/godot-combat-foundation.yml`. It creates the Web and Android artifacts from the exact pushed commit. For local editing, extract the canonical ZIP's `godot/realm_alliance/assets/production/` subtree into this project, then import with Godot 4.7.2.

The UI asset manifest records generation provenance and SHA-256 hashes. Skill orbs were generated with built-in image generation, sliced with transparent alpha retained, and packed into separate 280px runtime canvases. UI panels/bars/cooldown masks are native Godot drawing, keeping values and fill amounts dynamic. Fonts are subset DejaVu Sans with the license included.
