extends Node

signal puzzle_progression_changed
signal mastery_level_up(level: int)

const CONFIG_PATH := "res://data/puzzle_v1_28.json"
const CONFIG_VERSION := "v1.48-puzzle-v2-04"

var config: Dictionary = {}
var stage: int = 1
var mastery_xp: int = 0
var mastery_level: int = 1
var claimed_mastery_levels: Array[int] = []
var completions: int = 0

func _ready() -> void:
	_load_config()
	_recalculate_mastery(false)

func _load_config() -> void:
	var f:=FileAccess.open(CONFIG_PATH,FileAccess.READ)
	if not f:
		push_error("Puzzle V2 config missing")
		return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:
		config=parsed

func progression_config() -> Dictionary:
	return config.get("puzzle_progression",{})

func stage_count() -> int:
	return maxi(int(progression_config().get("stage_count",8)),1)

func stage_profile(stage_id: int = -1) -> Dictionary:
	var wanted:=stage if stage_id<0 else stage_id
	for row in progression_config().get("stage_objectives",[]):
		if int(row.get("stage",0))==wanted:
			return row
	return {"stage":wanted,"target_matches":3,"label":"PUZZLE"}

func target_matches() -> int:
	return maxi(int(stage_profile().get("target_matches",3)),1)

func stage_label() -> String:
	return str(stage_profile().get("label","PUZZLE"))

func max_mastery_level() -> int:
	return maxi(int(progression_config().get("max_mastery_level",5)),1)

func thresholds() -> Array:
	return progression_config().get("mastery_thresholds",[0,4,10,18,28])

func xp_for_level(level: int) -> int:
	var t:=thresholds()
	if t.is_empty(): return 0
	return int(t[clampi(level-1,0,t.size()-1)])

func xp_for_next_level() -> int:
	if mastery_level>=max_mastery_level():
		return xp_for_level(max_mastery_level())
	return xp_for_level(mastery_level+1)

func mastery_ratio() -> float:
	if mastery_level>=max_mastery_level():
		return 1.0
	var floor:=xp_for_level(mastery_level)
	var target:=xp_for_next_level()
	if target<=floor: return 1.0
	return clamp(float(mastery_xp-floor)/float(target-floor),0.0,1.0)

func register_match() -> void:
	mastery_xp += maxi(int(progression_config().get("match_xp",1)),0)
	_recalculate_mastery(true)
	puzzle_progression_changed.emit()

func register_completion() -> void:
	completions += 1
	mastery_xp += maxi(int(progression_config().get("completion_xp",2)),0)
	stage += 1
	if stage>stage_count():
		stage=1
	_recalculate_mastery(true)
	puzzle_progression_changed.emit()

func _recalculate_mastery(emit_signal: bool) -> void:
	var old:=mastery_level
	var new_level:=1
	for level in range(1,max_mastery_level()+1):
		if mastery_xp>=xp_for_level(level):
			new_level=level
	mastery_level=new_level
	if emit_signal and mastery_level>old:
		mastery_level_up.emit(mastery_level)

func claimable_mastery_level() -> int:
	var rewards: Dictionary=progression_config().get("mastery_rewards",{})
	for level in range(2,mastery_level+1):
		if claimed_mastery_levels.has(level): continue
		if not Dictionary(rewards.get(str(level),{})).is_empty():
			return level
	return 0

func can_claim_mastery_reward() -> bool:
	return claimable_mastery_level()>0

func claim_mastery_reward() -> Dictionary:
	var level:=claimable_mastery_level()
	if level<=0:
		return {"ok":false,"message":"Keine Puzzle-Mastery-Belohnung bereit"}
	var rewards: Dictionary=progression_config().get("mastery_rewards",{})
	var reward:=Dictionary(rewards.get(str(level),{})).duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("puzzle_mastery_reward_claim", {"mastery_level":level})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"claimed_mastery_level":level}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Belohnung konnte nicht bestätigt werden"))}
	claimed_mastery_levels.append(level)
	SaveGame.save_game()
	puzzle_progression_changed.emit()
	return {"ok":true,"level":level,"reward":reward,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func stage_text() -> String:
	return "STUFE %d / %d · %s" % [stage,stage_count(),stage_label()]

func mastery_text() -> String:
	if mastery_level>=max_mastery_level():
		return "PUZZLE-FORTSCHRITT · STUFE %d MAX · %d PUNKTE" % [mastery_level,mastery_xp]
	return "PUZZLE-FORTSCHRITT · STUFE %d · %d / %d" % [mastery_level,mastery_xp,xp_for_next_level()]

func export_save_data() -> Dictionary:
	return {
		"stage":stage,
		"mastery_xp":mastery_xp,
		"mastery_level":mastery_level,
		"claimed_mastery_levels":claimed_mastery_levels.duplicate(),
		"completions":completions
	}

func apply_save_data(data: Dictionary) -> void:
	stage=clampi(int(data.get("stage",1)),1,stage_count())
	mastery_xp=maxi(int(data.get("mastery_xp",0)),0)
	claimed_mastery_levels.clear()
	for item in data.get("claimed_mastery_levels",[]):
		var level:=int(item)
		if level>=2 and not claimed_mastery_levels.has(level):
			claimed_mastery_levels.append(level)
	completions=maxi(int(data.get("completions",0)),0)
	_recalculate_mastery(false)
	puzzle_progression_changed.emit()
