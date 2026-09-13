extends Node
## V2.07 — central reward contract: Source → Definition → Grant → Transaction Result → Save hook.

signal transaction_committed(result: Dictionary)

const CONFIG_VERSION := "v2.07-reward-pipeline-01"

const SOURCE_MONSTER_DEFEAT := "monster_defeat"
const SOURCE_BOSS_DEFEAT := "boss_defeat"
const SOURCE_SPIN := "spin"
const SOURCE_AFK := "afk"
const SOURCE_VILLAGE_GOLDMINE := "village_goldmine"
const SOURCE_DAILY := "daily"
const SOURCE_QUEST := "quest"
const SOURCE_CHEST := "chest"
const SOURCE_EVENT := "event"

var last_transaction: Dictionary = {}
var _transaction_sequence: int = 0

func grant(source: String, definition: Dictionary, operation: String = "reward_grant", domain_changes: Dictionary = {}) -> Dictionary:
	var balances_before := _snapshot_balances()
	var inventory_before := ItemInventoryService.snapshot_instance_count()
	var normalized := _normalize_reward(definition)
	if not bool(normalized.get("valid", true)):
		return {
			"ok": false,
			"source": source,
			"error_code": "INVALID_REWARD_DEFINITION",
			"validation_errors": normalized.get("validation_errors", []),
			"message": "Reward definition failed validation"
		}
	var reward_payload := normalized.duplicate(true)
	reward_payload.erase("valid")
	reward_payload.erase("validation_errors")
	var intent := OnlineAuthorityService.build_intent(operation, {
		"source": source,
		"reward": reward_payload,
		"domain": domain_changes
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(intent, reward_payload, domain_changes)
	var xp := maxi(int(definition.get("xp", 0)), 0)
	if xp > 0 and bool(economy_result.get("ok", false)):
		PlayerData.add_xp(xp)
	var balances_after := _snapshot_balances()
	_transaction_sequence += 1
	var txn_id := str(definition.get("transaction_id", ""))
	if txn_id.is_empty():
		txn_id = "%s_%d_%d" % [source, ServerClockService.now_unix(), _transaction_sequence]
	var granted_items: Array = []
	var item_grant: Dictionary = {}
	if bool(economy_result.get("ok", false)) and not reward_payload.get("items", []).is_empty():
		item_grant = ItemInventoryService.grant_from_transaction(
			txn_id,
			source,
			reward_payload.get("items", []),
			Dictionary(definition.get("metadata", {}))
		)
		if not bool(item_grant.get("ok", false)):
			return {
				"ok": false,
				"source": source,
				"transaction_id": txn_id,
				"error_code": str(item_grant.get("error_code", "ITEM_GRANT_FAILED")),
				"message": "Item grant failed after currency commit",
				"reward": reward_payload,
				"item_grant": item_grant
			}
		granted_items = item_grant.get("granted_items", [])
	var inventory_after := ItemInventoryService.snapshot_instance_count()
	var result := {
		"ok": bool(economy_result.get("ok", false)),
		"source": source,
		"transaction_id": txn_id,
		"reward_id": str(definition.get("reward_id", source)),
		"reward": reward_payload,
		"granted_items": granted_items,
		"instance_ids": item_grant.get("instance_ids", []),
		"item_duplicate": bool(item_grant.get("duplicate", false)),
		"balances_before": balances_before,
		"balances_after": balances_after,
		"inventory_before": inventory_before,
		"inventory_after": inventory_after,
		"authority_request_id": str(intent.get("request_id", "")),
		"authority_revision": int(economy_result.get("revision", 0)),
		"timestamp_unix": ServerClockService.now_unix(),
		"config_version": CONFIG_VERSION,
		"metadata": Dictionary(definition.get("metadata", {})).duplicate(true),
		"message": str(economy_result.get("message", "")),
		"error_code": str(economy_result.get("error_code", ""))
	}
	if bool(result.get("ok", false)):
		last_transaction = result.duplicate(true)
		transaction_committed.emit(result)
	return result

func grant_monster_defeat(level: int, is_boss: bool) -> Dictionary:
	var gold := GameConfig.effective_monster_reward(level)
	var boss_spins := 2 if is_boss else 0
	var bonus_spin := (not is_boss) and randf() <= GameConfig.BONUS_SPIN_CHANCE
	var bonus_spin_amount := 1 if bonus_spin else 0
	var source := SOURCE_BOSS_DEFEAT if is_boss else SOURCE_MONSTER_DEFEAT
	var items: Array = EncounterStatService.roll_loot_items(level)
	var xp := EncounterStatService.xp_reward(level)
	return grant(source, {
		"gold": gold,
		"spins": boss_spins + bonus_spin_amount,
		"xp": xp,
		"items": items,
		"reward_id": "monster_kill_%d" % level,
		"metadata": {
			"monster_level": level,
			"boss": is_boss,
			"bonus_spin": bonus_spin,
			"classification": P0MonsterVisualSystem.monster_classification(level),
			"loot_source": EncounterStatService.loot_source_id(level),
			"loot_roll_chance": EncounterStatService.loot_roll_chance(level)
		}
	}, "monster_defeat_reward")

func commit_spin_reward(authority_intent: Dictionary, spin_result: Dictionary) -> Dictionary:
	var balances_before := _snapshot_balances()
	var economy_result := EconomyAuthorityService.commit_spin_local(authority_intent, spin_result)
	var balances_after := _snapshot_balances()
	_transaction_sequence += 1
	var reward_type := str(spin_result.get("reward_type", "none"))
	var amount := maxi(int(spin_result.get("reward_value", 0)), 0)
	var result := {
		"ok": bool(economy_result.get("ok", false)),
		"source": SOURCE_SPIN,
		"transaction_id": str(spin_result.get("result_id", "spin_%d" % _transaction_sequence)),
		"reward_id": str(spin_result.get("reward_id", reward_type)),
		"reward": {
			"reward_type": reward_type,
			"reward_value": amount,
			"gold": amount if reward_type in ["gold", "gold_fallback", "special_gold"] else 0,
			"spins": amount if reward_type == "spins" else 0,
			"shields": amount if reward_type == "shield" else 0,
			"items": []
		},
		"granted_items": [],
		"instance_ids": [],
		"balances_before": balances_before,
		"balances_after": balances_after,
		"authority_request_id": str(authority_intent.get("request_id", "")),
		"authority_revision": int(economy_result.get("revision", 0)),
		"timestamp_unix": ServerClockService.now_unix(),
		"config_version": CONFIG_VERSION,
		"metadata": {
			"segment_id": str(spin_result.get("segment_id", "")),
			"payline_match": bool(spin_result.get("payline_match", false))
		},
		"message": str(economy_result.get("message", "")),
		"error_code": str(economy_result.get("error_code", ""))
	}
	if bool(result.get("ok", false)):
		last_transaction = result.duplicate(true)
		transaction_committed.emit(result)
	return result

func grant_afk(pending: Dictionary) -> Dictionary:
	return grant(SOURCE_AFK, {
		"gold": maxi(int(pending.get("gold", 0)), 0),
		"reward_id": str(pending.get("claim_id", "")),
		"transaction_id": str(pending.get("claim_id", "")),
		"metadata": pending.duplicate(true)
	}, "afk_reward_claim")

func grant_daily(day_index: int, reward: Dictionary, domain_changes: Dictionary = {}) -> Dictionary:
	var txn_id := "daily_%d_%d" % [day_index, ServerClockService.now_unix()]
	return grant(SOURCE_DAILY, {
		"gold": maxi(int(reward.get("gold", 0)), 0),
		"gems": maxi(int(reward.get("gems", 0)), 0),
		"spins": maxi(int(reward.get("spins", 0)), 0),
		"xp": maxi(int(reward.get("xp", 0)), 0),
		"items": reward.get("items", []),
		"reward_id": "daily_day_%d" % day_index,
		"transaction_id": txn_id,
		"metadata": {"day_index": day_index}
	}, "daily_reward_claim", domain_changes)

func grant_quest(category: String, objective_id: String, reward: Dictionary, metadata: Dictionary = {}) -> Dictionary:
	var txn_id := "quest_%s_%s_%d" % [category, objective_id, ServerClockService.now_unix()]
	var meta := metadata.duplicate(true)
	meta["category"] = category
	meta["objective_id"] = objective_id
	return grant(SOURCE_QUEST, {
		"gold": maxi(int(reward.get("gold", 0)), 0),
		"gems": maxi(int(reward.get("gems", 0)), 0),
		"spins": maxi(int(reward.get("spins", 0)), 0),
		"realm_keys": maxi(int(reward.get("realm_keys", 0)), 0),
		"xp": maxi(int(reward.get("xp", 0)), 0),
		"items": reward.get("items", []),
		"reward_id": objective_id,
		"transaction_id": txn_id,
		"metadata": meta
	}, "quest_reward_claim")

func grant_chest(chest_id: String, reward: Dictionary, metadata: Dictionary = {}) -> Dictionary:
	var meta := metadata.duplicate(true)
	meta["chest_id"] = chest_id
	return grant(SOURCE_CHEST, {
		"gold": maxi(int(reward.get("gold", 0)), 0),
		"spins": maxi(int(reward.get("spins", 0)), 0),
		"realm_keys": maxi(int(reward.get("realm_keys", 0)), 0),
		"xp": maxi(int(reward.get("xp", 0)), 0),
		"items": reward.get("items", []),
		"reward_id": chest_id,
		"transaction_id": chest_id,
		"metadata": meta
	}, "chest_open")

func _snapshot_balances() -> Dictionary:
	return {
		"gold": PlayerData.gold,
		"gems": PlayerData.gems,
		"spins": PlayerData.spins,
		"shields": PlayerData.shields
	}

func _normalize_reward(definition: Dictionary) -> Dictionary:
	var result := {
		"gold": maxi(int(definition.get("gold", 0)), 0),
		"gems": maxi(int(definition.get("gems", 0)), 0),
		"spins": maxi(int(definition.get("spins", 0)), 0),
		"shields": maxi(int(definition.get("shields", 0)), 0),
		"realm_keys": maxi(int(definition.get("realm_keys", 0)), 0),
		"items": [],
		"valid": true,
		"validation_errors": []
	}
	var raw_items = definition.get("items", [])
	if typeof(raw_items) == TYPE_ARRAY and not raw_items.is_empty():
		var item_norm := ItemInventoryService.normalize_item_grants(raw_items)
		if not bool(item_norm.get("valid", false)):
			result["valid"] = false
			result["validation_errors"] = item_norm.get("errors", [])
		else:
			result["items"] = item_norm.get("items", [])
	return result

func export_save_data() -> Dictionary:
	return {
		"transaction_sequence": _transaction_sequence,
		"last_transaction_id": str(last_transaction.get("transaction_id", ""))
	}

func apply_save_data(data: Dictionary) -> void:
	_transaction_sequence = maxi(int(data.get("transaction_sequence", 0)), 0)
