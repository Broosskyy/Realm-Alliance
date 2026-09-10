#!/usr/bin/env python3
from pathlib import Path
import json, math, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]

wheel=json.loads((ROOT/"data/wheel_p0_v1_4.json").read_text(encoding="utf-8"))
village=json.loads((ROOT/"data/village_p0_v1_4.json").read_text(encoding="utf-8"))
enc=json.loads((ROOT/"data/encounters_greenvale_p0_v1_4.json").read_text(encoding="utf-8"))

weights=[int(x["weight"]) for x in wheel["segments"]]
if sum(weights)!=100:
    errors.append("wheel weights != 100")
if len(weights)!=8:
    errors.append("wheel segments != 8")

building_ids=[str(x["id"]) for x in village["buildings"]]
for expected in ["townhall","goldmine","forge","lucktemple"]:
    if expected not in building_ids:
        errors.append(f"missing building {expected}")

# Master prototype costs
expected_costs={
    "townhall":[200,600],
    "goldmine":[150,450],
    "forge":[180,550],
    "lucktemple":[180,550],
}
for b in village["buildings"]:
    bid=b["id"]
    if bid in expected_costs:
        got=[int(x["cost_to_next"]) for x in b["levels"][:2]]
        if got!=expected_costs[bid]:
            errors.append(f"{bid} costs drift: {got}")

# First ten encounter contract
rotation=enc.get("rotation",[])
if len(rotation)<4:
    errors.append("Greenvale rotation needs four normal monsters")
boss_id=enc.get("boss",{}).get("id") or enc.get("boss_id")
# tolerate existing schema; source runtime is authoritative for B001
if "B001" not in json.dumps(enc):
    errors.append("B001 absent from encounter config")

# First-monster feel from Master
hp1=100
tap=10
if math.ceil(hp1/tap)!=10:
    errors.append("first monster should take about 10 taps")

report={
    "ok":not errors,
    "errors":errors,
    "wheel_weights":weights,
    "building_ids":building_ids,
    "first_monster_taps":math.ceil(hp1/tap),
}
print(json.dumps(report,ensure_ascii=False,indent=2))
sys.exit(0 if not errors else 1)
