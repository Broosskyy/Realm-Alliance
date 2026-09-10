extends Node

signal daily_claimed(day_index: int, reward: Dictionary)

const DATA_PATH := "res://data/daily_quests_v1_32.json"
var rewards: Array = []

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("V1.32 Daily config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		rewards = parsed.get("daily",{}).get("cycle",[])

func _day_key_from_unix(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	var d := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%04d-%02d-%02d" % [int(d.year),int(d.month),int(d.day)]

func _today_key() -> String:
	return _day_key_from_unix(ServerClockService.now_unix())

func can_claim_today() -> bool:
	if PlayerData.last_daily_claim_unix <= 0:
		return true
	return _day_key_from_unix(PlayerData.last_daily_claim_unix) != _today_key()

# Legacy compatibility.
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
		return {"ok":false,"message":"Heute bereits abgeholt"}
	if rewards.is_empty():
		return {"ok":false,"message":"Daily-Konfiguration fehlt"}

	var day_index := current_day_index()
	var raw: Dictionary = rewards[day_index].duplicate(true)
	raw.erase("day")
	var gold := maxi(int(raw.get("gold",0)),0)
	var spins := maxi(int(raw.get("spins",0)),0)
	var gems := maxi(int(raw.get("gems",0)),0)

	var next_streak := (PlayerData.daily_streak + 1) % rewards.size()
	var claim_unix := ServerClockService.now_unix()
	var authority_intent := OnlineAuthorityService.build_intent("daily_reward_claim", {
		"day_index":day_index,
		"current_streak":PlayerData.daily_streak,
		"claim_unix":claim_unix
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins,"gems":gems},
		{"daily_streak":next_streak,"last_daily_claim_unix":claim_unix}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Tagesbonus konnte nicht bestätigt werden"))}

	PlayerData.daily_streak = next_streak
	PlayerData.last_daily_claim_unix = claim_unix
	PlayerData.stats_changed.emit()

	var result := {
		"ok":true,
		"day_index":day_index,
		"gold":gold,
		"spins":spins,
		"gems":gems,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision":int(economy_result.get("revision",0))
	}
	SaveGame.save_game()
	daily_claimed.emit(day_index,result)
	return result

# Legacy compatibility.
func claim() -> Dictionary:
	var result := claim_today()
	if not bool(result.get("ok",false)):
		return {}
	result.erase("ok")
	return result
