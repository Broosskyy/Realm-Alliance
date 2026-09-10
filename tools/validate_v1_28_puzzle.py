from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
puzzle=(root/"PuzzleSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/puzzle_v1_28.json").read_text(encoding="utf-8"))
checks=[
("autoload",'PuzzleSystem="*res://PuzzleSystem.gd"' in project),
('version','config/version="1.28"' in project or 'config/version="1.41"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.29"' in project or 'config/version="1.30"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.31"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("flag","const SHOW_PUZZLE := true" in flags),
("view",'name="View_Puzzle"' in scene),
("button",'name="PuzzleButton"' in scene),
("nine cells",sum(1 for i in range(9) if f'name="PuzzleCell{i}"' in scene)==9),
("save export",'"puzzle": PuzzleSystem.export_save_data()' in save),
("save import",'PuzzleSystem.apply_save_data(parsed.get("puzzle", {}))' in save),
("schema V20","const SAVE_VERSION := 20" in save),
("adjacency","func _adjacent" in puzzle),
("match check","func _has_match" in puzzle),
("invalid revert",'message":"Kein 3er-Match"' in puzzle),
("runtime","_on_puzzle_cell_pressed" in game),
("3x3",int(cfg.get("board_size",0))==9),
("target",int(cfg.get("target_matches",0))==3),
("primary nav",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
 if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.28"},indent=2))
sys.exit(1 if errors else 0)
