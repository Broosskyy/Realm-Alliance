extends Node

signal lane_progression_changed
signal mastery_level_up(level: int)

const CONFIG_PATH := "res://data/lane_battle_v1_30.json"
var config: Dictionary = {}
var campaign_stage:=1
var mastery_xp:=0
var mastery_level:=1
var unit_tech_level:=1
var claimed_mastery_levels:Array[int]=[]
var completed_wins:=0
var deployments_total:=0

func _ready()->void:
	_load_config()
	_recalculate(false)

func _load_config()->void:
	var f:=FileAccess.open(CONFIG_PATH,FileAccess.READ)
	if not f: return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY: config=parsed

func progression()->Dictionary: return config.get("progression",{})
func stage_count()->int: return maxi(int(config.get("campaign_stages",6)),1)

func stage_profile(stage_id:int=-1)->Dictionary:
	var wanted:=campaign_stage if stage_id<0 else stage_id
	for row in config.get("stage_profiles",[]):
		if int(row.get("stage",0))==wanted: return row
	return {"stage":wanted,"label":"ANGRIFF","enemy_hp_bonus":0,"pressure_bonus":0.0}

func stage_label()->String: return str(stage_profile().get("label","ANGRIFF"))
func enemy_hp_bonus()->float: return maxf(float(stage_profile().get("enemy_hp_bonus",0)),0.0)
func pressure_bonus()->float: return maxf(float(stage_profile().get("pressure_bonus",0.0)),0.0)

func max_mastery()->int: return maxi(int(progression().get("max_mastery_level",5)),1)
func thresholds()->Array: return progression().get("mastery_thresholds",[0,3,8,15,24])
func xp_for_level(level:int)->int:
	var t:=thresholds()
	return int(t[clampi(level-1,0,t.size()-1)]) if not t.is_empty() else 0
func xp_for_next_level()->int:
	return xp_for_level(max_mastery()) if mastery_level>=max_mastery() else xp_for_level(mastery_level+1)
func mastery_ratio()->float:
	if mastery_level>=max_mastery(): return 1.0
	var floor:=xp_for_level(mastery_level)
	var target:=xp_for_next_level()
	return 1.0 if target<=floor else clamp(float(mastery_xp-floor)/float(target-floor),0.0,1.0)

func register_deployment()->void:
	deployments_total+=1
	var every:=maxi(int(progression().get("deployment_xp_every",4)),1)
	if deployments_total % every==0:
		mastery_xp+=1
		_recalculate(true)
	lane_progression_changed.emit()

func register_win()->void:
	completed_wins+=1
	mastery_xp+=maxi(int(progression().get("win_xp",3)),0)
	campaign_stage+=1
	if campaign_stage>stage_count(): campaign_stage=1
	_recalculate(true)
	lane_progression_changed.emit()

func _recalculate(emit_signal:bool)->void:
	var old:=mastery_level
	var new_level:=1
	for level in range(1,max_mastery()+1):
		if mastery_xp>=xp_for_level(level): new_level=level
	mastery_level=new_level
	if emit_signal and mastery_level>old: mastery_level_up.emit(mastery_level)

func max_unit_tech()->int: return maxi(int(progression().get("max_unit_tech",4)),1)
func unit_power_bonus()->float:
	return maxf(float(unit_tech_level-1)*float(progression().get("unit_power_bonus",0.8)),0.0)
func unit_tech_cost()->int:
	if unit_tech_level>=max_unit_tech(): return 0
	var costs:Array=progression().get("unit_tech_costs",[0,350,700,1200])
	return maxi(int(costs[clampi(unit_tech_level,0,costs.size()-1)]),0)
func can_upgrade_unit_tech()->bool:
	return unit_tech_level<max_unit_tech() and PlayerData.gold>=unit_tech_cost()
func upgrade_unit_tech()->Dictionary:
	if unit_tech_level>=max_unit_tech(): return {"ok":false,"message":"Einheiten-Technik ist maximal"}
	var cost:=unit_tech_cost()
	var authority_intent := OnlineAuthorityService.build_intent("lane_unit_tech_upgrade", {
		"from_level":unit_tech_level,"to_level":unit_tech_level+1,"cost":cost
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,cost,{"unit_tech_level":unit_tech_level+1}
	)
	if not bool(economy_result.get("ok",false)): return {"ok":false,"message":str(economy_result.get("message","Nicht genug Gold"))}
	unit_tech_level+=1
	SaveGame.save_game()
	lane_progression_changed.emit()
	return {"ok":true,"level":unit_tech_level,"cost":cost,"power_bonus":unit_power_bonus(),"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func claimable_mastery_level()->int:
	var rewards:Dictionary=progression().get("mastery_rewards",{})
	for level in range(2,mastery_level+1):
		if claimed_mastery_levels.has(level): continue
		if not Dictionary(rewards.get(str(level),{})).is_empty(): return level
	return 0
func can_claim_mastery_reward()->bool: return claimable_mastery_level()>0
func claim_mastery_reward()->Dictionary:
	var level:=claimable_mastery_level()
	if level<=0: return {"ok":false,"message":"Noch keine Angriffs-Belohnung bereit"}
	var reward:=Dictionary(progression().get("mastery_rewards",{}).get(str(level),{})).duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("lane_mastery_reward_claim", {"mastery_level":level})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"claimed_mastery_level":level}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Belohnung konnte nicht bestätigt werden"))}
	claimed_mastery_levels.append(level)
	SaveGame.save_game()
	lane_progression_changed.emit()
	return {"ok":true,"level":level,"reward":reward,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func stage_text()->String: return "STUFE %d / %d · %s" % [campaign_stage,stage_count(),stage_label()]
func mastery_text()->String:
	if mastery_level>=max_mastery(): return "ANGRIFF-FORTSCHRITT · STUFE %d MAX · %d PUNKTE" % [mastery_level,mastery_xp]
	return "ANGRIFF-FORTSCHRITT · STUFE %d · %d / %d" % [mastery_level,mastery_xp,xp_for_next_level()]
func tech_text()->String:
	if unit_tech_level>=max_unit_tech(): return "EINHEITEN · STUFE %d MAX · +%.1f KRAFT" % [unit_tech_level,unit_power_bonus()]
	return "EINHEITEN · STUFE %d · +%.1f KRAFT · %d GOLD" % [unit_tech_level,unit_power_bonus(),unit_tech_cost()]

func export_save_data()->Dictionary:
	return {"campaign_stage":campaign_stage,"mastery_xp":mastery_xp,"mastery_level":mastery_level,"unit_tech_level":unit_tech_level,"claimed_mastery_levels":claimed_mastery_levels.duplicate(),"completed_wins":completed_wins,"deployments_total":deployments_total}
func apply_save_data(data:Dictionary)->void:
	campaign_stage=clampi(int(data.get("campaign_stage",1)),1,stage_count())
	mastery_xp=maxi(int(data.get("mastery_xp",0)),0)
	unit_tech_level=clampi(int(data.get("unit_tech_level",1)),1,max_unit_tech())
	claimed_mastery_levels.clear()
	for item in data.get("claimed_mastery_levels",[]):
		var level:=int(item)
		if level>=2 and not claimed_mastery_levels.has(level): claimed_mastery_levels.append(level)
	completed_wins=maxi(int(data.get("completed_wins",0)),0)
	deployments_total=maxi(int(data.get("deployments_total",0)),0)
	_recalculate(false)
	lane_progression_changed.emit()
