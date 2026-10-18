# Work 6.4 — in progress

This is an implementation checkpoint, not milestone acceptance. Work 6.3 remains the last fully verified deliverable.

- Original master images recovered and visually reviewed: combat identity stays the white-haired masked Realmwächter; multi-page master is a layout reference.
- Two isolated armor production cutouts authored with built-in image generation, true alpha and deterministic crop/scale normalization. Manifest under assets/equipment/.
- Optional versioned hero_equipment profile domain, stable item IDs, acquisition costs/unlocks, compatible equip/unequip, upgrades, separate cosmetic overrides and actual HP/defense rules.
- 23 deterministic new model checks pass, including V1/V2 compatibility, health preservation, no swap-heal exploit, incoming damage reduction and future-domain write protection.
- Remaining: head/back assets, per-pose attachment rig, real UI interactions, full regression/render/browser/save/CI gates. No 6.4 completion or Android-device test claimed.
