from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text();obj=(root/"ObjectiveSystem.gd").read_text();game=(root/"MainGame.gd").read_text();save=(root/"SaveGame.gd").read_text();scene=(root/"MainGame.tscn").read_text();meta=(root/"MetaProgressSystem.gd").read_text()
cfg=json.loads((root/"data/objectives_v1_52.json").read_text());swap=json.loads((root/"data/asset_swap_map_v1_52.json").read_text())
checks=[
("version",'config/version="1.52"' in project or 'config/version="1.53"' in project),("autoload",'ObjectiveSystem="*res://ObjectiveSystem.gd"' in project),
("config",cfg.get("version")=="v1.52-objectives-v2-05"),("daily",len(cfg.get("daily",[]))==3),("weekly",len(cfg.get("weekly",[]))==3),("achievements",len(cfg.get("achievements",[]))==5),
("day bucket","func _utc_day()" in obj),("week bucket","func _week_bucket()" in obj),("bestiary","bestiary" in obj and 'metric=="monster_defeat"' in obj),
("save export",'"objectives": ObjectiveSystem.export_save_data()' in save),("save load",'ObjectiveSystem.apply_save_data(parsed.get("objectives", {}))' in save),
("combat hook",'ObjectiveSystem.register_action("monster_defeat"' in game),("spin hook",'ObjectiveSystem.register_action("spin",1)' in game),("journey hook",'ObjectiveSystem.register_action("journey_lap",1)' in game),("puzzle hook",'ObjectiveSystem.register_action("puzzle_complete",1)' in game),("td hook",'ObjectiveSystem.register_action("td_win",1)' in game),("lane hook",'ObjectiveSystem.register_action("lane_win",1)' in game),
("scroll",'name="QuestScrollV152"' in scene),("fake rankings removed",'return []' in meta[meta.find("func ranking_rows()"):meta.find("func export_save_data()")]),("schema",'const SAVE_VERSION := 20' in save),("swap",len(swap.get("slots",[]))==8)]
errors=[k for k,v in checks if not v]
assets=list((root/"assets/v152_objectives").glob("V152_*.png"))
if len(assets)!=8:errors.append("asset count")
for a in assets:
 im=Image.open(a)
 if im.size!=(768,768) or im.mode!="RGBA":errors.append("asset format "+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.52"},indent=2));sys.exit(1 if errors else 0)
