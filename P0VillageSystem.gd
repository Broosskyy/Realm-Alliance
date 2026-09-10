extends Node

signal building_changed(building_id: String)
signal village_changed
signal goldmine_claimed(amount: int)

const DATA_PATH := "res://data/village_p0_v1_4.json"

var defs: Dictionary = {}
var levels := {
	"townhall": 1,
	"goldmine": 1,
	"forge": 1,
	"lucktemple": 1
}
var last_goldmine_claim_unix: int = 0
var upgrade_transaction_active: bool = false
var claim_transaction_active: bool = false
var upgrade_sequence:int=0
var pending_upgrade_result:Dictionary={}

func _ready() -> void:
	_load_defs()
	if last_goldmine_claim_unix <= 0:
		last_goldmine_claim_unix = ServerClockService.now_unix()

func _load_defs() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		push_error("Village data missing")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Village data invalid")
		return
	for building in parsed.get("buildings", []):
		defs[str(building.get("id",""))] = building

func get_level(building_id: String) -> int:
	return int(levels.get(building_id, 1))

func get_def(building_id: String) -> Dictionary:
	return defs.get(building_id, {})

func get_level_def(building_id: String) -> Dictionary:
	var definition: Dictionary = get_def(building_id)
	var level := get_level(building_id)
	for entry in definition.get("levels", []):
		if int(entry.get("level",0)) == level:
			return entry
	return {}

func get_cost(building_id: String) -> int:
	return int(get_level_def(building_id).get("cost_to_next", 0))

func get_building_name(building_id: String) -> String:
	return str(get_def(building_id).get("name", building_id))

func get_effect(building_id: String) -> String:
	return str(get_level_def(building_id).get("effect", ""))

func is_max(building_id: String) -> bool:
	return get_level(building_id) >= 3

func master_asset_id(building_id: String) -> String:
	var prefix: String = str({
		"townhall":"V001_TOWNHALL",
		"goldmine":"V002_GOLDMINE",
		"forge":"V003_FORGE",
		"lucktemple":"V004_LUCKTEMPLE"
	}.get(building_id, ""))
	return "%s_LV%d" % [prefix, get_level(building_id)]

func can_upgrade(building_id:String)->Dictionary:
	if is_max(building_id):
		return {"ok":false,"message":"Maximale Stufe"}
	var next_level:=get_level(building_id)+1
	if building_id!="townhall" and next_level>P0VillageSystem.get_level("townhall"):
		return {"ok":false,"message":"Rathaus zuerst auf Lv.%d verbessern" % next_level}
	var cost:=get_cost(building_id)
	if PlayerData.gold<cost:
		return {"ok":false,"message":"Nicht genug Gold","missing":maxi(cost-PlayerData.gold,0)}
	return {"ok":true,"cost":cost,"next_level":next_level}

func upgrade(building_id: String) -> Dictionary:
	if upgrade_transaction_active:
		return {"ok":false,"message":"Upgrade wird bereits verarbeitet"}
	var validation:=can_upgrade(building_id)
	if not bool(validation.get("ok",false)):
		return validation

	var from_level:=get_level(building_id)
	var cost:=get_cost(building_id)
	upgrade_transaction_active=true
	var authority_intent := OnlineAuthorityService.build_intent("village_upgrade", {
		"building_id":building_id,
		"from_level":from_level,
		"to_level":from_level+1,
		"cost":cost
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,
		cost,
		{"building_id":building_id,"to_level":from_level+1}
	)
	if not bool(economy_result.get("ok",false)):
		upgrade_transaction_active=false
		return {"ok":false,"message":str(economy_result.get("message","Nicht genug Gold"))}

	levels[building_id]=from_level+1
	_apply_effect(building_id)
	VillageProgressionSystem.register_building_upgrade()
	upgrade_sequence+=1
	var result={
		"ok":true,
		"upgrade_id":"village_%d_%s_%d" % [ServerClockService.now_unix(),building_id,upgrade_sequence],
		"config_version":"v1.53-village-v2-06",
		"result_contract_version":"village-upgrade-result-v1",
		"building_id":building_id,
		"from_level":from_level,
		"to_level":get_level(building_id),
		"level":get_level(building_id),
		"name":get_building_name(building_id),
		"cost":cost,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0)),
		"presentation_pending":true
	}
	pending_upgrade_result=result.duplicate(true)
	SaveGame.save_game()
	building_changed.emit(building_id)
	village_changed.emit()
	upgrade_transaction_active=false
	return result

