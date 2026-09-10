from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
wheel=(root/"WheelSystem.gd").read_text(encoding="utf-8")
layout=(root/"ResponsiveLayout.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
if "return [winning_index, winning_index, winning_index]" not in wheel: errors.append("full payline does not mirror reward")
if 'result["payline_match"] = true' not in wheel: errors.append("payline_match result missing")
for t in ["_apply_spin_profile","PROFILE_SMALL","PROFILE_STANDARD","PROFILE_TALL"]:
    if t not in layout: errors.append("responsive spin contract missing "+t)
if "v2.0-3reel-p0-05" not in game: errors.append("runtime config telemetry not bumped")
if cfg.get("config_version")!="v2.0-3reel-p0-05": errors.append("config mismatch")
if len(cfg.get("segments",[]))!=8: errors.append("reward families changed")
if not (root/"V1_23R5_SPIN_DEVICE_QA.md").exists(): errors.append("device QA gate missing")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.23R5","master":"V2.0"},indent=2))
sys.exit(1 if errors else 0)
