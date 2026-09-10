from pathlib import Path
import json,sys,re
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
puzzle=(root/"PuzzleSystem.gd").read_text(encoding="utf-8")
progress=(root/"PuzzleProgressionSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/puzzle_v1_28.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_48.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.48"' in project or 'config/version="1.49"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'PuzzleProgressionSystem="*res://PuzzleProgressionSystem.gd"' in project),
("config version",cfg.get("version")=="v1.48-puzzle-v2-04"),
("stages",len(cfg.get("puzzle_progression",{}).get("stage_objectives",[]))==8),
("dynamic target","PuzzleProgressionSystem.target_matches()" in puzzle),
("mastery match","PuzzleProgressionSystem.register_match()" in puzzle),
("mastery completion","PuzzleProgressionSystem.register_completion()" in puzzle),
("completion id",'result["completion_id"]=' in puzzle),
("pending result",'pending_completion=result.duplicate(true)' in puzzle),
("save before emit",puzzle.find("pending_completion=result.duplicate(true)") < puzzle.find("puzzle_completed.emit(result)")),
("resume funcs","func has_pending_completion()" in puzzle and "func _restore_pending_puzzle_completion_v148()" in game),
("afk ordering","PuzzleSystem.has_pending_completion()" in game),
("mastery claim safe","func claimable_mastery_level()" in progress),
("ui stage","PuzzleStageLabelP0" in scene),
("ui mastery","PuzzleMasteryBarP0" in scene and "PuzzleMasteryClaimP0" in scene),
("save write",'"puzzle_progression": PuzzleProgressionSystem.export_save_data()' in save),
("save load order",save.find('PuzzleProgressionSystem.apply_save_data(parsed.get("puzzle_progression", {}))') < save.find('PuzzleSystem.apply_save_data(parsed.get("puzzle", {}))')),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8),
("journey indent fix","\n\t\tjourney_mastery_claim_p0.pressed.connect" in game),
("puzzle indent fix","\n\t\tpuzzle_mastery_claim_p0.pressed.connect" in game)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v148_puzzle").glob("V148_*.png"))
if len(assets)!=8: errors.append("asset count")
for a in assets:
    im=Image.open(a)
    if im.size!=(768,768) or im.mode!="RGBA":
        errors.append("asset format:"+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.48"},indent=2))
sys.exit(1 if errors else 0)
