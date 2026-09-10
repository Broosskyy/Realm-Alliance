extends Node

signal village_progression_changed
signal prosperity_level_up(level:int)

const DATA_PATH:="res://data/village_p0_v1_4.json"
const CONFIG_VERSION:="v1.53-village-v2-06"

var config:Dictionary={}
var prosperity_xp:int=0
var prosperity_level:int=1
var forge_crafts:int=0
var claimed_prosperity_levels:Array[int]=[]
var last_goldmine_xp_day:String=""
var last_temple_blessing_day:String=""

func _ready()->void:
	_load()
	_recalculate(false)

func _load()->void:
	var f:=FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f:return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:config=parsed

func progress_cfg()->Dictionary:return config.get("village_progression",{})
func forge_cfg()->Dictionary:return config.get("forge_function",{})

func _utc_day()->String:
	var d:=Time.get_datetime_dict_from_unix_time(ServerClockService.now_unix())
	return "%04d-%02d-%02d" % [int(d.year),int(d.month),int(d.day)]

func max_prosperity()->int:return maxi(int(progress_cfg().get("prosperity_max_level",5)),1)
func thresholds()->Array:return progress_cfg().get("prosperity_thresholds",[0,4,10,18,28])
func xp_for_level(level:int)->int:
	var t:=thresholds()
	return int(t[clampi(level-1,0,t.size()-1)]) if not t.is_empty() else 0
func xp_for_next()->int:
	return xp_for_level(max_prosperity()) if prosperity_level>=max_prosperity() else xp_for_level(prosperity_level+1)
func prosperity_ratio()->float:
	if prosperity_level>=max_prosperity():return 1.0
	var floor:=xp_for_level(prosperity_level);var target:=xp_for_next()
	return 1.0 if target<=floor else clamp(float(prosperity_xp-floor)/float(target-floor),0.0,1.0)

func _add_xp(amount:int)->void:
	if amount<=0:return
	prosperity_xp+=amount
	_recalculate(true)
	village_progression_changed.emit()

func grant_external_xp(source:String, amount:int)->Dictionary:
	var safe_amount := maxi(amount, 0)
	if safe_amount <= 0:
		return {"ok":false,"source":source,"xp":0}
	var before := prosperity_level
	_add_xp(safe_amount)
	SaveGame.save_game()
	return {
		"ok":true,
		"source":source,
		"xp":safe_amount,
		"level_before":before,
		"level_after":prosperity_level,
		"leveled_up":prosperity_level > before
	}

func register_building_upgrade()->void:
	_add_xp(maxi(int(progress_cfg().get("upgrade_xp",2)),0))

func register_goldmine_claim()->void:
	var day:=_utc_day()
	if last_goldmine_xp_day==day:return
	last_goldmine_xp_day=day
	_add_xp(maxi(int(progress_cfg().get("goldmine_daily_xp",1)),0))

func _recalculate(emit_signal:bool)->void:
	var old:=prosperity_level;var lv:=1
	for level in range(1,max_prosperity()+1):
		if prosperity_xp>=xp_for_level(level):lv=level
	prosperity_level=lv
	if emit_signal and prosperity_level>old:prosperity_level_up.emit(prosperity_level)

func max_forge_crafts()->int:return maxi(int(forge_cfg().get("max_crafts",6)),1)
func forge_craft_cap()->int:
	return mini(P0VillageSystem.get_level("forge")*maxi(int(forge_cfg().get("crafts_per_forge_level",2)),1),max_forge_crafts())
func forge_craft_cost()->int:
	if forge_crafts>=max_forge_crafts():return 0
	var costs:Array=forge_cfg().get("costs",[160,260,400,600,850,1150])
	return maxi(int(costs[clampi(forge_crafts,0,costs.size()-1)]),0)
func can_forge_craft()->bool:
	return forge_crafts<forge_craft_cap() and PlayerData.gold>=forge_craft_cost()
