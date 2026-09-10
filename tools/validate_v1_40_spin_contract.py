from pathlib import Path
import json,sys,re
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
wheel=(root/"WheelSystem.gd").read_text(encoding="utf-8")
presenter=(root/"SpinReelPresenter.gd").read_text(encoding="utf-8")
state=(root/"SpinPresentationState.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/spin_3reel_v2_0.json").read_text(encoding="utf-8"))
errors=[]
required=[
"result_id","reward_id","reward_type","reward_value","config_version",
"outcome_seed","visual_seed","reel_stops","reel_stop_ids","outcomes",
"visual_symbol_id","visual_symbol_index"
]
checks=[
("version",'config/version="1.40"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.42"' in project or 'config/version="1.41"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("config V06",'const CONFIG_VERSION := "v2.0-3reel-p0-06"' in wheel and cfg.get("config_version")=="v2.0-3reel-p0-06"),
("contract version",'RESULT_CONTRACT_VERSION := "spin-result-v1"' in wheel),
("required fields",all(f'result["{x}"]' in wheel for x in required)),
("stored RNG",'RandomNumberGenerator.new()' in wheel and 'outcome_rng.seed = outcome_seed' in wheel),
("weighted scoped RNG",'func _weighted_index(rng: RandomNumberGenerator)' in wheel),
("grant scoped RNG",'func _grant(segment: Dictionary, rng: RandomNumberGenerator)' in wheel),
("presenter deterministic",'randi_range(' not in presenter and '_frame_stops(visual_seed' in presenter),
("play visual seed",'play_to(stops, SettingsService.reduced_motion, int(result.get("visual_seed",1)))' in game),
("resume result id",'"result_id":str(result.get("result_id",""))' in game),
("resume migration",'func _normalize_result' in state and '"legacy-migrated"' in state),
("shield fallback visual",'"visual_symbol_id":"gold_medium"' in wheel),
("overlay visual index",'result.get("visual_symbol_index",result.get("segment_index",0))' in game),
("pending before save",'SpinPresentationState.set_pending_result(result, CONFIG_VERSION)' in wheel and 'SaveGame.save_game()' in wheel),
("schema","const SAVE_VERSION := 20" in save),
("config contract",cfg.get("result_contract",{}).get("version")=="spin-result-v1"),
("config fields",all(x in cfg.get("result_contract",{}).get("required_fields",[]) for x in required)),
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/spin_contract").glob("SPINC*.png"))
if len(assets)!=6: errors.append("spin contract asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.40","assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)
