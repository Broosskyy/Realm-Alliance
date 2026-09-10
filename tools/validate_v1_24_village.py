from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
visual=(root/"P0VillageVisualSystem.gd").read_text(encoding="utf-8")
system=(root/"P0VillageSystem.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
for token in ['name="VillageGround"','name="BuildingStagePreview"','name="Stage1"','name="Stage2"','name="Stage3"']:
    if token not in scene: errors.append("scene missing "+token)
for token in ['_refresh_building_stage_preview','_show_building_upgrade_feedback','building_upgrade_feedback']:
    if token not in game: errors.append("runtime missing "+token)
if "func texture_for_level" not in visual: errors.append("explicit stage visual lookup missing")
for bid in ["townhall","goldmine","forge","lucktemple"]:
    if bid not in system: errors.append("building missing "+bid)
assets=list((root/"assets/village/greenvale/p0").glob("V00*_lv*.png"))
if len(assets)!=12: errors.append("expected 12 stage assets, got %d" % len(assets))
if not (root/"assets/village/greenvale/V000_village_ground.png").exists(): errors.append("ground asset missing")
if "const SAVE_VERSION := 20" not in save: errors.append("save schema drift")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.24","stage_assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)
