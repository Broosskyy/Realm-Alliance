# REALM ALLIANCE — Godot Combat Foundation 01

Isolated **Godot 4.6 GDScript** vertical slice. The existing React/Vite web prototype in the repository root stays untouched. No existing save is migrated, overwritten or reset.

## Goal

Prove that a native Godot scene can drive fixed-stage portrait Tap/Auto combat, wave rewards, persistence and a **truly attached, swappable weapon**. This is an original, minimal prototype; it does **not** include or claim to be a port of Lost Ramko, and it does not yet match the approved production mockups.

## Import / run

Open the folder `godot/realm_alliance` (not the repository root) in **Godot 4.6 Standard** and press F5. Requires no downloaded assets, paid tools, C# or third-party plugins.

- TAP / tap the arena: player attack with short impact delay.
- AUTO toggle: periodic auto-attacks.
- SKILL: strong attack with cooldown.
- WEAPON: switch between 3 separately drawn swords mounted to the hand socket; stats change.
- UPGRADE: spend earned gold for permanent base power.
- Save on progress and normal application exit under `user://realm_alliance_combat_v1.json`.

This is **not a multiplayer system**. Browser storage is not authoritative and must not be used for competitive currencies or server rewards.

## Automated model tests (requires Godot installed)

```bash
godot --headless --path godot/realm_alliance --script res://tests/test_combat.gd
```

The test covers one-time reward, wave progression, upgrades, weapon cycle and save shape. Run it before any engine integrations.

## Web

Use **Compatibility** renderer and a default *single-threaded* Godot 4.6 Web export. Create a Web export preset in Project > Export, install matching export templates and export to `dist/web/index.html`; serve the files over HTTP(S), not `file://`. Check Android Chrome, tap input, sound unlock, frame pacing, saves, viewport and reload. Exported Web artifacts should not be committed.

## Android

In Project > Export, install the Android build templates. Set the Android SDK and JDK paths and create an Android debug preset. Use the portrait project setting. Export an APK and verify physical-device touch input and save/reload. Native APKs and web deployments have not been built in this environment.

## Production boundaries

- Current visuals are *geometry-only temporary placeholders* used to verify independent hero/equipment transforms.
- Replace visual parts with clean transparent production sprites **after** sockets, z-order and pose timing are stable.
- Respect the approved REALM ALLIANCE five-screen masters: Kampf, Abenteuer, Wesen, Beute, Mehr.
- Do not clone Lost Ramko's assets directly; its code and bundled assets have distinct terms. See `REFERENCE_AUDIT.md`.
- Online-ready domains and any eventual save migration are separate steps, not implied by this POC.

## Structure

```text
scenes/main.tscn           Godot root scene
scripts/combat_model.gd    Gameplay rules, no rendering
scripts/hero_rig.gd        Body/armor/hand pivot and attached weapon
scripts/enemy_visual.gd    Reusable presentation-only enemy
scripts/stage_art.gd       Temporary fixed arena environment
scripts/save_store.gd      Versioned local save
scripts/main.gd            UI, combat timing, state orchestration
tests/test_combat.gd       Model regression smoke tests
```
