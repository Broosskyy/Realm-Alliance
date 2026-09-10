from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
scene=(root/"BootFlow.tscn").read_text(encoding="utf-8")
script=(root/"BootFlow.gd").read_text(encoding="utf-8")
checks=[
("version",'config/version="1.34"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("boot main",'run/main_scene="res://BootFlow.tscn"' in project),
("splash",'name="Splash"' in scene),
("bootstrap",'name="Bootstrap"' in scene),
("welcome",'name="Welcome"' in scene),
("start",'SPIEL STARTEN' in scene),
("guest",'ALS GAST SPIELEN' in scene),
("login",'name="Login"' in scene and 'WILLKOMMEN ZURÜCK' in scene),
("register",'name="Register"' in scene and 'ACCOUNT ERSTELLEN' in scene),
("community",'DISCORD' in scene and 'INSTAGRAM' in scene and 'YOUTUBE' in scene),
("no fake urls","http://" not in scene+script and "https://" not in scene+script),
("game transition",'change_scene_to_file("res://MainGame.tscn")' in script),
("account honesty","BACKEND FOLGT" in script),
("assets",all((root/"assets/entry"/n).exists() for n in [
"ENTRY001_splash_bg_placeholder.png","ENTRY002_welcome_bg_placeholder.png",
"ENTRY003_realm_emblem_placeholder.png","ENTRY010_auth_panel_placeholder.png",
"ENTRY011_primary_button_placeholder.png","ENTRY012_secondary_button_placeholder.png"]))
]
for label,ok in checks:
    if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.34"},indent=2))
sys.exit(1 if errors else 0)
