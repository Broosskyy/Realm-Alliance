from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
village=(root/"P0VillageSystem.gd").read_text(encoding="utf-8")
prog=(root/"VillageProgressionSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
obj=(root/"ObjectiveSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/village_p0_v1_4.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_53.json").read_text(encoding="utf-8"))
checks=[
("version",'config/version="1.53"' in project),
("autoload",'VillageProgressionSystem="*res://VillageProgressionSystem.gd"' in project),
("config",cfg.get("master_version")=="v1.53-village-v2-06"),
("growth max",cfg.get("village_progression",{}).get("prosperity_max_level")==5),
("townhall gate",'building_id!="townhall" and next_level>P0VillageSystem.get_level("townhall")' in village),
("upgrade id",'"upgrade_id":"village_' in village),
("pending upgrade",'pending_upgrade_result=result.duplicate(true)' in village),
("save before presentation",village.find("pending_upgrade_result=result.duplicate(true)") < village.find("building_changed.emit(building_id)")),
("forge","func craft_forge_upgrade()" in prog and "forge_crafts" in prog),
("temple","func claim_temple_blessing()" in prog and "last_temple_blessing_day" in prog),
("growth reward","func claim_prosperity()" in prog),
("ui growth",'name="VillageGrowthLabelV153"' in scene and 'name="VillageGrowthBarV153"' in scene),
("ui forge",'name="VillageForgeActionV153"' in scene),
("ui temple",'name="VillageTempleActionV153"' in scene),
("restore","func _restore_pending_village_upgrade_v153()" in game),
("legacy connection removed","town_hall_button.pressed.connect(_on_town_hall_pressed)" not in game),
("objective funcs",all(x in obj for x in ["goldmine_claim","forge_craft","temple_blessing"])),
("save export",'"village_progression": VillageProgressionSystem.export_save_data()' in save),
("save load",'VillageProgressionSystem.apply_save_data(parsed.get("village_progression", {}))' in save),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8)
]
errors=[k for k,v in checks if not v]
assets=list((root/"assets/v153_village").glob("V153_*.png"))
if len(assets)!=8:errors.append("asset count")
for a in assets:
 im=Image.open(a)
 if im.size!=(768,768) or im.mode!="RGBA":errors.append("asset format "+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.53"},indent=2))
sys.exit(1 if errors else 0)
