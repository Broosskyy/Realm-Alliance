# REALM ALLIANCE V1.92

## Tower Defense production-role convergence
- Four production tower families are now selected visibly at runtime: Archer, Mage, Cannon and Nature.
- Tower slots stay hidden until built instead of showing legacy generic towers.
- Tower attacks briefly switch to production attack/ready states.
- TD projectiles now originate from the visible tower rather than the fight button.
- Enemy waves rotate through the available production enemy families and receive lightweight hit feedback.
- Added high-confidence state bindings for tower idle/attack/ready and enemy idle/attack/defeat art.
- Presentation director is deliberately non-authoritative: no damage, reward, economy or save decisions.

## Preservation
- Master concept V2.2 retained.
- Save schema remains 35.
- Existing gameplay/economy/online-ready foundations are preserved.
- Runtime/device QA still requires Godot outside this environment.
