from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
m=json.loads((root/"data/build_manifest_v1_42.json").read_text(encoding="utf-8"))
checks={"version":'config/version="1.42"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project,"defeat boundary":"func _resolve_monster_defeat_v142(source: String)" in game or (root/"MonsterDefeatService.gd").exists(),"defeat id":("last_monster_defeat_id_v142" in game and '"defeat_id":last_monster_defeat_id_v142' in game) or ("defeat_id" in (root/"MonsterDefeatService.gd").read_text(encoding="utf-8") if (root/"MonsterDefeatService.gd").exists() else False),"source attribution":'"source":source' in game,"multi pillars":len(m.get("gameplay_pillars",[]))>=7,"save v20":"const SAVE_VERSION := 20" in save,"website excluded":m.get("website")=="excluded"}
bad=[k for k,v in checks.items() if not v]
print(json.dumps({"ok":not bad,"errors":bad,"source":"V1.42"},indent=2))
sys.exit(1 if bad else 0)
