# V1.47 Realm Journey V2 QA

Static acceptance:
- 12-node Grünhain board remains intact.
- Per-roll deterministic RNG and pending-result resume contract remain intact.
- Journey Mastery XP is committed before the roll save.
- Portal Mastery XP is committed before the portal save.
- Mastery levels are data-driven and capped at level 5.
- Unclaimed lower-level mastery rewards remain claimable after later level-ups.
- Relikt-Splitter are earned only from completed laps in this version.
- Journey Cache has an explicit cost and exactly-once client transaction.
- Global Progression Hub reads Journey Mastery state.
- UI includes node identity, Mastery bar, reward CTA and Cache CTA.
- Placeholder kit contains exactly 8 transparent 768×768 isolated assets.
- Save schema remains V20.

Still pending:
- Godot executable/device parser test.
- Physical mobile visual QA.
- Final Recraft/production art.
- More regions/boards and later branch/path-choice mechanics.
