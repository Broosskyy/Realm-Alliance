extends Node

signal meta_changed
signal event_completed(payload: Dictionary)
signal chest_ready

const DATA_PATH := "res://data/meta_v1_27.json"

var config: Dictionary = {}
var boss_defeats: int = 0
var event_boss_progress: int = 0
var event_claimed: bool = false
var realm_keys: int = 0
var realm_chests_opened: int = 0

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		push_error("V1.27 meta config missing")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func register_boss_defeat() -> void:
	boss_defeats += 1
	if not event_claimed:
		event_boss_progress = mini(event_boss_progress + 1, event_target())
	grant_realm_keys(int(config.get("realm_chest",{}).get("key_sources",{}).get("boss_defeat",1)))
	meta_changed.emit()

func register_journey_lap() -> void:
	grant_realm_keys(int(config.get("realm_chest",{}).get("key_sources",{}).get("journey_lap",1)))
	meta_changed.emit()

func event_target() -> int:
	return maxi(int(config.get("event",{}).get("target_bosses",3)),1)

func can_claim_event() -> bool:
	return not event_claimed and event_boss_progress >= event_target()

func claim_event() -> Dictionary:
	var authority_intent := OnlineAuthorityService.build_intent("claim_event_reward", {"event_boss_progress":event_boss_progress,"event_target":event_target()})
	if not can_claim_event():
		return {"ok":false,"message":"Eventziel noch nicht erreicht"}
	var reward: Dictionary = config.get("event",{}).get("reward",{})
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins},
		{"event_claimed":true}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Event-Belohnung konnte nicht bestätigt werden"))}
	event_claimed = true
	var payload := {
		"ok":true,
		"gold":gold,
		"spins":spins,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0))
	}
	SaveGame.save_game()
	event_completed.emit(payload)
	meta_changed.emit()
	return payload

func required_keys() -> int:
	return maxi(int(config.get("realm_chest",{}).get("required_keys",3)),1)

func grant_realm_keys(amount: int) -> void:
	if amount <= 0:
		return
	var was_ready := can_open_chest()
	realm_keys += amount
	if not was_ready and can_open_chest():
		chest_ready.emit()

func can_open_chest() -> bool:
	return realm_keys >= required_keys()

func open_realm_chest() -> Dictionary:
	var authority_intent := OnlineAuthorityService.build_intent("open_realm_chest", {"realm_keys":realm_keys,"required_keys":required_keys()})
	if not can_open_chest():
		return {"ok":false,"message":"Noch nicht genug Realm-Schlüssel"}
	var next_opened := realm_chests_opened + 1
	var next_keys := realm_keys - required_keys()
	var reward: Dictionary = config.get("realm_chest",{}).get("reward",{})
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins},
		{"realm_keys":next_keys,"realm_chests_opened":next_opened}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Truhe konnte nicht bestätigt werden"))}
	realm_keys = next_keys
	realm_chests_opened = next_opened
	var result := {
		"ok":true,
		"gold":gold,
		"spins":spins,
		"opened":realm_chests_opened,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0))
	}
	SaveGame.save_game()
	meta_changed.emit()
	return result

func ranking_rows() -> Array:
	# V1.51: legacy fabricated multiplayer rows removed.
	# Real ranking data belongs to LiveOpsRankingSystem/backend snapshots only.
	return []


func export_save_data() -> Dictionary:
	return {
		"boss_defeats":boss_defeats,
		"event_boss_progress":event_boss_progress,
		"event_claimed":event_claimed,
		"realm_keys":realm_keys,
		"realm_chests_opened":realm_chests_opened
	}

func apply_save_data(data: Dictionary) -> void:
	boss_defeats = maxi(int(data.get("boss_defeats",0)),0)
	event_boss_progress = clampi(int(data.get("event_boss_progress",0)),0,event_target())
	event_claimed = bool(data.get("event_claimed",false))
	realm_keys = maxi(int(data.get("realm_keys",0)),0)
	realm_chests_opened = maxi(int(data.get("realm_chests_opened",0)),0)
	meta_changed.emit()
