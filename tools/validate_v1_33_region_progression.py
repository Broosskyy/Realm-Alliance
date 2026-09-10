from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
system=(root/"RegionProgressionSystem.gd").read_text(encoding="utf-8")
regions=json.loads((root/"data/regions.json").read_text(encoding="utf-8")).get("regions",[])
by={r.get("id"):r for r in regions}
checks=[
('version','config/version="1.33"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.34"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'RegionProgressionSystem="*res://RegionProgressionSystem.gd"' in project),
("greenvale",by.get("greenvale",{}).get("unlock_level")==1),
("frostmark",by.get("frostmark",{}).get("unlock_level")==20),
("frostmark empty monsters",by.get("frostmark",{}).get("monsters")==[]),
("system","func progress_to_next_region" in system and "func is_unlocked" in system),
("panel",'name="RegionProgressPanel"' in scene),
("bar",'name="RegionProgressBar"' in scene),
("refresh","func _refresh_region_progression_ui" in game),
("telemetry",'region_unlocked"' in game),
("schema","const SAVE_VERSION := 20" in save),
("primary nav",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
    if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.33"},indent=2))
sys.exit(1 if errors else 0)
