from pathlib import Path
import json,sys,re
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
wheel=(root/"WheelSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
presenter=(root/"SpinReelPresenter.gd").read_text(encoding="utf-8")
state=(root/"SpinPresentationState.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
checks=[
 ("SpinPresentationState autoload",'SpinPresentationState="*res://SpinPresentationState.gd"' in project),
 ("optional spin save export",'"spin_presentation": SpinPresentationState.export_save_data()' in save),
 ("spin save import",'SpinPresentationState.apply_save_data(parsed.get("spin_presentation", {}))' in save),
 ("pending set before save",wheel.find("SpinPresentationState.set_pending_result") < wheel.find("SaveGame.save_game()")),
 ("pending acknowledgement","SpinPresentationState.acknowledge_pending_result()" in game),
 ("resume restore","_restore_pending_spin_presentation" in game and "spin_presentation_resumed" in game),
 ("dedicated presenter",'class_name SpinReelPresenter' in presenter and "play_to" in presenter),
 ("MainGame presenter delegation","await spin_reel_presenter.play_to" in game and "spin_reel_presenter.show_stops" in game),
 ("schema V20","const SAVE_VERSION := 20" in save),
 ("config V05+",cfg.get("config_version") in ["v2.0-3reel-p0-05","v2.0-3reel-p0-06"]),
 ("8 rewards",len(cfg.get("segments",[]))==8),
]
for label,ok in checks:
    if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.23R6","save_schema":"V20","config":cfg.get("config_version")},indent=2))
sys.exit(1 if errors else 0)
