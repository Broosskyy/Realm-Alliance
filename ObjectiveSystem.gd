extends Node

signal objectives_changed

const DATA_PATH := "res://data/objectives_v1_52.json"
const CONFIG_VERSION := "v2.06-objectives-01"

const STATE_LOCKED := "LOCKED"
const STATE_ACTIVE := "ACTIVE"
const STATE_COMPLETED := "COMPLETED"
const STATE_CLAIMABLE := "CLAIMABLE"
const STATE_CLAIMED := "CLAIMED"

var config: Dictionary = {}
var lifetime: Dictionary = {}
var daily: Dictionary = {}
var weekly: Dictionary = {}
var daily_claimed: Array[String] = []
var weekly_claimed: Array[String] = []
var achievement_claimed: Array[String] = []
var starter_claimed: Array[String] = []
var collection_claimed: bool = false
var bestiary: Array[String] = []
var daily_bucket: String = ""
var weekly_bucket: String = ""
var claimed_transaction_ids: Array[String] = []

func _ready() -> void:
	_load()
	_roll_periods(false)
	call_deferred("_bind_gameplay_events")

func _bind_gameplay_events() -> void:
	if not GameplayEventService.event_emitted.is_connected(_on_gameplay_event):
		GameplayEventService.event_emitted.connect(_on_gameplay_event)

func _load() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _utc_day() -> String:
	return ServerClockService.day_key()

func _week_bucket() -> String:
	return ServerClockService.week_bucket_key()

func _roll_periods(save: bool = true) -> void:
	var day := _utc_day()
	var week := _week_bucket()
	var changed := false
	if daily_bucket != day:
		daily_bucket = day
		daily.clear()
		daily_claimed.clear()
		changed = true
	if weekly_bucket != week:
		weekly_bucket = week
		weekly.clear()
		weekly_claimed.clear()
		changed = true
	if changed:
		objectives_changed.emit()
		if save:
			SaveGame.save_game()

func _on_gameplay_event(event_name: String, amount: int, context: Dictionary) -> void:
	var metric := GameplayEventService.metric_for(event_name)
	if metric.is_empty():
		return
	register_action(metric, amount, context)

func register_action(metric: String, amount: int = 1, context: Dictionary = {}) -> void:
	if metric.is_empty() or amount <= 0:
		return
	_roll_periods(false)
	lifetime[metric] = int(lifetime.get(metric, 0)) + amount
	daily[metric] = int(daily.get(metric, 0)) + amount
	weekly[metric] = int(weekly.get(metric, 0)) + amount
	if metric in ["monster_defeat", "boss_defeat", "spin", "journey_lap", "puzzle_complete", "td_win", "lane_win", "village_upgrade", "goldmine_claim", "forge_craft", "temple_blessing", "tap", "critical_hit", "upgrade_purchased", "afk_claimed", "item_acquired", "item_equipped"]:
		daily["pillar_action"] = int(daily.get("pillar_action", 0)) + 1
		weekly["pillar_action"] = int(weekly.get("pillar_action", 0)) + 1
		lifetime["pillar_action"] = int(lifetime.get("pillar_action", 0)) + 1
	if metric == "monster_defeat":
		var encounter := str(context.get("encounter_id", ""))
		if not encounter.is_empty() and not bestiary.has(encounter):
			bestiary.append(encounter)
	objectives_changed.emit()
	SaveGame.save_game()

func defs(category: String) -> Array:
	return config.get(category, [])

func progress_for(category: String, metric: String) -> int:
	_roll_periods(false)
	if category == "daily":
		return int(daily.get(metric, 0))
	if category == "weekly":
		return int(weekly.get(metric, 0))
	return int(lifetime.get(metric, 0))

func claimed_for(category: String) -> Array:
	if category == "daily":
		return daily_claimed
	if category == "weekly":
		return weekly_claimed
	if category == "starter":
		return starter_claimed
	return achievement_claimed

func _unlock_met(def: Dictionary) -> bool:
	var required := maxi(int(def.get("unlock_player_level", 1)), 1)
	return PlayerData.player_level >= required

func quest_state(category: String, def: Dictionary) -> String:
	var id := str(def.get("id", ""))
	if claimed_for(category).has(id):
		return STATE_CLAIMED
	if not _unlock_met(def):
		return STATE_LOCKED
	var metric := str(def.get("metric", ""))
	var target := maxi(int(def.get("target", 1)), 1)
	var value := progress_for(category, metric)
	if value >= target:
		return STATE_CLAIMABLE
	if value > 0:
		return STATE_ACTIVE
	return STATE_ACTIVE

func row_state(category: String, def: Dictionary) -> Dictionary:
	var id := str(def.get("id", ""))
	var metric := str(def.get("metric", ""))
	var target := maxi(int(def.get("target", 1)), 1)
	var value := mini(progress_for(category, metric), target)
	var claimed := claimed_for(category).has(id)
	var locked := not _unlock_met(def)
	var ready := (not locked) and value >= target and not claimed
	return {
		"id": id,
		"title": str(def.get("title", id)),
		"description": str(def.get("description", "")),
		"value": value,
		"target": target,
		"ready": ready,
		"claimed": claimed,
		"locked": locked,
		"state": quest_state(category, def),
		"reward": def.get("reward", {}),
		"category": category
	}

func rows(category: String) -> Array:
	var out: Array = []
	for def in defs(category):
		out.append(row_state(category, def))
	return out