func has_pending_upgrade_result()->bool:
	return not pending_upgrade_result.is_empty()

func peek_pending_upgrade_result()->Dictionary:
	return pending_upgrade_result.duplicate(true)

func acknowledge_pending_upgrade_result()->void:
	if pending_upgrade_result.is_empty():return
	pending_upgrade_result={}
	SaveGame.save_game()


func _apply_effect(building_id: String) -> void:
	match building_id:
		"townhall":
			PlayerData.village_level = max(PlayerData.village_level, get_level(building_id))
			PlayerData.progression_changed.emit()
		"forge":
			PlayerData.tap_damage += 5
			PlayerData.stats_changed.emit()
		"goldmine":
			pass
		"lucktemple":
			pass

func goldmine_rate_per_minute() -> int:
	return int(get_level_def("goldmine").get("gold_per_minute", 30))

func goldmine_cap_minutes() -> int:
	return int(get_level_def("goldmine").get("claim_cap_minutes", 30))

func pending_goldmine_gold(now_unix: int = 0) -> int:
	if now_unix <= 0:
		now_unix = ServerClockService.now_unix()
	if last_goldmine_claim_unix <= 0:
		return 0
	var elapsed_seconds := maxi(now_unix - last_goldmine_claim_unix, 0)
	var capped_seconds := mini(elapsed_seconds, goldmine_cap_minutes() * 60)
	return int(floor(float(capped_seconds) / 60.0 * float(goldmine_rate_per_minute())))

func seconds_until_next_gold() -> int:
	if pending_goldmine_gold() > 0:
		return 0
	var now := ServerClockService.now_unix()
	var elapsed := maxi(now - last_goldmine_claim_unix, 0)
	return maxi(60 - (elapsed % 60), 0)

func claim_goldmine() -> Dictionary:
	if claim_transaction_active:
		return {"ok":false,"amount":0,"message":"Abholung wird bereits verarbeitet"}
	var now := ServerClockService.now_unix()
	var amount := pending_goldmine_gold(now)
	if amount <= 0:
		return {"ok":false,"amount":0,"message":"Goldmine produziert noch"}

	claim_transaction_active = true
	var authority_intent := OnlineAuthorityService.build_intent("goldmine_claim", {
		"claim_unix":now,
		"last_claim_unix":last_goldmine_claim_unix,
		"goldmine_level":get_level("goldmine"),
		"calculated_amount":amount
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":amount},
		{"last_goldmine_claim_unix":now}
	)
	if not bool(economy_result.get("ok",false)):
		claim_transaction_active = false
		return {"ok":false,"amount":0,"message":str(economy_result.get("message","Abholung konnte nicht bestätigt werden"))}
	last_goldmine_claim_unix = now
	VillageProgressionSystem.register_goldmine_claim()
	SaveGame.save_game()
	goldmine_claimed.emit(amount)
	village_changed.emit()
	claim_transaction_active = false
	return {"ok":true,"amount":amount,"message":"+%d Gold" % amount,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func luck_bonus_spin_amount() -> int:
	return int(get_level_def("lucktemple").get("bonus_spin_amount", 2))

func export_save_data() -> Dictionary:
	return {
		"levels":levels.duplicate(),
		"last_goldmine_claim_unix":last_goldmine_claim_unix,
		"upgrade_sequence":upgrade_sequence,
		"pending_upgrade_result":pending_upgrade_result.duplicate(true)
	}

func apply_save_data(data: Dictionary) -> void:
	var incoming: Dictionary = data.get("levels", {})
	for key in levels.keys():
		levels[key] = clampi(int(incoming.get(key, levels[key])), 1, 3)
	last_goldmine_claim_unix = int(data.get("last_goldmine_claim_unix", ServerClockService.now_unix()))
	upgrade_sequence=maxi(int(data.get("upgrade_sequence",0)),0)
	var pending=data.get("pending_upgrade_result",{})
	pending_upgrade_result=pending.duplicate(true) if typeof(pending)==TYPE_DICTIONARY else {}
	village_changed.emit()
