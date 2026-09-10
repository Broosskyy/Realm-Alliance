from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
journey=(root/"DiceJourneySystem.gd").read_text(encoding="utf-8")
mastery=(root/"JourneyProgressionSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/dice_journey_greenvale_v1_26.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_47.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.47"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'JourneyProgressionSystem="*res://JourneyProgressionSystem.gd"' in project),
("config",cfg.get("version")=="v1.47-journey-progression-03"),
("board",cfg.get("board_nodes")==12 and len(cfg.get("node_profiles",[]))==12),
("deterministic rng","RandomNumberGenerator.new()" in journey and "rng.seed = roll_seed" in journey),
("pending result","pending_result = result.duplicate(true)" in journey),
("atomic roll progression",journey.find("JourneyProgressionSystem.register_roll(result)") < journey.find("pending_result = result.duplicate(true)")),
("atomic portal progression","JourneyProgressionSystem.register_portal_open()" in journey),
("mastery","func progress_ratio()" in mastery and "max_level" in mastery),
("claim safe","func claimable_mastery_level()" in mastery),
("shards","relic_shards" in mastery and "lap_relic_shards" in str(cfg)),
("cache","func open_cache()" in mastery and "JourneyCacheP0" in scene),
("ui","JourneyMasteryBarP0" in scene and "JourneyNodeDetailP0" in scene),
("save",'"journey_progression": JourneyProgressionSystem.export_save_data()' in save),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v147_journey").glob("V147_*.png"))
if len(assets)!=8: errors.append("asset count")
for a in assets:
    im=Image.open(a)
    if im.size!=(768,768) or im.mode!="RGBA":
        errors.append("asset format:"+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.47"},indent=2))
sys.exit(1 if errors else 0)
