#!/usr/bin/env python3
from pathlib import Path
import json, re, math, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]
notes=[]

def read(name):
    return (ROOT/name).read_text(encoding="utf-8")

flags=read("FeatureFlags.gd")
game=read("GameConfig.gd")
player=read("PlayerData.gd")
main=read("MainGame.gd")
wheel=read("WheelSystem.gd")
village=read("P0VillageSystem.gd")
contract=read("P0RuntimeContract.gd")
harness=read("P0TestHarness.gd")
wheel_data=json.loads(read("data/wheel_p0_v1_4.json"))
village_data=json.loads(read("data/village_p0_v1_4.json"))
acceptance=json.loads(read("data/p0_core_acceptance_v1_17.json"))
balance=json.loads(read("data/p0_balance_profile_v1_16.json"))

def require(cond,msg):
    if not cond: errors.append(msg)

# P1 gate
for flag in ["SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","ENABLE_HERO_AUTODPS"]:
    require(f"const {flag} := false" in flags, f"P1 flag enabled: {flag}")

# Starting economy
require("var gold: int = 300" in player, "Starting Gold drift")
require("var spins: int = 5" in player, "Starting Spins drift")
require(balance["calibrated_starting_economy"]["gold"]==300, "Balance profile Gold drift")
require(balance["calibrated_starting_economy"]["spins"]==5, "Balance profile Spins drift")

# Monster pacing / boss
require("const MONSTER_BASE_HP := 100" in game, "Monster base HP drift")
require("const MONSTER_HP_GROWTH := 1.085" in game, "Monster HP growth drift")
require("const BOSS_HP_MULTIPLIER := 2.4" in game, "Boss HP multiplier drift")
def hp(level):
    v=round(100*(1.085**max(level-1,0)))
    return round(v*2.4) if level%10==0 else v
require(math.ceil(hp(1)/10)==10, "Monster 1 not 10 taps")
require(hp(10)==499, "Boss 10 HP drift")
require('encounter_id_for_level(10) != "B001"' in contract or 'encounter_id_for_level(10) == "B001"' not in contract, "Contract boss check unexpectedly changed")
require('"B001"' in contract, "Boss B001 contract missing")

# Transaction durability
kill=re.search(r"func _on_monster_pressed\(\).*?(?=\nfunc |\Z)",main,re.S)
require(kill is not None, "Kill handler missing")
if kill:
    kb=kill.group(0)
    require("PlayerData.spawn_next_monster()" in kb, "Kill transaction does not commit next monster")
    require("SaveGame.save_game()" in kb, "Kill transaction does not save")
    require(kb.find("PlayerData.spawn_next_monster()") < kb.find("SaveGame.save_game()"), "Kill saves before next monster")
require("_repair_legacy_zero_hp_monster" in read("SaveGame.gd"), "Legacy HP=0 repair missing")

# Wheel
weights=[int(s["weight"]) for s in wheel_data["segments"]]
require(weights==[22,18,10,20,10,8,7,5], "Wheel weights drift")
require(sum(weights)==100, "Wheel weights total != 100")
require("spin_transaction_active" in wheel, "Wheel transaction guard missing")

# Village
ids=[b["id"] for b in village_data["buildings"]]
require(ids==["townhall","goldmine","forge","lucktemple"], "Village building IDs drift")
costs={b["id"]:[x["cost_to_next"] for x in b["levels"][:2]] for b in village_data["buildings"]}
require(costs=={"townhall":[200,600],"goldmine":[150,450],"forge":[180,550],"lucktemple":[180,550]}, "Village costs drift")
require("upgrade_transaction_active" in village, "Village upgrade guard missing")
require("claim_transaction_active" in village, "Goldmine claim guard missing")

# Harness
for profile in ["fresh","half_boss","boss_ready","wheel","village","return","low_resource","legacy_zero_hp"]:
    require(profile in harness, f"Harness profile missing: {profile}")

# UX flow
for token in ["TIPPE AUF DAS MONSTER","BOSS IN %d","KEINE SPINS"]:
    require(token in main, f"First-session UX token missing: {token}")

result={
  "ok":not errors,
  "errors":errors,
  "required_core_views":acceptance["required_core_views"],
  "scenario_count":len(acceptance["acceptance_scenarios"]),
  "boss10_hp":hp(10),
  "first_monster_taps":math.ceil(hp(1)/10),
  "wheel_weights":weights,
  "village_ids":ids,
  "p1_blocked":not any(f"const {f} := true" in flags for f in ["SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE"])
}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(0 if not errors else 1)
