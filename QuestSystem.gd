extends Node

signal quests_changed

const DATA_PATH := "res://data/daily_quests_v1_32.json"

var QUESTS: Array = []
var progress: Dictionary = {}
var claimed: Array[String] = []

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("V1.32 Quest config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	QUESTS = parsed.get("quests",[])
	for q in QUESTS:
		var id := str(q.get("id",""))
		if not id.is_empty() and not progress.has(id):
			progress[id] = 0

func add_progress(id: String, amount: int = 1) -> void:
	if not progress.has(id) or amount <= 0:
		return
	var before := int(progress[id])
	progress[id] = mini(before + amount, target_for(id))
	if int(progress[id]) == before:
		return
	quests_changed.emit()
	SaveGame.save_game()

func target_for(id: String) -> int:
	for q in QUESTS:
		if str(q.get("id","")) == id:
			return maxi(int(q.get("target",1)),1)
	return 1

func quest_for(id: String) -> Dictionary:
	for q in QUESTS:
		if str(q.get("id","")) == id:
			return q
	return {}

func is_ready(id: String) -> bool:
	return not claimed.has(id) and int(progress.get(id,0)) >= target_for(id)

func claim(id: String) -> Dictionary:
	if not is_ready(id):
		return {"ok":false}
	var q := quest_for(id)
	if q.is_empty():
		return {"ok":false}
	var gold := maxi(int(q.get("reward_gold",0)),0)
	var authority_intent := OnlineAuthorityService.build_intent("quest_reward_claim", {
		"quest_id":id,
		"progress":int(progress.get(id,0))
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold},
		{"quest_id":id,"claimed":true}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Belohnung konnte nicht bestätigt werden"))}
	claimed.append(id)
	var result := {
		"ok":true,
		"title":"Aufgabe geschafft",
		"quest_id":id,
		"gold":gold,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0))
	}
	SaveGame.save_game()
	quests_changed.emit()
	return result

func completed_count() -> int:
	return claimed.size()

func total_count() -> int:
	return QUESTS.size()

func export_save_data() -> Dictionary:
	return {"progress":progress.duplicate(true),"claimed":claimed.duplicate()}

func apply_save_data(data: Dictionary) -> void:
	if QUESTS.is_empty():
		_load_config()
	var incoming: Dictionary = data.get("progress",{})
	for q in QUESTS:
		var id := str(q.get("id",""))
		progress[id] = clampi(int(incoming.get(id,0)),0,target_for(id))
	claimed.clear()
	for item in data.get("claimed",[]):
		var id := str(item)
		if not quest_for(id).is_empty() and not claimed.has(id):
			claimed.append(id)
	quests_changed.emit()
