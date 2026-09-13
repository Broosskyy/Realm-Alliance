extends Node

signal afk_changed

const CONFIG_VERSION := "v2.04-afk-01"

var pending_reward: Dictionary = {}
var claim_sequence: int = 0
var claimed_claim_ids: Array[String] = []
var last_prepared_seconds: int = 0

func prepare_from_seconds_away(seconds_away: int) -> bool:
	if not pending_reward.is_empty():
		return false
	var seconds := clampi(seconds_away, 0, GameConfig.AFK_MAX_SECONDS)
	if seconds < GameConfig.AFK_MIN_SECONDS:
		return false
	claim_sequence += 1
	last_prepared_seconds = seconds
	var gold := GameConfig.afk_gold_for_seconds(seconds)
	var claim_id := "afk_%d_%d" % [int(Time.get_unix_time_from_system()), claim_sequence]
	pending_reward = {
		"claim_id": claim_id,
		"seconds": seconds,
		"gold": gold,
		"village_multiplier": _village_multiplier(),
		"config_version": CONFIG_VERSION
	}
	SaveGame.save_game()
	afk_changed.emit()
	return true

func qa_prepare_seconds(seconds: int) -> bool:
	claim_sequence += 1
	last_prepared_seconds = maxi(seconds, GameConfig.AFK_MIN_SECONDS)
	var gold := GameConfig.afk_gold_for_seconds(last_prepared_seconds)
	var claim_id := "afk_qa_%d_%d" % [int(Time.get_unix_time_from_system()), claim_sequence]
	pending_reward = {
		"claim_id": claim_id,
		"seconds": last_prepared_seconds,
		"gold": gold,
		"village_multiplier": _village_multiplier(),
		"config_version": CONFIG_VERSION,
		"qa": true
	}
	afk_changed.emit()
	return true

func has_pending_reward() -> bool:
	return not pending_reward.is_empty()

func preview_text() -> String:
	if pending_reward.is_empty():
		return "Keine Offline-Belohnung verfügbar"
	var minutes := int(int(pending_reward.get("seconds", 0)) / 60)
	var village_note := ""
	var mult := float(pending_reward.get("village_multiplier", 1.0))
	if mult > 1.01:
		village_note = "\nDORF-BONUS AKTIV"
	return "DU WARST %d MIN. WEG\n+%d GOLD%s" % [minutes, int(pending_reward.get("gold", 0)), village_note]

func claim() -> Dictionary:
	if pending_reward.is_empty():
		return {"ok": false, "message": "Keine Offline-Belohnung"}
	var claim_id := str(pending_reward.get("claim_id", ""))
	if claim_id.is_empty():
		return {"ok": false, "message": "Ungültige Offline-Belohnung"}
	if claimed_claim_ids.has(claim_id):
		return {"ok": false, "message": "Bereits eingesammelt", "error_code": "ALREADY_CLAIMED"}
	var snapshot := pending_reward.duplicate(true)
	var reward_txn := RewardPipeline.grant_afk(snapshot)
	if not bool(reward_txn.get("ok", false)):
		return {
			"ok": false,
			"message": str(reward_txn.get("message", "Offline-Belohnung konnte nicht bestätigt werden")),
			"error_code": str(reward_txn.get("error_code", "REWARD_FAILED"))
		}
	claimed_claim_ids.append(claim_id)
	pending_reward = {}
	claim_sequence += 1
	SaveGame.save_game()
	afk_changed.emit()
	var result := snapshot.duplicate(true)
	result["ok"] = true
	result["reward_transaction"] = reward_txn
	result["authority_request_id"] = str(reward_txn.get("authority_request_id", ""))
	result["authority_revision"] = int(reward_txn.get("authority_revision", 0))
	return result

func _village_multiplier() -> float:
	var village_rate := float(P0VillageSystem.goldmine_rate_per_minute())
	return 1.0 + maxf(village_rate - float(GameConfig.AFK_VILLAGE_RATE_REFERENCE), 0.0) / float(GameConfig.AFK_VILLAGE_RATE_REFERENCE) * 0.35

func export_save_data() -> Dictionary:
	return {
		"pending_reward": pending_reward.duplicate(true),
		"claim_sequence": claim_sequence,
		"claimed_claim_ids": claimed_claim_ids.duplicate(),
		"last_prepared_seconds": last_prepared_seconds
	}

func apply_save_data(data: Dictionary) -> void:
	var incoming = data.get("pending_reward", {})
	pending_reward = incoming.duplicate(true) if typeof(incoming) == TYPE_DICTIONARY else {}
	claim_sequence = maxi(int(data.get("claim_sequence", 0)), 0)
	last_prepared_seconds = int(data.get("last_prepared_seconds", 0))
	claimed_claim_ids.clear()
	for item in data.get("claimed_claim_ids", []):
		claimed_claim_ids.append(str(item))
	afk_changed.emit()

func reset_runtime() -> void:
	pending_reward = {}
	last_prepared_seconds = 0
