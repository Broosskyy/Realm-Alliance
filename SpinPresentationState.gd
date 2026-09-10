extends Node

var pending_result: Dictionary = {}
var pending_config_version: String = ""

func has_pending_result() -> bool:
	return not pending_result.is_empty()

func set_pending_result(result: Dictionary, config_version: String) -> void:
	pending_result = _normalize_result(result)
	pending_config_version = config_version

func peek_pending_result() -> Dictionary:
	return pending_result.duplicate(true)

func acknowledge_pending_result() -> void:
	pending_result = {}
	pending_config_version = ""

func export_save_data() -> Dictionary:
	if pending_result.is_empty():
		return {}
	return {
		"pending_result":pending_result,
		"config_version":pending_config_version
	}

func apply_save_data(data: Dictionary) -> void:
	var result = data.get("pending_result",{})
	pending_result = _normalize_result(result) if typeof(result) == TYPE_DICTIONARY else {}
	pending_config_version = str(data.get("config_version",pending_result.get("config_version","")))

func _normalize_result(source: Dictionary) -> Dictionary:
	if source.is_empty():
		return {}
	var result := source.duplicate(true)
	var legacy_id := str(result.get("segment_id","legacy_reward"))
	if not result.has("result_id"):
		result["result_id"] = "legacy_pending_%s" % legacy_id
	if not result.has("reward_id"):
		result["reward_id"] = legacy_id
	if not result.has("reward_type"):
		result["reward_type"] = str(result.get("type","none"))
	if not result.has("reward_value"):
		result["reward_value"] = int(result.get("amount",0))
	if not result.has("visual_symbol_id"):
		result["visual_symbol_id"] = legacy_id
	if not result.has("visual_symbol_index"):
		result["visual_symbol_index"] = int(result.get("segment_index",0))
	if not result.has("visual_seed"):
		result["visual_seed"] = 1
	if not result.has("outcome_seed"):
		result["outcome_seed"] = 0
	if not result.has("result_contract_version"):
		result["result_contract_version"] = "legacy-migrated"
	if not result.has("reel_stop_ids"):
		var stops: Array = result.get("reel_stops",[0,0,0])
		var symbol_id := str(result.get("visual_symbol_id",legacy_id))
		result["reel_stop_ids"] = [
			"legacy_reel_1_stop_%d_%s" % [int(stops[0]),symbol_id],
			"legacy_reel_2_stop_%d_%s" % [int(stops[1]),symbol_id],
			"legacy_reel_3_stop_%d_%s" % [int(stops[2]),symbol_id]
		]
	return result
