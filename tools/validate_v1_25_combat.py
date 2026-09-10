from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
enc=json.loads((root/"data/encounters_greenvale_p0_v1_4.json").read_text(encoding="utf-8"))
visual=(root/"P0MonsterVisualSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
expected={
 "M001":["idle","hit","defeat"],
 "M002":["idle","hit","defeat"],
 "M003":["idle","hit","defeat"],
 "M004":["idle","hit","defeat"],
 "B001":["idle","hit","shield","defeat"]
}
defs={m["id"]:m for m in enc.get("monsters",[])}
for mid,states in expected.items():
 if mid not in defs: errors.append("missing definition "+mid)
 for state in states:
  if not (root/f"assets/monsters/greenvale/states/{mid}_{state}.png").exists():
   errors.append(f"missing {mid}_{state}")
if defs.get("M001",{}).get("name")!="Waldwinzling": errors.append("M001 canonical name drift")
if enc.get("rotation")!=["M001","M002","M003","M004"]: errors.append("rotation drift")
if int(enc.get("boss_every_kills",0))!=10: errors.append("boss frequency drift")
for token in ["production_asset_id","has_state"]:
 if token not in visual: errors.append("visual contract missing "+token)
for token in ["encounter_id","monster_defeat_visual","boss_shield_visual","BOSS IN %d"]:
 if token not in game: errors.append("runtime polish missing "+token)
if "const SAVE_VERSION := 20" not in save: errors.append("save schema drift")
count=sum(len(v) for v in expected.values())
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.25","required_state_assets":count},indent=2))
sys.exit(1 if errors else 0)
