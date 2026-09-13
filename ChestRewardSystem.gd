extends Node
## V2.05 — reward container: acquire → pending → open → RewardPipeline → idempotent state.

signal chest_changed

const DATA_PATH := "res://data/chests_v205.json"
const CONFIG_VERSION := "v2.05-chest-01"

var config: Dictionary = {}
var pending_chests: Array = []
var opened_chest_ids: Array[String] = []
var _sequence: int = 0

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		push_error("V2.05 chest config missing")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func acquire_chest(tier: String, source: String) -> Dictionary:
	_sequence += 1
	var chest_id := "chest_%d_%d" % [ServerClockService.now_unix(), _sequence]
	var entry := {
		"chest_id": chest_id,
		"tier": tier if not tier.is_empty() else "common",
		"source": source,
		"opened": false,
		"config_version": CONFIG_VERSION
	}
	pending_chests.append(entry)
	SaveGame.save_game()
	chest_changed.emit()
	return entry.duplicate(true)

func has_pending_chest() -> bool:
	for entry in pending_chests:
		if not bool(entry.get("opened", false)):
			return true
	return false

func pending_count() -> int:
	var count := 0
	for entry in pending_chests:
		if not bool(entry.get("opened", false)):
			count += 1
	return count

func next_pending() -> Dictionary:
	for entry in pending_chests:
		if not bool(entry.get("opened", false)):
			return entry.duplicate(true)
	return {}

func open_chest(chest_id: String) -> Dictionary:
	if chest_id.is_empty():
		return {"ok": false, "error_code": "INVALID_CHEST"}
	if opened_chest_ids.has(chest_id):
		return {"ok": false, "error_code": "ALREADY_OPENED", "message": "Truhe bereits geöffnet"}
	var index := -1
	for i in range(pending_chests.size()):
		if str(pending_chests[i].get("chest_id", "")) == chest_id:
			index = i
			break
	if index < 0:
		return {"ok": false, "error_code": "CHEST_NOT_FOUND"}
	var entry: Dictionary = pending_chests[index]
	if bool(entry.get("opened", false)):
		return {"ok": false, "error_code": "ALREADY_OPENED", "message": "Truhe bereits geöffnet"}
	var tier := str(entry.get("tier", "common"))
	var reward := _reward_for_tier(tier)
	var txn := RewardPipeline.grant_chest(chest_id, reward, {
		"tier": tier,
		"source": str(entry.get("source", ""))
	})
	if not bool(txn.get("ok", false)):
		return {
			"ok": false,
			"error_code": str(txn.get("error_code", "REWARD_FAILED")),
			"message": str(txn.get("message", "Truhe konnte nicht geöffnet werden"))
		}
	opened_chest_ids.append(chest_id)
	pending_chests[index]["opened"] = true
	SaveGame.save_game()
	chest_changed.emit()
	return {
		"ok": true,
		"chest_id": chest_id,
		"tier": tier,
		"reward": reward,
		"reward_transaction": txn
	}

func open_next_pending() -> Dictionary:
	var pending := next_pending()
	if pending.is_empty():
		return {"ok": false, "error_code": "NO_PENDING_CHEST"}
	return open_chest(str(pending.get("chest_id", "")))

func _reward_for_tier(tier: String) -> Dictionary:
	var tiers: Dictionary = config.get("tiers", {})
	var reward: Dictionary = tiers.get(tier, tiers.get("common", {}))
	var payload := {
		"gold": maxi(int(reward.get("gold", 0)), 0),
		"spins": maxi(int(reward.get("spins", 0)), 0),
		"realm_keys": maxi(int(reward.get("realm_keys", 0)), 0),
		"xp": maxi(int(reward.get("xp", 0)), 0),
		"items": []
	}
	var loot_source := LootTableService.chest_source_for_tier(tier)
	var rolled: Array = LootTableService.roll(loot_source)
	if not rolled.is_empty():
		payload["items"] = rolled
	return payload

func export_save_data() -> Dictionary:
	return {
		"pending_chests": pending_chests.duplicate(true),
		"opened_chest_ids": opened_chest_ids.duplicate(),
		"sequence": _sequence
	}

func apply_save_data(data: Dictionary) -> void:
	pending_chests.clear()
	opened_chest_ids.clear()
	for entry in data.get("pending_chests", []):
		if typeof(entry) == TYPE_DICTIONARY:
			pending_chests.append(entry.duplicate(true))
	for id in data.get("opened_chest_ids", []):
		var clean := str(id)
		if not clean.is_empty() and not opened_chest_ids.has(clean):
			opened_chest_ids.append(clean)
	_sequence = maxi(int(data.get("sequence", 0)), 0)
	chest_changed.emit()

func reset_runtime() -> void:
	pending_chests.clear()
	opened_chest_ids.clear()
	_sequence = 0
