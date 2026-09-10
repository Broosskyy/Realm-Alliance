# REALM ALLIANCE V1.23R6 — SPIN Runtime Modularization & Resume Safety

Master V2.0 V1.23 closure pass.

- Added `SpinReelPresenter.gd`: dedicated 3-reel symbol/animation presenter.
- MainGame delegates reel rendering and stop animation to the presenter.
- Added `SpinPresentationState.gd` autoload for presentation-only pending reward state.
- Authoritative reward is still granted exactly once in WheelSystem before animation.
- Pending result is saved as optional Save Schema V20 data; schema number remains V20.
- If the app/process returns with an unacknowledged SPIN result, the exact reel stops and reward overlay are restored without granting the reward again.
- Closing the reward overlay acknowledges/clears the pending presentation and saves.
- Added `spin_presentation_resumed` analytics event.
- Config bumped to `v2.0-3reel-p0-05`.
- Website remains excluded.
- Final production art and real Android visual QA remain external acceptance gates.
