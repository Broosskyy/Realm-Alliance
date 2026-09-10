# V1.59 — Asset Decisions After Visual Inspection

## Production-bound now
- Monsters: 14 normal + 3 bosses; all four authored states copied into runtime state paths.
- Village: Townhall, Forge and Luck Temple are high-confidence semantic matches.
- Village Goldmine: existing storehouse/economy building is used temporarily with MEDIUM confidence because the dedicated gold-mine silhouette is still missing.
- UI: V4 standalone set and 15 production atlases remain canonical. No further generic Panel/Button/Bar kits should be generated.

## Deliberately not auto-deleted
There are no exact duplicate PNG files inside the 219 canonical V4 UI textures. Similar-looking frames are retained because they differ in proportions/state/detail and can be useful in different screens. Automatic perceptual deletion would be destructive.

## Still needs NEW art only after runtime QA
1. Dedicated Goldmine building art / visible tier evolution if the temporary economy building reads incorrectly.
2. Hero portraits: Knight, Archer, Mage.
3. Lane Battle: Greenvale lane map + Knight + Archer units.
4. Tower Defense: Greenvale TD map + Archer Tower + Mage Tower + Runner enemy.
5. Entry branding: Splash background + Welcome background + final Realm emblem.
6. Village ambient tree/vegetation cluster.

Everything else should first be solved with the current production library and Godot composition.

## Important crop correction found during V1.59 visual QA
The V4 processed monster state files were not safe to bind blindly: at least one previous `idle.png` contained two poses from the source sheet. V1.59 therefore does **not** reuse those processed monster-state crops. All runtime monster states were rebuilt directly from the 19 original transparent 2×2 source sheets using fixed quadrant extraction (Idle top-left, Attack top-right, Hit bottom-left, Defeat bottom-right), alpha trim and transparent safety padding. The runtime now uses these corrected crops.