func ready_count() -> int:
	var ready := 0
	for cat in ["starter", "daily", "weekly", "achievements"]:
		for row in rows(cat):
			if bool(row.ready):
				ready += 1
	if bool(collection_state().ready):
		ready += 1
	return ready

func _grant_side_effects(reward: Dictionary) -> void:
	var chest_tier := str(reward.get("chest_tier", ""))
	if not chest_tier.is_empty():
		ChestRewardSystem.acquire_chest(chest_tier, "quest_reward")

func claim(category: String, id: String) -> Dictionary:
	for def in defs(category):
		if str(def.get("id", "")) != id:
			continue
		var state := row_state(category, def)
		if state.locked:
			return {"ok": false, "error_code": "LOCKED"}
		if state.claimed:
			return {"ok": false, "error_code": "ALREADY_CLAIMED", "message": "Bereits abgeholt"}
		if not bool(state.ready):
			return {"ok": false, "error_code": "NOT_READY"}
		var reward: Dictionary = state.reward
		var txn := RewardPipeline.grant_quest(category, id, reward, {"objective_id": id})
		if not bool(txn.get("ok", false)):
			return {
				"ok": false,
				"error_code": str(txn.get("error_code", "REWARD_FAILED")),
				"message": str(txn.get("message", "Belohnung konnte nicht bestätigt werden"))
			}
		var txn_id := str(txn.get("transaction_id", ""))
		if not txn_id.is_empty() and claimed_transaction_ids.has(txn_id):
			return {"ok": false, "error_code": "DUPLICATE_TRANSACTION"}
		if not txn_id.is_empty():
			claimed_transaction_ids.append(txn_id)
		_grant_side_effects(reward)
		var target := claimed_for(category)
		target.append(id)
		SaveGame.save_game()
		objectives_changed.emit()
		return {
			"ok": true,
			"title": str(state.title),
			"reward": reward,
			"objective_id": id,
			"category": category,
			"reward_transaction": txn
		}
	return {"ok": false, "error_code": "NOT_FOUND"}

func collection_state() -> Dictionary:
	var c: Dictionary = config.get("collection", {})
	var target := maxi(int(c.get("target_unique", 5)), 1)
	return {
		"id": str(c.get("id", "collection")),
		"title": str(c.get("title", "SAMMLUNG")),
		"value": mini(bestiary.size(), target),
		"target": target,
		"ready": bestiary.size() >= target and not collection_claimed,
		"claimed": collection_claimed,
		"reward": c.get("reward", {}),
		"state": STATE_CLAIMED if collection_claimed else (STATE_CLAIMABLE if bestiary.size() >= target else STATE_ACTIVE)
	}

func claim_collection() -> Dictionary:
	var state := collection_state()
	if state.claimed:
		return {"ok": false, "error_code": "ALREADY_CLAIMED"}
	if not bool(state.ready):
		return {"ok": false, "error_code": "NOT_READY"}
	var reward: Dictionary = state.reward
	var txn := RewardPipeline.grant_quest("collection", str(state.id), reward, {"collection": true})
	if not bool(txn.get("ok", false)):
		return {"ok": false, "message": str(txn.get("message", ""))}
	_grant_side_effects(reward)
	collection_claimed = true
	SaveGame.save_game()
	objectives_changed.emit()
	return {"ok": true, "title": str(state.title), "reward": reward, "objective_id": str(state.id), "reward_transaction": txn}

func summary() -> String:
	return "AUFGABEN · %d BEREIT · TAG %s" % [ready_count(), daily_bucket]

func export_save_data() -> Dictionary:
	return {
		"lifetime": lifetime.duplicate(true),
		"daily": daily.duplicate(true),
		"weekly": weekly.duplicate(true),
		"daily_claimed": daily_claimed.duplicate(),
		"weekly_claimed": weekly_claimed.duplicate(),
		"achievement_claimed": achievement_claimed.duplicate(),
		"starter_claimed": starter_claimed.duplicate(),
		"collection_claimed": collection_claimed,
		"bestiary": bestiary.duplicate(),
		"daily_bucket": daily_bucket,
		"weekly_bucket": weekly_bucket,
		"claimed_transaction_ids": claimed_transaction_ids.duplicate()
	}

func apply_save_data(data: Dictionary) -> void:
	for key in ["lifetime", "daily", "weekly"]:
		var incoming = data.get(key, {})
		if typeof(incoming) == TYPE_DICTIONARY:
			set(key, incoming.duplicate(true))
	daily_claimed.clear()
	weekly_claimed.clear()
	achievement_claimed.clear()
	starter_claimed.clear()
	bestiary.clear()
	claimed_transaction_ids.clear()
	for id in data.get("daily_claimed", []):
		daily_claimed.append(str(id))
	for id in data.get("weekly_claimed", []):
		weekly_claimed.append(str(id))
	for id in data.get("achievement_claimed", []):
		achievement_claimed.append(str(id))
	for id in data.get("starter_claimed", []):
		starter_claimed.append(str(id))
	for id in data.get("claimed_transaction_ids", []):
		var clean := str(id)
		if not clean.is_empty() and not claimed_transaction_ids.has(clean):
			claimed_transaction_ids.append(clean)
	for id in data.get("bestiary", []):
		var clean := str(id)
		if not clean.is_empty() and not bestiary.has(clean):
			bestiary.append(clean)
	collection_claimed = bool(data.get("collection_claimed", false))
	daily_bucket = str(data.get("daily_bucket", ""))
	weekly_bucket = str(data.get("weekly_bucket", ""))
	_roll_periods(false)
	objectives_changed.emit()
