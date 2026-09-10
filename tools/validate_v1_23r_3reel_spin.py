from pathlib import Path
import json, re, sys
root=Path(__file__).resolve().parents[1]
errors=[]
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
if cfg.get("reel_count") != 3: errors.append("reel_count != 3")
if len(cfg.get("segments",[])) != 8: errors.append("eight reward families not preserved")
if sum(int(x.get("weight",0)) for x in cfg.get("segments",[])) != 100: errors.append("weights != 100")
mg=(root/"MainGame.gd").read_text(encoding="utf-8")
for token in ["%Reel1","%Reel2","%Reel3","reel_stops","v2.0-3reel-p0-05"]:
    if token not in mg: errors.append("missing MainGame token: "+token)
if "wheel_base.rotation" in mg: errors.append("legacy round-wheel rotation still active")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
for token in ['name="Reel1"','name="Reel2"','name="Reel3"','name="SpinMachineFrame"']:
    if token not in scene: errors.append("missing scene node: "+token)
if 'name="WheelBase"' in scene or 'name="WheelPointer"' in scene:
    errors.append("legacy round-wheel scene nodes still active")
print(json.dumps({"ok":not errors,"errors":errors,"reels":3,"reward_families":len(cfg.get("segments",[]))},indent=2))
sys.exit(1 if errors else 0)
