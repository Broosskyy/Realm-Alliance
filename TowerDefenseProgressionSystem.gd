extends Node

signal td_progression_changed
signal mastery_level_up(level: int)

const CONFIG_PATH := "res://data/tower_defense_v1_29.json"
const CONFIG_VERSION := "v1.49-td-v2-05"

var config: Dictionary = {}
var campaign_stage: int = 1
var mastery_xp: int = 0
var mastery_level: int = 1
var tower_tech_level: int = 1
var claimed_mastery_levels: Array[int] = []
var completed_runs: int = 0

func _ready() -> void:
	_load_config()
	_recalculate_mastery(false)

func _load_config() -> void:
	var f:=FileAccess.open(CONFIG_PATH,FileAccess.READ)
	if not f:
		push_error("Tower Defense V2 config missing")
		return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:
		config=parsed

func progression_config() -> Dictionary:
	return config.get("progression",{})

func campaign_stage_count() -> int:
	return maxi(int(config.get("campaign_stages",6)),1)

func stage_profile(stage_id: int = -1) -> Dictionary:
	var wanted:=campaign_stage if stage_id<0 else stage_id
	for row in config.get("stage_profiles",[]):
		if int(row.get("stage",0))==wanted:
			return row
	return {"stage":wanted,"label":"VERTEIDIGUNG","enemy_hp_bonus":0}

func stage_label() -> String:
	return str(stage_profile().get("label","VERTEIDIGUNG"))

func enemy_hp_bonus() -> int:
	return maxi(int(stage_profile().get("enemy_hp_bonus",0)),0)

func max_mastery_level() -> int:
	return maxi(int(progression_config().get("max_mastery_level",5)),1)

func thresholds() -> Array:
	return progression_config().get("mastery_thresholds",[0,3,8,15,24])

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

func register_wave_clear() -> void:
	mastery_xp += maxi(int(progression_config().get("wave_xp",1)),0)
	_recalculate_mastery(true)
	td_progression_changed.emit()

func register_run_completion() -> void:
	completed_runs += 1
	mastery_xp += maxi(int(progression_config().get("run_xp",2)),0)
	campaign_stage += 1
	if campaign_stage>campaign_stage_count():
		campaign_stage=1
	_recalculate_mastery(true)
	td_progression_changed.emit()

func _recalculate_mastery(emit_signal: bool) -> void:
	var old:=mastery_level
	var new_level:=1
	for level in range(1,max_mastery_level()+1):
		if mastery_xp>=xp_for_level(level):
			new_level=level
	mastery_level=new_level
	if emit_signal and mastery_level>old:
		mastery_level_up.emit(mastery_level)

func max_tower_tech() -> int:
	return maxi(int(progression_config().get("max_tower_tech",4)),1)

func tower_damage_bonus() -> int:
	return maxi((tower_tech_level-1) * int(progression_config().get("tower_tech_damage_bonus",1)),0)

func tower_tech_cost() -> int:
	if tower_tech_level>=max_tower_tech():
		return 0
	var costs: Array=progression_config().get("tower_tech_costs",[0,300,650,1100])
	var idx:=clampi(tower_tech_level,0,costs.size()-1)
	return maxi(int(costs[idx]),0)

func can_upgrade_tower_tech() -> bool:
	return tower_tech_level<max_tower_tech() and PlayerData.gold>=tower_tech_cost()

func upgrade_tower_tech() -> Dictionary:
	if tower_tech_level>=max_tower_tech():
		return {"ok":false,"message":"Turm-Technik ist bereits maximal"}
	var cost:=tower_tech_cost()
	if PlayerData.gold<cost:
		return {"ok":false,"message":"Nicht genug Gold"}
	var authority_intent := OnlineAuthorityService.build_intent("tower_tech_upgrade", {
		"from_level":tower_tech_level,"to_level":tower_tech_level+1,"cost":cost
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,cost,{"tower_tech_level":tower_tech_level+1}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Nicht genug Gold"))}
	tower_tech_level += 1
	SaveGame.save_game()
	td_progression_changed.emit()
	return {"ok":true,"level":tower_tech_level,"cost":cost,"damage_bonus":tower_damage_bonus(),"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

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
		return {"ok":false,"message":"Keine Defense-Mastery-Belohnung bereit"}
	var rewards: Dictionary=progression_config().get("mastery_rewards",{})
	var reward:=Dictionary(rewards.get(str(level),{})).duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("tower_defense_mastery_reward_claim", {"mastery_level":level})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"claimed_mastery_level":level}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Belohnung konnte nicht bestätigt werden"))}
	claimed_mastery_levels.append(level)
	SaveGame.save_game()
	td_progression_changed.emit()
	return {"ok":true,"level":level,"reward":reward,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func stage_text() -> String:
	return "STUFE %d / %d · %s" % [campaign_stage,campaign_stage_count(),stage_label()]

func mastery_text() -> String:
	if mastery_level>=max_mastery_level():
		return "VERTEIDIGUNGS-FORTSCHRITT · STUFE %d MAX · %d PUNKTE" % [mastery_level,mastery_xp]
	return "VERTEIDIGUNGS-FORTSCHRITT · STUFE %d · %d / %d" % [mastery_level,mastery_xp,xp_for_next_level()]

func tech_text() -> String:
	if tower_tech_level>=max_tower_tech():
		return "TURM-TECHNIK · STUFE %d MAX · +%d SCHADEN" % [tower_tech_level,tower_damage_bonus()]
	return "TURM-TECHNIK · STUFE %d · +%d SCHADEN · %d GOLD" % [tower_tech_level,tower_damage_bonus(),tower_tech_cost()]

func export_save_data() -> Dictionary:
	return {
		"campaign_stage":campaign_stage,
		"mastery_xp":mastery_xp,
		"mastery_level":mastery_level,
		"tower_tech_level":tower_tech_level,
		"claimed_mastery_levels":claimed_mastery_levels.duplicate(),
		"completed_runs":completed_runs
	}

func apply_save_data(data: Dictionary) -> void:
	campaign_stage=clampi(int(data.get("campaign_stage",1)),1,campaign_stage_count())
	mastery_xp=maxi(int(data.get("mastery_xp",0)),0)
	tower_tech_level=clampi(int(data.get("tower_tech_level",1)),1,max_tower_tech())
	claimed_mastery_levels.clear()
	for item in data.get("claimed_mastery_levels",[]):
		var level:=int(item)
		if level>=2 and not claimed_mastery_levels.has(level):
			claimed_mastery_levels.append(level)
	completed_runs=maxi(int(data.get("completed_runs",0)),0)
	_recalculate_mastery(false)
	td_progression_changed.emit()
