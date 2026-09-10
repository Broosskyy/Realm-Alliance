extends Node

const INDEX_PATH := "res://data/generated_asset_index_v160.json"
const RULES_PATH := "res://data/asset_rules_v190.json"
const CONFIDENCE_PATH := "res://data/asset_confidence_v160.json"
const CONTRACTS_PATH := "res://data/screen_asset_contracts_v190.json"

var index: Dictionary = {}
var rules: Dictionary = {}
var confidence: Dictionary = {}
var contracts: Dictionary = {}

func _ready() -> void:
	reload_all()

func reload_all() -> void:
	index = _read_json(INDEX_PATH)
	rules = _read_json(RULES_PATH)
	confidence = _read_json(CONFIDENCE_PATH)
	contracts = _read_json(CONTRACTS_PATH)

func _read_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("SemanticAssetRegistry missing: %s" % path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func texture_for_role(role_id: String, allow_medium := false) -> Texture2D:
	# Canonical runtime bindings remain the source of truth. This facade adds
	# rules/contracts and gives future generated mappings one stable API.
	if has_node("/root/ProductionAssetRegistry"):
		return ProductionAssetRegistry.bound_texture(role_id, allow_medium)
	return null

func binding_info(role_id: String) -> Dictionary:
	if has_node("/root/ProductionAssetRegistry"):
		return ProductionAssetRegistry.binding_info(role_id)
	return {}

func family_rules(family_id: String) -> Dictionary:
	return rules.get("families", {}).get(family_id, {}).duplicate(true)

func screen_contract(screen_id: String) -> Dictionary:
	return contracts.get("screens", {}).get(screen_id, {}).duplicate(true)

func asset_meta(path_or_id: String) -> Dictionary:
	if path_or_id.begins_with("atlas:"):
		return index.get("virtual_assets", {}).get(path_or_id, {}).duplicate(true)
	return index.get("assets", {}).get(path_or_id, {}).duplicate(true)

func canonical_path(path: String) -> String:
	var entry: Dictionary = index.get("assets", {}).get(path, {})
	var alias := str(entry.get("alias_to", ""))
	return alias if not alias.is_empty() else path

func is_resolved_placeholder(path: String) -> bool:
	var entry: Dictionary = index.get("assets", {}).get(path, {})
	return bool(entry.get("placeholder_resolved_by_alias", false))

func duplicate_groups() -> Array:
	return index.get("duplicate_groups", []).duplicate(true)

func pipeline_stats() -> Dictionary:
	return index.get("stats", {}).duplicate(true)
