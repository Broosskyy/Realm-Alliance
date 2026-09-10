#!/usr/bin/env python3
from pathlib import Path
import json, sys

ROOT=Path(__file__).resolve().parents[1]
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
scene=(ROOT/"MainGame.tscn").read_text(encoding="utf-8")
flags=(ROOT/"FeatureFlags.gd").read_text(encoding="utf-8")

checks={
 "hint_node":"FirstSessionHintP0" in scene,
 "boss_proximity_node":"BossProximityP0" in scene,
 "first_action_hint":'TIPPE AUF DAS MONSTER' in main,
 "boss_in_countdown":'BOSS IN %d' in main,
 "wheel_empty_state":'KEINE SPINS' in main,
 "village_affordance":'can_upgrade_any' in main,
 "no_p1":all(f"const {x} := false" in flags for x in [
   "SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","ENABLE_HERO_AUTODPS"
 ]),
}
errors=[k for k,v in checks.items() if not v]
print(json.dumps({"ok":not errors,"checks":checks,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)
