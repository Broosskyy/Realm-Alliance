from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
responsive=(root/"ResponsiveLayout.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
errors=[]
checks=[
("version",'config/version="1.39"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.42"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("spin status",'1 PRO DREHUNG · 3 WALZEN' in game),
("payline game",'GEWINNLINIE · MITTLERE REIHE' in game),
("payline scene",'GEWINNLINIE · MITTLERE REIHE' in scene),
("village title",'DORF · GRÜNHAIN' in scene),
("village subtitle",'4 GEBÄUDE · SICHTBAR WACHSEN' in scene),
("ready state",'· BEREIT' in game),
("missing state",'NOCH %d GOLD' in game),
("cost available",'VERFÜGBAR %d' in game),
("upgrade missing CTA",'GOLD BENÖTIGT' in game),
("village responsive",'village_grid.add_theme_constant_override' in responsive),
("feature responsive",'feature_grid.add_theme_constant_override' in responsive),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"'])),
("schema","const SAVE_VERSION := 20" in save),
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v139_polish").glob("P139_*.png"))
if len(assets)!=6: errors.append("v139 asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.39","assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)
