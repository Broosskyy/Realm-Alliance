# REALM ALLIANCE — SPIN FINAL ASSET SWAP V2.0

V1.23R4 keeps runtime placeholders only as integration scaffolding. Final art replaces textures, not gameplay logic.

## Canonical slots
- SPIN010 — complete machine frame / outer housing, transparent.
- SPIN020 / 021 / 022 — left, center, right reel windows; identical inner dimensions.
- SPIN030 — center-row win/payline treatment.
- SPIN031 — jackpot header/panel.
- SPIN101–108 — eight clean individual reward symbols.
- UI033 — large SPIN primary CTA treatment.
- UI034 — reward/result panel.
- FX040 — reel motion/trail.
- FX041 — individual reel stop impact.
- FX042 — jackpot celebration.
- FX043 — optional No-Spins feedback.

## Runtime rules
- Do not bake localized text, Spin counts, Gold amounts or Jackpot amount into art.
- Three reels stay independent runtime nodes.
- Result authority stays in WheelSystem; art never determines odds.
- All assets require transparent padding, consistent Realm materials and portrait/mobile readability.
- Concept/reference boards must not be cut up and shipped as final runtime assets.
