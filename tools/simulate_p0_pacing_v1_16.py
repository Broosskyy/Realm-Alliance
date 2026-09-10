#!/usr/bin/env python3
from pathlib import Path
import json, math, sys

ROOT=Path(__file__).resolve().parents[1]
profile=json.loads((ROOT/"data/p0_balance_profile_v1_16.json").read_text(encoding="utf-8"))
village=json.loads((ROOT/"data/village_p0_v1_4.json").read_text(encoding="utf-8"))
wheel=json.loads((ROOT/"data/wheel_p0_v1_4.json").read_text(encoding="utf-8"))

errors=[]
start=profile["calibrated_starting_economy"]
if start["gold"] != 300: errors.append("starting gold drift")
if start["spins"] != 5: errors.append("starting spins drift")

costs={}
for b in village["buildings"]:
    costs[b["id"]]=[x["cost_to_next"] for x in b["levels"][:2]]
expected={"townhall":[200,600],"goldmine":[150,450],"forge":[180,550],"lucktemple":[180,550]}
if costs != expected: errors.append("Master V1.4 village costs drift")

weights=[s["weight"] for s in wheel["segments"]]
if weights != [22,18,10,20,10,8,7,5]: errors.append("wheel weights drift")
if sum(weights) != 100: errors.append("wheel weights do not total 100")

def hp(level):
    value=round(100*(1.085**max(level-1,0)))
    if level%10==0: value=round(value*2.4)
    return value

first_taps=math.ceil(hp(1)/10)
boss10_taps=math.ceil(hp(10)/10)
if first_taps != 10: errors.append("first monster no longer ~10 taps")
if boss10_taps > 55: errors.append("boss 10 became an early wall")

affordable=[bid for bid,c in costs.items() if c[0] <= start["gold"]]
if len(affordable) < 1: errors.append("no first village choice affordable")
if sum(c[0] for c in costs.values()) <= start["gold"]:
    errors.append("all first upgrades affordable at session start")

# expected direct Gold per wheel spin; shield utility deliberately excluded
ev_gold=0.0
ev_spin_return=0.0
for seg in wheel["segments"]:
    p=seg["weight"]/100.0
    t=seg["reward_type"]
    if t=="gold":
        ev_gold += p*((seg["amount_min"]+seg["amount_max"])/2.0)
    elif t in ("fallback_gold","special_gold"):
        ev_gold += p*seg["amount"]
    elif t=="spins":
        ev_spin_return += p*seg["amount"]

result={
 "ok":not errors,
 "errors":errors,
 "starting_gold":start["gold"],
 "starting_spins":start["spins"],
 "affordable_first_upgrades":affordable,
 "first_monster_taps":first_taps,
 "boss10_hp":hp(10),
 "boss10_taps_at_10_damage":boss10_taps,
 "wheel_expected_direct_gold_per_spin":round(ev_gold,2),
 "wheel_expected_spin_return_per_spin":round(ev_spin_return,3),
 "first_30_level_taps_at_damage_10":[math.ceil(hp(i)/10) for i in range(1,31)]
}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(0 if not errors else 1)
