extends Node

signal afk_changed

const CONFIG_VERSION := "v1.44-afk-01"
const MIN_SECONDS := 120
const MAX_SECONDS := 28800 # 8h cap
const GOLD_PER_MINUTE_BASE := 8

var pending_reward: Dictionary = {}
var claim_sequence: int = 0

func prepare_from_seconds_away(seconds_away: int) -> bool:
	if not pending_reward.is_empty():
		return false
	var seconds := clampi(seconds_away,0,MAX_SECONDS)
	if seconds < MIN_SECONDS:
		return false
	claim_sequence += 1
	var minutes := maxi(int(seconds / 60),1)
	var progression_bonus := maxi(PlayerData.player_level - 1,0) * 2
	var gold := minutes * (GOLD_PER_MINUTE_BASE + progression_bonus)
	pending_reward = {
		"claim_id":"afk_%d_%d" % [int(Time.get_unix_time_from_system()),claim_sequence],
		"seconds":seconds,
		"gold":gold,
		"config_version":CONFIG_VERSION
	}
	SaveGame.save_game()
	afk_changed.emit()
	return true

func has_pending_reward() -> bool:
	return not pending_reward.is_empty()

func preview_text() -> String:
	if pending_reward.is_empty():
		return "Keine Offline-Belohnung verfügbar"
	var minutes := int(int(pending_reward.get("seconds",0)) / 60)
	return "DU WARST %d MIN. WEG\n+%d GOLD" % [minutes,int(pending_reward.get("gold",0))]

func claim() -> Dictionary:
	if pending_reward.is_empty():
		return {"ok":false,"message":"Keine Offline-Belohnung"}
	var result := pending_reward.duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("afk_reward_claim", {
		"claim_sequence":claim_sequence,
		"pending_reward":result
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		result,
		{"pending_reward_cleared":true,"claim_sequence":claim_sequence+1}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Offline-Belohnung konnte nicht bestätigt werden"))}
	pending_reward = {}
	claim_sequence += 1
	SaveGame.save_game()
	afk_changed.emit()
	result["ok"]=true
	result["authority_request_id"]=str(authority_intent.get("request_id",""))
	result["authority_revision"]=int(economy_result.get("revision",0))
	return result

func export_save_data() -> Dictionary:
	return {"pending_reward":pending_reward.duplicate(true),"claim_sequence":claim_sequence}

func apply_save_data(data: Dictionary) -> void:
	var incoming=data.get("pending_reward",{})
	pending_reward=incoming.duplicate(true) if typeof(incoming)==TYPE_DICTIONARY else {}
	claim_sequence=maxi(int(data.get("claim_sequence",0)),0)
	afk_changed.emit()
