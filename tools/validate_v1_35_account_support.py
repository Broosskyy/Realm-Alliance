from pathlib import Path
import json,sys,re
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
boot=(root/"BootFlow.gd").read_text(encoding="utf-8")
bootscene=(root/"BootFlow.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
account=(root/"AccountState.gd").read_text(encoding="utf-8")

checks=[
("version",'config/version="1.35"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("boot scene",'run/main_scene="res://BootFlow.tscn"' in project),
("account autoload",'AccountState="*res://AccountState.gd"' in project),
("guest mode",'MODE_GUEST := "guest"' in account),
("local profile",'MODE_LOCAL_PROFILE := "local_profile"' in account),
("no password account","password" not in account.lower()),
("register password validate",'register_password.text.length() < 6' in boot),
("register match",'register_password.text != register_password2.text' in boot),
("consent",'register_consent.button_pressed' in boot),
("no save before load","SaveGame.save_game()" not in account),
("optional save export",'"account_state": AccountState.export_save_data()' in save),
("optional save load",'if parsed.has("account_state")' in save),
("account overlay",'name="AccountOverlayP0"' in scene),
("support overlay",'name="SupportOverlayP0"' in scene),
("guest link","GASTSTAND MIT ACCOUNT VERKNÜPFEN" in scene),
("cloud honesty","BACKEND" in game and "Cloud" in game),
("support slots",all(x in scene for x in ["HELP CENTER","DATENSCHUTZ","NUTZUNGSBEDINGUNGEN","IMPRESSUM"])),
("no urls","http://" not in scene+game+boot and "https://" not in scene+game+boot),
("scene boundary",'SCHLIESSEN"[node' not in scene),
("schema","const SAVE_VERSION := 20" in save),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"']))
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=[
"ACC001_profile_panel_placeholder.png","ACC002_profile_icon_placeholder.png",
"ACC003_cloud_status_placeholder.png","ACC004_support_card_placeholder.png",
"ACC005_legal_card_placeholder.png","ACC006_account_action_placeholder.png"
]
if not all((root/"assets/account"/a).exists() for a in assets):
    errors.append("account asset kit")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.35"},indent=2))
sys.exit(1 if errors else 0)
