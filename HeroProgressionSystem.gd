extends Node

signal hero_progression_changed
signal hero_mastery_level_up(hero_id: String, level: int)

const DATA_PATH := "res://data/heroes.json"
var config:Dictionary={}
var mastery_xp:Dictionary={"knight":0,"archer":0,"mage":0}
var mastery_level:Dictionary={"knight":1,"archer":1,"mage":1}
var normal_defeat_counter:Dictionary={"knight":0,"archer":0,"mage":0}
var claimed_mastery_rewards:Dictionary={"knight":[],"archer":[],"mage":[]}
var specialization_enabled:Dictionary={"knight":false,"archer":false,"mage":false}

func _ready()->void:
	_load()
	_recalculate_all(false)

func _load()->void:
	var f:=FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f:return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:config=parsed

func mastery_cfg()->Dictionary:return config.get("mastery",{})
func max_mastery()->int:return maxi(int(mastery_cfg().get("max_level",5)),1)
func thresholds()->Array:return mastery_cfg().get("thresholds",[0,5,14,28,48])
func xp_for_level(level:int)->int:
	var t:=thresholds()
	return int(t[clampi(level-1,0,t.size()-1)]) if not t.is_empty() else 0
func xp_for_next(hero_id:String)->int:
	var lv:=int(mastery_level.get(hero_id,1))
	return xp_for_level(max_mastery()) if lv>=max_mastery() else xp_for_level(lv+1)
func mastery_ratio(hero_id:String)->float:
	var lv:=int(mastery_level.get(hero_id,1))
	if lv>=max_mastery():return 1.0
	var floor:=xp_for_level(lv);var target:=xp_for_next(hero_id)
	return 1.0 if target<=floor else clamp(float(int(mastery_xp.get(hero_id,0))-floor)/float(target-floor),0.0,1.0)

func register_monster_defeat(result:Dictionary)->void:
	var hero_id:=HeroSystem.get_selected_hero_id()
	if not HeroSystem.is_unlocked(hero_id):return
	var add:=0
	if bool(result.get("boss",false)):
		add=maxi(int(mastery_cfg().get("boss_defeat_xp",2)),0)
	else:
		normal_defeat_counter[hero_id]=int(normal_defeat_counter.get(hero_id,0))+1
		var every:=maxi(int(mastery_cfg().get("normal_defeat_every",10)),1)
		if int(normal_defeat_counter[hero_id])>=every:
			normal_defeat_counter[hero_id]=0
			add=1
	if add>0:
		mastery_xp[hero_id]=int(mastery_xp.get(hero_id,0))+add
		_recalculate(hero_id,true)
		hero_progression_changed.emit()
		SaveGame.save_game()

func _recalculate(hero_id:String,emit_signal:bool)->void:
	var old:=int(mastery_level.get(hero_id,1));var new_level:=1
	for lv in range(1,max_mastery()+1):
		if int(mastery_xp.get(hero_id,0))>=xp_for_level(lv):new_level=lv
	mastery_level[hero_id]=new_level
	if emit_signal and new_level>old:hero_mastery_level_up.emit(hero_id,new_level)
func _recalculate_all(emit_signal:bool)->void:
	for id in mastery_xp.keys():_recalculate(str(id),emit_signal)

func specialization(hero_id:String)->Dictionary:return config.get("specializations",{}).get(hero_id,{})
func specialization_unlocked(hero_id:String)->bool:
	return int(mastery_level.get(hero_id,1))>=int(specialization(hero_id).get("unlock_mastery",999))
func toggle_specialization(hero_id:String)->Dictionary:
	if not specialization_unlocked(hero_id):return {"ok":false,"message":"Spezialisierung noch gesperrt"}
	specialization_enabled[hero_id]=not bool(specialization_enabled.get(hero_id,false))
	SaveGame.save_game();hero_progression_changed.emit()
	return {"ok":true,"enabled":bool(specialization_enabled[hero_id]),"label":str(specialization(hero_id).get("label","SPEZIALISIERUNG"))}
func specialization_power_bonus(hero_id:String)->int:
	if not bool(specialization_enabled.get(hero_id,false)):return 0
	return maxi(int(specialization(hero_id).get("power_bonus",0)),0)

func claimable_level(hero_id:String)->int:
	var rewards:Dictionary=mastery_cfg().get("rewards",{})
	var claimed:Array=claimed_mastery_rewards.get(hero_id,[])
	for lv in range(2,int(mastery_level.get(hero_id,1))+1):
		if claimed.has(lv):continue
		if not Dictionary(rewards.get(str(lv),{})).is_empty():return lv
	return 0
func can_claim(hero_id:String)->bool:return claimable_level(hero_id)>0
func claim(hero_id:String)->Dictionary:
	var lv:=claimable_level(hero_id)
	if lv<=0:return {"ok":false,"message":"Keine Hero-Mastery-Belohnung bereit"}
	var reward:=Dictionary(mastery_cfg().get("rewards",{}).get(str(lv),{})).duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("hero_mastery_reward_claim", {
		"hero_id":hero_id,
		"mastery_level":lv
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"hero_id":hero_id,"claimed_mastery_level":lv}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Belohnung konnte nicht bestätigt werden"))}
	var claimed:Array=claimed_mastery_rewards.get(hero_id,[])
	claimed.append(lv);claimed_mastery_rewards[hero_id]=claimed
	SaveGame.save_game();hero_progression_changed.emit()
	return {
		"ok":true,
		"level":lv,
		"reward":reward,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0))
	}

func mastery_text(hero_id:String)->String:
	var lv:=int(mastery_level.get(hero_id,1));var xp:=int(mastery_xp.get(hero_id,0))
	if lv>=max_mastery():return "HELDEN-FORTSCHRITT · STUFE %d MAX · %d PUNKTE" % [lv,xp]
	return "HELDEN-FORTSCHRITT · STUFE %d · %d / %d" % [lv,xp,xp_for_next(hero_id)]
func specialization_text(hero_id:String)->String:
	var spec:=specialization(hero_id);var label:=str(spec.get("label","SPEZIALISIERUNG"))
	if not specialization_unlocked(hero_id):return "%s · AB FORTSCHRITT %d" % [label,int(spec.get("unlock_mastery",2))]
	return "%s · %s · +%d STÄRKE" % [label,"AKTIV" if bool(specialization_enabled.get(hero_id,false)) else "BEREIT",int(spec.get("power_bonus",0))]

func export_save_data()->Dictionary:
	return {"mastery_xp":mastery_xp.duplicate(true),"mastery_level":mastery_level.duplicate(true),"normal_defeat_counter":normal_defeat_counter.duplicate(true),"claimed_mastery_rewards":claimed_mastery_rewards.duplicate(true),"specialization_enabled":specialization_enabled.duplicate(true)}
func apply_save_data(data:Dictionary)->void:
	for field in ["mastery_xp","normal_defeat_counter","specialization_enabled"]:
		var incoming=data.get(field,{})
		if typeof(incoming)==TYPE_DICTIONARY:
			var target:Dictionary=get(field)
			for id in incoming:target[str(id)]=incoming[id]
	var claims=data.get("claimed_mastery_rewards",{})
	if typeof(claims)==TYPE_DICTIONARY:
		for id in claims:
			var clean:Array=[]
			for item in claims[id]:
				var lv:=int(item)
				if lv>=2 and not clean.has(lv):clean.append(lv)
			claimed_mastery_rewards[str(id)]=clean
	_recalculate_all(false);hero_progression_changed.emit()
