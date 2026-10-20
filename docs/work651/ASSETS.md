# Work 6.5.1 UI assets

Six original code-native SVG production surfaces, authored for this project at 96×96 with 16px rounded corners and 20px nine-slice margins. No bitmap generation or third-party artwork used. Actual imported textures are referenced by the shared Godot Theme and NinePatchRect components.

| Stable role | File | Actual use |
|---|---|---|
| ui.panel | assets/ui/work651/panel.svg | Header, status, dialogs, cards, settings |
| ui.active | assets/ui/work651/hero.svg | Selected equipment and navigation |
| ui.boss_reward | assets/ui/work651/boss.svg | Boss HUD, reward/notification accent |
| ui.primary | assets/ui/work651/primary.svg | Selected world region and action material |
| ui.secondary | assets/ui/work651/secondary.svg | Save actions and secondary material |
| ui.slot | assets/ui/work651/slot.svg | Inventory item surfaces |

Paths are relative to `godot/realm_alliance/`. These replace live Work 6.3 material references; legacy assets remain in source for historical compatibility. Alias roles hero_ornate/boss_ornate now resolve to the new restrained surfaces rather than rendering the old ornate artwork.

Existing canonical hero, five weapon textures, equipment, skill-orb art, backgrounds and region map are reused unchanged. WorldMap uses separate AtlasTexture regions `(0,0,600,800)` and `(600,0,600,800)` from the actual Work 6.5 map. Dynamic labels, stars, unlock states and hit targets are native controls; nothing interactive is baked into that image. The hero pedestal is a native ellipse, not a body/equipment bitmap edit. Rare/epic item frames are native overlays using the shared palette.

No new hero design, enemy or gameplay item is introduced in this visual pass. The utility button now opens the existing real quest system instead of the old unavailable-mail placeholder.
