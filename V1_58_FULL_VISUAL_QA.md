# V1.58 Full Visual Integration QA

## Required visual contracts
- [x] Master concept label: V2.1
- [x] Portrait/mobile-first calibration service present
- [x] Three-reel SPIN housing uses verified production atlas region
- [x] Legacy wheel remains deprecated/hold
- [x] Runtime text remains separate from atlas artwork
- [x] Monster health uses player term `LEBEN`
- [x] Shop does not expose internal product type / price-tier strings
- [x] Disabled ranking CTA avoids backend/server jargon
- [x] Viewport resize reapplies responsive + copy + screen visual calibration
- [x] Dynamic Quest rows retain production-art state backgrounds
- [x] ProgressBar production backdrop supported without hiding runtime fill

## Conservative mapping gates
Village and monster production art must not be semantically guessed merely because an image exists.
A visual match is promoted only after silhouette/function/state review. This prevents a crystal mine from
being silently presented as a Goldmine or a generic house as a higher Townhall tier.

## Device QA still required
A real Godot/Android boot remains required for final pixel-level approval of:
- safe-area clipping,
- reel-window alignment inside the verified SPIN housing,
- text wrapping on smallest supported Android profile,
- overlay heights and scroll pressure,
- exact Village building scale,
- monster sprite state scale/padding.
