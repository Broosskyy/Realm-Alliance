from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
meta=(root/"MetaProgressSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/meta_v1_27.json").read_text(encoding="utf-8"))
checks=[
 ("autoload",'MetaProgressSystem="*res://MetaProgressSystem.gd"' in project),
 ('version','config/version="1.27"' in project or 'config/version="1.41"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.28"' in project or 'config/version="1.29"' in project or 'config/version="1.30"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.31"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
 ("events flag","const SHOW_EVENTS := true" in flags),
 ("rankings flag","const SHOW_RANKINGS := true" in flags),
 ("chest flag","const SHOW_REALM_CHEST := true" in flags),
 ("meta button",'name="MetaButton"' in scene),
 ("meta view",'name="View_Meta"' in scene),
 ("event panel",'name="EventPanel"' in scene),
 ("ranking panel",'name="RankingPanel"' in scene),
 ("chest panel",'name="RealmChestPanel"' in scene),
 ("save export",'"meta_progress": MetaProgressSystem.export_save_data()' in save),
 ("save import",'MetaProgressSystem.apply_save_data(parsed.get("meta_progress", {}))' in save),
 ("schema V20","const SAVE_VERSION := 20" in save),
 ("boss progression","register_boss_defeat" in game and "register_boss_defeat" in meta),
 ("journey key","register_journey_lap" in game and "register_journey_lap" in meta),
 ("event transaction","claim_event" in meta and "SaveGame.save_game()" in meta),
 ("chest transaction","open_realm_chest" in meta),
 ("ranking local mode",cfg.get("ranking",{}).get("metric")=="boss_defeats"),
 ("primary nav preserved",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
 if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.27","event_target":cfg.get("event",{}).get("target_bosses"),"chest_keys":cfg.get("realm_chest",{}).get("required_keys")},indent=2))
sys.exit(1 if errors else 0)
