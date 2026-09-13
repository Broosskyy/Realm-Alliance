extends Node

signal daily_claimed(day_index: int, reward: Dictionary)

const DATA_PATH := "res://data/daily_quests_v1_32.json"
var rewards: Array = []
var claimed_day_keys: Array[String] = []

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("V1.32 Daily config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		rewards = parsed.get("daily", {}).get("cycle", [])

func _today_key() -> String:
	return ServerClockService.day_key()

func can_claim_today() -> bool:
	if PlayerData.last_daily_claim_unix <= 0:
		return true
	return ServerClockService.day_key(PlayerData.last_daily_claim_unix) != _today_key()

func can_claim() -> bool:
	return can_claim_today()

func current_day_index() -> int:
	if rewards.is_empty():
		return 0
	return posmod(PlayerData.daily_streak, rewards.size())

func current_reward() -> Dictionary:
	if rewards.is_empty():
		return {}
	return rewards[current_day_index()].duplicate(true)

func claim_today() -> Dictionary:
	if not can_claim_today():
		return {"ok": false, "message": "Heute bereits abgeholt", "error_code": "ALREADY_CLAIMED"}
	if rewards.is_empty():
		return {"ok": false, "message": "Daily-Konfiguration fehlt"}

	var day_index := current_day_index()
	var today_key := _today_key()
	if claimed_day_keys.has(today_key):
		return {"ok": false, "message": "Heute bereits abgeholt", "error_code": "ALREADY_CLAIMED"}

	var raw: Dictionary = rewards[day_index].duplicate(true)
	raw.erase("day")
	var gold := maxi(int(raw.get("gold", 0)), 0)
	var spins := maxi(int(raw.get("spins", 0)), 0)
	var gems := maxi(int(raw.get("gems", 0)), 0)
	var xp := maxi(int(raw.get("xp", 0)), 0)

	var next_streak := (PlayerData.daily_streak + 1) % rewards.size()
	var claim_unix := ServerClockService.now_unix()
	var reward_txn := RewardPipeline.grant_daily(day_index, {
		"gold": gold,
		"spins": spins,
		"gems": gems,
		"xp": xp
	}, {
		"daily_streak": next_streak,
		"last_daily_claim_unix": claim_unix
	})
	if not bool(reward_txn.get("ok", false)):
		return {
			"ok": false,
			"message": str(reward_txn.get("message", "Tagesbonus konnte nicht bestätigt werden")),
			"error_code": str(reward_txn.get("error_code", "REWARD_FAILED"))
		}

	PlayerData.daily_streak = next_streak
	PlayerData.last_daily_claim_unix = claim_unix
	claimed_day_keys.append(today_key)
	PlayerData.stats_changed.emit()

	var result := {
		"ok": true,
		"day_index": day_index,
		"gold": gold,
		"spins": spins,
		"gems": gems,
		"xp": xp,
		"reward_transaction": reward_txn,
		"authority_request_id": str(reward_txn.get("authority_request_id", "")),
		"authority_revision": int(reward_txn.get("authority_revision", 0))
	}
	SaveGame.save_game()
	daily_claimed.emit(day_index, result)
	GameplayEventService.publish(GameplayEventService.EVENT_DAILY_CLAIMED, 1, {"day_index": day_index})
	return result

func claim() -> Dictionary:
	var result := claim_today()
	if not bool(result.get("ok", false)):
		return {}
	result.erase("ok")
	return result

func export_save_data() -> Dictionary:
	return {"claimed_day_keys": claimed_day_keys.duplicate()}

func apply_save_data(data: Dictionary) -> void:
	claimed_day_keys.clear()
	for key in data.get("claimed_day_keys", []):
		var clean := str(key)
		if not clean.is_empty() and not claimed_day_keys.has(clean):
			claimed_day_keys.append(clean)
