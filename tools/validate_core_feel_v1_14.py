#!/usr/bin/env python3
from pathlib import Path
import re, json, sys

ROOT=Path(__file__).resolve().parents[1]
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
flags=(ROOT/"FeatureFlags.gd").read_text(encoding="utf-8")
errors=[]

checks={
 "hp_tween":"hp_tween" in main and 'tween_property(monster_hp, "value"' in main,
 "damage_reduced_motion_readable":'damage_tween.tween_interval(0.18)' in main,
 "monster_idle":"func _process(delta: float)" in main and "monster_idle_clock" in main,
 "hit_reaction":"monster_reaction_active = true" in main and "TRANS_BACK" in main,
 "touch_feedback":"func _setup_core_touch_feedback()" in main,
 "wheel_reward_scale":"wheel_reward_overlay_p0.scale" in main,
 "no_new_p1":all(f"const {x} := false" in flags for x in [
   "SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","ENABLE_HERO_AUTODPS"
 ]),
}
for key,value in checks.items():
    if not value: errors.append(key)
print(json.dumps({"ok":not errors,"checks":checks,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)
