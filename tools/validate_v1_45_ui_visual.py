from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
responsive=(root/"ResponsiveLayout.gd").read_text(encoding="utf-8")
polish=(root/"UiPolishService.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
swap=json.loads((root/"data/asset_swap_map_v1_45.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.45"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'UiPolishService="*res://UiPolishService.gd"' in project),
("polish apply",'UiPolishService.apply(self)' in game),
("touch target",'const MIN_TOUCH_HEIGHT := 78.0' in polish),
("primary target",'const PRIMARY_TOUCH_HEIGHT := 96.0' in polish),
("ranking selected",'ranking_daily_p0.text = "● TÄGLICH"' in game and 'ranking_weekly_p0.text = "● WÖCHENTLICH"' in game),
("shop payload",'reward_bits' in game),
("multi pillar copy",'text = "SPIELMODI & FEATURES"' in scene),
("w106 path",'"res://assets/wheel/segments/W106_puzzle_bonus.png"' in game),
("w106 file",(root/"assets/wheel/segments/W106_puzzle_bonus.png").exists()),
("no old w106 runtime",'"res://assets/wheel/segments/W106_defense_fallback.png"' not in game),
("swap slots",len(swap.get("slots",[]))==8),
("responsive liveops",'LiveOpsOverlayP0' in responsive),
("schema",'const SAVE_VERSION := 20' in save)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v145_ui").glob("V145_*.png"))
if len(assets)!=8: errors.append("asset count")
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.45"},indent=2))
sys.exit(1 if errors else 0)
