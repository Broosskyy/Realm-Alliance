from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
for token in ['name="WinLineLabel"','name="WheelRewardIconP0"']:
    if token not in scene: errors.append("scene missing "+token)
for token in ['_refresh_spin_ui','wheel_reward_icon_p0.texture','JACKPOT · +%d GOLD','v2.0-3reel-p0-05']:
    if token not in game: errors.append("runtime missing "+token)
if cfg.get("config_version")!="v2.0-3reel-p0-05": errors.append("config version mismatch")
if len(cfg.get("segments",[]))!=8: errors.append("eight reward families changed")
if not (root/"SPIN_FINAL_ASSET_SWAP_V2_0.md").exists(): errors.append("final asset swap contract missing")
if "67.250" in scene or "67.250" in game: errors.append("fake static jackpot remains")
if "W010_wheel_p0_v14.png" in scene or "W011_pointer_p0_v14.png" in scene: errors.append("legacy round wheel resources active")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.23R4","config":cfg.get("config_version")},indent=2))
sys.exit(1 if errors else 0)
