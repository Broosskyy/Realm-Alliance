from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
controller=(root/"P02CoreController.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
errors=[]
checks=[
("version",'config/version="1.37"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.42"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("more",'name="MoreFeaturesButtonP0"' in scene and 'text = "MEHR"' in scene),
("hub",'name="FeatureHubOverlayP0"' in scene),
("grid",'name="FeatureHubGrid"' in scene and "columns = 2" in scene),
("hub entries",all(x in scene for x in ["HELDEN","PUZZLE","DEFENSE","LANE BATTLE","EVENTS & META","PROFIL & SOCIAL"])),
("badge",'name="QuickBadgeP0"' in scene and "SocialHubSystem.unread_count()" in game and "DailyRewards.can_claim()" in game and "QuestSystem.is_ready" in game),
("hidden legacy",all(f'_set_visible(root, "{n}", false)' in controller for n in ["HeroesGameButton","LaneBattleButton","DefenseGameButton","PuzzleButton","MetaButton"])),
("more visible",'_set_visible(root, "MoreFeaturesButtonP0", true)' in controller),
("routes",all(x in game for x in ["_hub_open_heroes_p0","_hub_open_puzzle_p0","_hub_open_defense_p0","_hub_open_lane_p0","_hub_open_meta_p0","_hub_open_profile_p0"])),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"'])),
("schema","const SAVE_VERSION := 20" in save),
("no urls","http://" not in game+scene and "https://" not in game+scene)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/ui_polish").glob("UIP*.png"))
if len(assets)!=6: errors.append("ui polish asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.37"},indent=2))
sys.exit(1 if errors else 0)
