# Work 6.6 production/presentation changes

No generated raster replacement of the canonical hero, sword, armor, wing or enemy art. Existing genuine-alpha cutouts remain unchanged.

- `scripts/hero_cape.gd`: six pose-authored rear-cloth polygons, source canvas 640×512. These are asset-space masks and shoulder-local fold transforms, independent of device pixels. Canonical face/head/weapon-hand sample points are outside each mask.
- `assets/hero/cape_palette.gdshader`: actual body/cape compositing plus preserved cape palettes. Separate cape sprite samples the same pose image; no opacity trick over the whole hero and no wing painted over the front of the body.
- `scripts/hero_attachments.gd`: original wing alpha image, clasp pivot (403.357,261.561), reviewed 0.76 source scale, behind the folded cape/body. Equipment semantics are unchanged.
- `scripts/presentation/weapon_upgrade_vfx.gd`: separate sword-local light/rune strokes. First upgrade has a visible tier; later tiers use cyan/violet/gold. Source weapon texture and grip remain intact, all five swords supported.
- Existing alpha VFX textures form three directional chain slashes, the ultimate charge/impact, break feedback, crits and higher-rank skill impacts. Effects remain outside body/weapon source art. Controller cap remains 24; floating labels are bounded to 10.
- Status rendering respects disabled ambient effects. UI remains the shared Work 6.5.1 material family; new mode/ultimate controls are real buttons with physical touch-size checks.

Full fixture capture adapter, all native PNGs, actual fresh progression browser flow and data snapshots are shipped in the QA archive. Fixture screenshots and earned-gameplay evidence are labelled separately.
