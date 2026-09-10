# V1.49 Tower Defense V2 QA

Static acceptance:
- Bottom navigation DEFENSE is no longer the fight button.
- Dedicated fight, tech, mastery and next-stage controls exist inside Tower Defense.
- Six campaign stages are data-driven.
- Stage HP bonus is applied through TowerDefenseProgressionSystem.
- Tower Tech uses existing Gold and is capped at level 4.
- Wave and run Mastery XP are booked before save.
- Final run result contains unique run_id and pending-presentation contract.
- Pending TD completion restores without re-granting run rewards.
- AFK presentation waits behind pending Spin/Journey/Puzzle/Tower Defense results.
- Halloween receives one seasonal activity action per cleared TD wave.
- Global Progression Hub includes Defense stage/Mastery/Tech.
- Placeholder kit contains exactly 8 isolated transparent 768×768 assets.
- Save Schema remains V20.

Still pending:
- Godot executable/device parser validation.
- Physical Android layout/visual QA.
- Final Recraft/production models and effects.
- Later tower archetypes, enemy traits, lane branching and active abilities.
