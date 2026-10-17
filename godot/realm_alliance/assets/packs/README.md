# REALM ALLIANCE — Canonical production art pack

## Current uploaded integration ZIP (17 October 2026)

The canonical integration bundle is **already committed** to this feature branch at
`godot/realm_alliance/REALM_ALLIANCE_CANONICAL_GODOT_INTEGRATION_AND_WEB_PREVIEW.zip`.
Its Git blob is `90e54c9b19bead6540c6f79630a5a7cee173d145`.

The workflow now recognizes this exact filename and extracts only the 16 production
PNGs from `godot/realm_alliance/assets/production/{hero,weapons,enemy,world}/...`
inside the archive into Godot's `res://assets/production/`. The bundled offline
HTML demo and preview screenshot stay out of the Godot runtime import.

After extraction, the workflow requires all 16 production files and runs the
production art/socket tests before Web/Android exports. A green workflow and an
actual on-device check are still required before visual approval. **Do not merge
this draft solely because the ZIP upload or Vercel preview succeeded.**

## Alternative compact pack format (still supported)

The source-backed Godot 4.7.2 project uses a **single, optional ZIP bundle** to avoid manually uploading 16 PNG files.

Upload the file **`realm_canonical_batch_v2.zip`** (8.7 MB, SHA-256 `d1a96e6c9fa984947e4210f0f131fcadee5779280d858acd58ecfc9f94dde547`) **into this exact directory** on the branch `feature/godot-combat-foundation-01`.

GitHub Actions unpacks it automatically into `res://assets/production/` **before** the Godot project imports resources. The main scene then switches to the canonical **white-haired masked hero, separately equipped sword, stone Golem and Wolkgarten background**.

### Bundle layout
```
realm_canonical_batch_v2.zip
├── hero/idle.png, ready.png, windup.png, attack_contact.png, recovery.png, hit.png
├── weapons/steel.png, crystal.png, ember.png, rune_gold.png, shadow_violet.png
├── enemy/golem_idle_ready.png, golem_attack.png, golem_hit_damage.png, golem_defeated.png
└── world/wolkgarten_battle_plate.png
```

The ZIP must have these paths **at its root**, not wrapped in an extra folder.

### Upload via GitHub web
1. Open this folder in the **feature** branch.
2. Click **Add file → Upload files**, choose `realm_canonical_batch_v2.zip`.
3. Commit **to `feature/godot-combat-foundation-01`**, not to `main`.
4. After the workflow is green, download `realm-alliance-godot-android-poc` from the latest run's Artifacts.

Until the ZIP is committed, the existing Bramble preview remains the safe default. The code and tests can be checked in GitHub without silently shipping missing art. This is an integration **prototype**, not a complete recreation of the master UI. The hand socket still needs on-device visual QA.
