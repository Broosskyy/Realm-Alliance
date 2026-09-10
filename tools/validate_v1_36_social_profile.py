from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
system=(root/"SocialHubSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
errors=[]
checks=[
("version",'config/version="1.36"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'SocialHubSystem="*res://SocialHubSystem.gd"' in project),
("profile snapshot","func profile_snapshot()" in system),
("achievements","func achievements()" in system and "first_steps" in system and "greenvale_guard" in system),
("no reward grant","add_gold(" not in system and "add_spin(" not in system),
("inbox","const MESSAGES" in system and "mark_all_read" in system),
("save export",'"social_hub": SocialHubSystem.export_save_data()' in save),
("save load",'SocialHubSystem.apply_save_data(parsed.get("social_hub", {}))' in save),
("social overlay",'name="SocialOverlayP0"' in scene),
("tabs",all(x in scene for x in ["POSTFACH","ERFOLGE","FREUNDE"])),
("friends honesty","keine Fake-Freunde" in game and "serverseitigen Social-Service" in game),
("no urls","http://" not in system+game+scene and "https://" not in system+game+scene),
("schema","const SAVE_VERSION := 20" in save),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"']))
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/social").glob("SOC*.png"))
if len(assets)!=6: errors.append("social asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.36"},indent=2))
sys.exit(1 if errors else 0)
