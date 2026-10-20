# Work 6.5.1 — baseline audit and visual targets

Baseline: Work 6.5 verified runtime 8827f0e, documentation/source 5ff810a. Functional two-region RPG loop is retained. Remote branch: feature/work-6-5-1-master-ui. No edits to main or Game Factory.

References: supplied 01-199953, 02-194889, 03-194895, 04-194897, 05-194896. Canonical hero identity comes from 03 and existing assets; 04/05 alternate hero is a composition reference only.

| Area | Current gap | Work 6.5.1 target |
|---|---|---|
| Shared UI | Angular cyan compact frames mixed with ornate metallic hero/modal frames | One restrained rounded navy surface family, thin highlights, purple active and gold reward accents, reusable nine-slice assets |
| Combat | Enemy HUD to the right; excess empty sky; compact skill imagery | Central HUD, toast clear of name/HP, stronger arena composition and readable existing skills |
| Adventure | Short map thumbnail plus five full-width list buttons | Tall illustrated map, five real clickable stage nodes, real region selection and unlock states |
| Hero | Ornate boxed portrait, stat line on frame | Open canonical hero, readable stat strip, coherent slots and actual item/skill/evolution controls |
| Loot | Three-column text-heavy cards, only underline indicates rarity | Four-column clear icon-led rarity cards, real inventory/filter/compare/upgrade behaviours retained |
| More | Sparse text and separated controls | Profile card, real quest/achievement functions, grouped actual settings/save actions |
| Motion | Abrupt menu state changes | Bounded surface transition, reduced/off intensity respected; touch cannot leak into combat |
| Performance | Repeated preview rig updates and texture lookup every 0.1s | Update preview only when its appearance changes; cache texture handles; measure without promising device FPS |

Not in this pass: x2/x4, new heroes/pets, paid shops, dungeons, events or online systems. Their roadmap is binding but implementation follows this visual gate. No save-schema change planned. Physical Android validation remains separate from CI export.
