from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text()
hero=(root/"HeroSystem.gd").read_text()
prog=(root/"HeroProgressionSystem.gd").read_text()
game=(root/"MainGame.gd").read_text()
save=(root/"SaveGame.gd").read_text()
meta=(root/"MetaProgressSystem.gd").read_text()
cfg=json.loads((root/"data/heroes.json").read_text())
swap=json.loads((root/"data/asset_swap_map_v1_51.json").read_text())
checks=[
("version",'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'HeroProgressionSystem="*res://HeroProgressionSystem.gd"' in project),
("hero cfg",cfg.get("version")=="v1.51-heroes-v2-04"),
("mastery",cfg.get("mastery",{}).get("max_level")==5),
("specs",len(cfg.get("specializations",{}))==3),
("defeat hook","HeroProgressionSystem.register_monster_defeat(result)" in game),
("boss mastery",'bool(result.get("boss",false))' in prog),
("power bonus","HeroProgressionSystem.specialization_power_bonus(hero_id)" in hero),
("save export",'"hero_progression": HeroProgressionSystem.export_save_data()' in save),
("save load",'HeroProgressionSystem.apply_save_data(parsed.get("hero_progression", {}))' in save),
("fake rankings removed",'return []' in meta[meta.find("func ranking_rows()"):meta.find("func export_save_data()")]),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8)
]
errors=[k for k,v in checks if not v]
assets=list((root/"assets/v151_heroes").glob("V151_*.png"))
if len(assets)!=8:errors.append("asset count")
for a in assets:
 im=Image.open(a)
 if im.size!=(768,768) or im.mode!="RGBA":errors.append("asset format "+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.51"},indent=2))
sys.exit(1 if errors else 0)
