from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
for token in ['name="NoSpinsPanel"','name="JackpotFlash"','name="SpinStatusLabel"','unique_name_in_owner = true']:
    if token not in scene: errors.append("scene missing "+token)
for token in ['_show_no_spins_state','_show_jackpot_feedback','_pulse_payline','v2.0-3reel-p0-05']:
    if token not in game: errors.append("runtime missing "+token)
if "W010_wheel_p0_v14.png" in scene or "W011_pointer_p0_v14.png" in scene:
    errors.append("legacy circular wheel resources still loaded")
if cfg.get("config_version")!="v2.0-3reel-p0-05":
    errors.append("wrong config version")
if len(cfg.get("segments",[]))!=8:
    errors.append("reward family count changed")
if not (root/"data/SPIN_ASSET_SLOTS_V2_0.json").exists():
    errors.append("asset slot contract missing")
print(json.dumps({"ok":not errors,"errors":errors,"config":cfg.get("config_version"),"reward_families":len(cfg.get("segments",[]))},indent=2))
sys.exit(1 if errors else 0)