func craft_forge_upgrade()->Dictionary:
	if forge_crafts>=max_forge_crafts():return {"ok":false,"message":"Schmiede-Veredelung ist maximal"}
	if forge_crafts>=forge_craft_cap():return {"ok":false,"message":"Schmiede-Gebäude zuerst verbessern"}
	var cost:=forge_craft_cost()
	var damage:=maxi(int(forge_cfg().get("tap_damage_per_craft",2)),0)
	var authority_intent := OnlineAuthorityService.build_intent("village_forge_craft", {
		"craft_before":forge_crafts,
		"craft_after":forge_crafts+1,
		"cost":cost,
		"tap_damage_gain":damage
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,
		cost,
		{"forge_crafts":forge_crafts+1,"tap_damage_gain":damage}
	)
	if not bool(economy_result.get("ok",false)):return {"ok":false,"message":str(economy_result.get("message","Nicht genug Gold"))}
	forge_crafts+=1
	PlayerData.tap_damage+=damage
	PlayerData.stats_changed.emit()
	_add_xp(maxi(int(progress_cfg().get("forge_craft_xp",1)),0))
	SaveGame.save_game()
	return {"ok":true,"craft":forge_crafts,"cost":cost,"tap_damage":damage,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func temple_available()->bool:
	return last_temple_blessing_day!=_utc_day()
func claim_temple_blessing()->Dictionary:
	if not temple_available():return {"ok":false,"message":"Segen heute bereits abgeholt"}
	var spins:=maxi(P0VillageSystem.luck_bonus_spin_amount(),0)
	var blessing_day := _utc_day()
	var authority_intent := OnlineAuthorityService.build_intent("village_temple_blessing", {"day":blessing_day})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"spins":spins},
		{"last_temple_blessing_day":blessing_day}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Segen konnte nicht bestätigt werden"))}
	last_temple_blessing_day=blessing_day
	_add_xp(maxi(int(progress_cfg().get("temple_blessing_xp",1)),0))
	SaveGame.save_game()
	return {"ok":true,"spins":spins,"day":last_temple_blessing_day,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func claimable_prosperity_level()->int:
	var rewards:Dictionary=progress_cfg().get("prosperity_rewards",{})
	for lv in range(2,prosperity_level+1):
		if claimed_prosperity_levels.has(lv):continue
		if not Dictionary(rewards.get(str(lv),{})).is_empty():return lv
	return 0
func can_claim_prosperity()->bool:return claimable_prosperity_level()>0
func claim_prosperity()->Dictionary:
	var lv:=claimable_prosperity_level()
	if lv<=0:return {"ok":false,"message":"Keine Dorf-Belohnung bereit"}
	var reward:=Dictionary(progress_cfg().get("prosperity_rewards",{}).get(str(lv),{})).duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("village_prosperity_reward_claim", {"prosperity_level":lv})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"claimed_prosperity_level":lv}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Dorf-Belohnung konnte nicht bestätigt werden"))}
	claimed_prosperity_levels.append(lv)
	SaveGame.save_game();village_progression_changed.emit()
	return {"ok":true,"level":lv,"reward":reward,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func prosperity_text()->String:
	if prosperity_level>=max_prosperity():return "DORF-WACHSTUM · STUFE %d MAX · %d XP" % [prosperity_level,prosperity_xp]
	return "DORF-WACHSTUM · STUFE %d · %d / %d XP" % [prosperity_level,prosperity_xp,xp_for_next()]
func forge_text()->String:
	if forge_crafts>=max_forge_crafts():return "SCHMIEDE · VEREDLUNG %d / %d · MAX" % [forge_crafts,max_forge_crafts()]
	return "SCHMIEDE · VEREDLUNG %d / %d · %d GOLD" % [forge_crafts,forge_craft_cap(),forge_craft_cost()]
func temple_text()->String:
	return "GLÜCKSTEMPEL · +%d SPINS · %s" % [P0VillageSystem.luck_bonus_spin_amount(),"BEREIT" if temple_available() else "HEUTE ABGEHOLT"]

func export_save_data()->Dictionary:
	return {"prosperity_xp":prosperity_xp,"prosperity_level":prosperity_level,"forge_crafts":forge_crafts,"claimed_prosperity_levels":claimed_prosperity_levels.duplicate(),"last_goldmine_xp_day":last_goldmine_xp_day,"last_temple_blessing_day":last_temple_blessing_day}
func apply_save_data(data:Dictionary)->void:
	prosperity_xp=maxi(int(data.get("prosperity_xp",0)),0)
	forge_crafts=clampi(int(data.get("forge_crafts",0)),0,max_forge_crafts())
	claimed_prosperity_levels.clear()
	for item in data.get("claimed_prosperity_levels",[]):
		var lv:=int(item)
		if lv>=2 and not claimed_prosperity_levels.has(lv):claimed_prosperity_levels.append(lv)
	last_goldmine_xp_day=str(data.get("last_goldmine_xp_day",""))
	last_temple_blessing_day=str(data.get("last_temple_blessing_day",""))
	_recalculate(false);village_progression_changed.emit()
