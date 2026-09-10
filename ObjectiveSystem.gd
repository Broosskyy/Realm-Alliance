extends Node

signal objectives_changed
const DATA_PATH:="res://data/objectives_v1_52.json"
const CONFIG_VERSION:="v1.52-objectives-v2-05"
var config:Dictionary={}
var lifetime:Dictionary={}
var daily:Dictionary={}
var weekly:Dictionary={}
var daily_claimed:Array[String]=[]
var weekly_claimed:Array[String]=[]
var achievement_claimed:Array[String]=[]
var collection_claimed:bool=false
var bestiary:Array[String]=[]
var daily_bucket:String=""
var weekly_bucket:String=""

func _ready()->void:
	_load();_roll_periods(false)

func _load()->void:
	var f:=FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f:return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:config=parsed

func _utc_day()->String:
	var d:=Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [int(d.year),int(d.month),int(d.day)]
func _week_bucket()->String:
	var unix:=int(Time.get_unix_time_from_system())
	var d:=Time.get_datetime_dict_from_unix_time(unix)
	var weekday:=int(d.weekday) # Sunday=0
	var since_monday:=(weekday+6)%7
	return str((unix-since_monday*86400)/604800)

func _roll_periods(save:bool=true)->void:
	var day:=_utc_day();var week:=_week_bucket();var changed:=false
	if daily_bucket!=day:
		daily_bucket=day;daily.clear();daily_claimed.clear();changed=true
	if weekly_bucket!=week:
		weekly_bucket=week;weekly.clear();weekly_claimed.clear();changed=true
	if changed:
		objectives_changed.emit()
		if save:SaveGame.save_game()

func register_action(metric:String,amount:int=1,context:Dictionary={})->void:
	if metric.is_empty() or amount<=0:return
	_roll_periods(false)
	lifetime[metric]=int(lifetime.get(metric,0))+amount
	daily[metric]=int(daily.get(metric,0))+amount
	weekly[metric]=int(weekly.get(metric,0))+amount
	if metric in ["monster_defeat","boss_defeat","spin","journey_lap","puzzle_complete","td_win","lane_win","village_upgrade","goldmine_claim","forge_craft","temple_blessing"]:
		daily["pillar_action"]=int(daily.get("pillar_action",0))+1
		weekly["pillar_action"]=int(weekly.get("pillar_action",0))+1
		lifetime["pillar_action"]=int(lifetime.get("pillar_action",0))+1
	if metric=="monster_defeat":
		var encounter:=str(context.get("encounter_id",""))
		if not encounter.is_empty() and not bestiary.has(encounter):bestiary.append(encounter)
	objectives_changed.emit();SaveGame.save_game()

func defs(category:String)->Array:return config.get(category,[])
func progress_for(category:String,metric:String)->int:
	_roll_periods(false)
	if category=="daily":return int(daily.get(metric,0))
	if category=="weekly":return int(weekly.get(metric,0))
	return int(lifetime.get(metric,0))
func claimed_for(category:String)->Array:
	if category=="daily":return daily_claimed
	if category=="weekly":return weekly_claimed
	return achievement_claimed
func row_state(category:String,def:Dictionary)->Dictionary:
	var id:=str(def.get("id",""));var metric:=str(def.get("metric",""));var target:=maxi(int(def.get("target",1)),1)
	var value:=mini(progress_for(category,metric),target);var claimed:=claimed_for(category).has(id)
	return {"id":id,"title":str(def.get("title",id)),"value":value,"target":target,"ready":value>=target and not claimed,"claimed":claimed,"reward":def.get("reward",{})}
func rows(category:String)->Array:
	var out:Array=[]
	for def in defs(category):out.append(row_state(category,def))
	return out

func _grant(reward:Dictionary)->void:
	if int(reward.get("gold",0))>0:PlayerData.add_gold(int(reward.get("gold",0)))
	if int(reward.get("spins",0))>0:PlayerData.add_spin(int(reward.get("spins",0)))
	if int(reward.get("realm_keys",0))>0:MetaProgressSystem.grant_realm_keys(int(reward.get("realm_keys",0)))
func claim(category:String,id:String)->Dictionary:
	for def in defs(category):
		if str(def.get("id",""))!=id:continue
		var state:=row_state(category,def)
		if not bool(state.ready):return {"ok":false}
		_grant(state.reward)
		var target:=claimed_for(category);target.append(id)
		SaveGame.save_game();objectives_changed.emit()
		return {"ok":true,"title":str(state.title),"reward":state.reward,"objective_id":id}
	return {"ok":false}
func collection_state()->Dictionary:
	var c:Dictionary=config.get("collection",{});var target:=maxi(int(c.get("target_unique",5)),1)
	return {"id":str(c.get("id","collection")),"title":str(c.get("title","SAMMLUNG")),"value":mini(bestiary.size(),target),"target":target,"ready":bestiary.size()>=target and not collection_claimed,"claimed":collection_claimed,"reward":c.get("reward",{})}
func claim_collection()->Dictionary:
	var state:=collection_state()
	if not bool(state.ready):return {"ok":false}
	_grant(state.reward);collection_claimed=true;SaveGame.save_game();objectives_changed.emit()
	return {"ok":true,"title":str(state.title),"reward":state.reward,"objective_id":str(state.id)}

func summary()->String:
	var ready:=0
	for cat in ["daily","weekly","achievements"]:
		for row in rows(cat):
			if bool(row.ready):ready+=1
	if bool(collection_state().ready):ready+=1
	return "AUFGABEN · ERFOLGE · SAMMLUNG · %d BEREIT" % ready

func export_save_data()->Dictionary:
	return {"lifetime":lifetime.duplicate(true),"daily":daily.duplicate(true),"weekly":weekly.duplicate(true),"daily_claimed":daily_claimed.duplicate(),"weekly_claimed":weekly_claimed.duplicate(),"achievement_claimed":achievement_claimed.duplicate(),"collection_claimed":collection_claimed,"bestiary":bestiary.duplicate(),"daily_bucket":daily_bucket,"weekly_bucket":weekly_bucket}
func apply_save_data(data:Dictionary)->void:
	for key in ["lifetime","daily","weekly"]:
		var incoming=data.get(key,{})
		if typeof(incoming)==TYPE_DICTIONARY:set(key,incoming.duplicate(true))
	daily_claimed.clear();weekly_claimed.clear();achievement_claimed.clear();bestiary.clear()
	for id in data.get("daily_claimed",[]):daily_claimed.append(str(id))
	for id in data.get("weekly_claimed",[]):weekly_claimed.append(str(id))
	for id in data.get("achievement_claimed",[]):achievement_claimed.append(str(id))
	for id in data.get("bestiary",[]):
		var clean:=str(id)
		if not clean.is_empty() and not bestiary.has(clean):bestiary.append(clean)
	collection_claimed=bool(data.get("collection_claimed",false))
	daily_bucket=str(data.get("daily_bucket",""));weekly_bucket=str(data.get("weekly_bucket",""))
	_roll_periods(false);objectives_changed.emit()
