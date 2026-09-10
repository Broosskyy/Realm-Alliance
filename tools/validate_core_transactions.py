#!/usr/bin/env python3
from pathlib import Path
import re, sys, json

ROOT=Path(__file__).resolve().parents[1]
errors=[]

main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
save=(ROOT/"SaveGame.gd").read_text(encoding="utf-8")
wheel=(ROOT/"WheelSystem.gd").read_text(encoding="utf-8")
village=(ROOT/"P0VillageSystem.gd").read_text(encoding="utf-8")

kill=re.search(r"func _on_monster_pressed\(\).*?(?=\nfunc |\Z)",main,re.S)
cont=re.search(r"func _continue_after_monster_reward\(\).*?(?=\nfunc |\Z)",main,re.S)
if not kill or "PlayerData.spawn_next_monster()" not in kill.group(0):
    errors.append("kill transaction does not commit next monster")
if kill and kill.group(0).find("PlayerData.spawn_next_monster()") > kill.group(0).find("SaveGame.save_game()"):
    errors.append("kill transaction saves before next monster commit")
if cont and "PlayerData.spawn_next_monster()" in cont.group(0):
    errors.append("Continue still advances monster and can double-advance")
if "_show_monster_defeat_state_for_level(defeated_level" not in main:
    errors.append("defeat visual is not pinned to defeated level")
if "spin_transaction_active" not in wheel:
    errors.append("wheel transaction guard missing")
if "upgrade_transaction_active" not in village:
    errors.append("village upgrade transaction guard missing")
if "claim_transaction_active" not in village:
    errors.append("goldmine claim transaction guard missing")
if "_repair_legacy_zero_hp_monster" not in save:
    errors.append("legacy HP=0 save repair missing")
if "SAVE_VERSION := 20" not in save:
    errors.append("save schema not V20")

print(json.dumps({"ok":not errors,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)
