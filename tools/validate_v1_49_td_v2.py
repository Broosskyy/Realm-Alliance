from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
td=(root/"TowerDefenseSystem.gd").read_text(encoding="utf-8")
progress=(root/"TowerDefenseProgressionSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
live=(root/"LiveOpsRankingSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/tower_defense_v1_29.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_49.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.49"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'TowerDefenseProgressionSystem="*res://TowerDefenseProgressionSystem.gd"' in project),
("config",cfg.get("version")=="v1.49-td-v2-05"),
("stages",len(cfg.get("stage_profiles",[]))==6),
("dedicated fight",'@onready var td_fight_button: Button = %TDFightButtonP0' in game and 'name="TDFightButtonP0"' in scene),
("no nav fight",'@onready var td_fight_button: Button = %Btn_Defense' not in game),
("tech","func upgrade_tower_tech()" in progress and "tower_tech_level" in progress),
("mastery","func register_wave_clear()" in progress and "func register_run_completion()" in progress),
("run id",'"run_id":"td_' in td),
("pending",'pending_run_result=result.duplicate(true)' in td and "func has_pending_run_result()" in td),
("save before emit",td.find("pending_run_result=result.duplicate(true)") < td.find("td_completed.emit(result)")),
("restore","func _restore_pending_td_run_v149()" in game),
("afk waits","TowerDefenseSystem.has_pending_run_result()" in game),
("save write",'"tower_defense_progression": TowerDefenseProgressionSystem.export_save_data()' in save),
("load order",save.find('TowerDefenseProgressionSystem.apply_save_data(parsed.get("tower_defense_progression", {}))') < save.find('TowerDefenseSystem.apply_save_data(parsed.get("tower_defense", {}))')),
("liveops td","func register_td_wave()" in live and "LiveOpsRankingSystem.register_td_wave()" in game),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v149_td").glob("V149_*.png"))
if len(assets)!=8: errors.append("asset count")
for a in assets:
    im=Image.open(a)
    if im.size!=(768,768) or im.mode!="RGBA":
        errors.append("asset format:"+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.49"},indent=2))
sys.exit(1 if errors else 0)
