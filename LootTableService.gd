extends Node
## V2.07 — data-driven loot rolls for RewardPipeline integration.

const DATA_PATH := "res://data/loot_tables_v207.json"
const CONFIG_VERSION := "v2.09-loot-02"

var sources: Dictionary = {}
var validation_errors: Array[String] = []

var qa_forced_roll: Dictionary = {}

func _ready() -> void:
	_load_and_validate()

func _load_and_validate() -> void:
	validation_errors.clear()
	sources.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		validation_errors.append("loot table file missing: %s" % DATA_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		validation_errors.append("loot table parse failed")
		return
	for source_id in parsed.get("sources", {}).keys():
		var source_def: Dictionary = parsed["sources"][source_id]
		_validate_source(str(source_id), source_def)
		sources[str(source_id)] = source_def
	if not sources.is_empty():
		for error in validation_errors:
			push_error("[LootTableService] %s" % error)

func _validate_source(source_id: String, source_def: Dictionary) -> void:
	if source_id.is_empty():
		validation_errors.append("empty loot source id")
		return
	for entry in source_def.get("guaranteed", []):
		_validate_entry(source_id, entry, true)
	for entry in source_def.get("weighted_entries", []):
		_validate_entry(source_id, entry, false)

func _validate_entry(source_id: String, entry: Dictionary, guaranteed: bool) -> void:
	var item_id := str(entry.get("item_id", ""))
	if item_id.is_empty():
		validation_errors.append("%s: entry missing item_id" % source_id)
		return
	if not ItemInventoryService.has_item_definition(item_id):
		validation_errors.append("%s: unknown item_id %s" % [source_id, item_id])
	if not guaranteed and float(entry.get("weight", 0)) <= 0.0:
		validation_errors.append("%s: weight must be > 0 for %s" % [source_id, item_id])

func set_qa_forced_roll(source_id: String, item_id: String, quantity: int = 1) -> void:
	qa_forced_roll[source_id] = {"item_id": item_id, "quantity": maxi(quantity, 1)}

func clear_qa_forced_roll() -> void:
	qa_forced_roll.clear()

func roll(source_id: String) -> Array:
	if qa_forced_roll.has(source_id):
		var forced: Dictionary = qa_forced_roll[source_id]
		return [{"item_id": str(forced.get("item_id", "")), "quantity": maxi(int(forced.get("quantity", 1)), 1)}]
	var source_def: Dictionary = sources.get(source_id, {})
	if source_def.is_empty():
		return []
	var out: Array = []
	for entry in source_def.get("guaranteed", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var item_id := str(entry.get("item_id", ""))
		if item_id.is_empty():
			continue
		out.append({"item_id": item_id, "quantity": maxi(int(entry.get("quantity", 1)), 1)})
	var weighted: Array = []
	var total_weight := 0.0
	for entry in source_def.get("weighted_entries", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var weight := float(entry.get("weight", 0))
		if weight <= 0.0:
			continue
		total_weight += weight
		weighted.append(entry)
	if total_weight > 0.0 and not weighted.is_empty():
		var pick := randf() * total_weight
		var cursor := 0.0
		for entry in weighted:
			cursor += float(entry.get("weight", 0))
			if pick <= cursor:
				out.append({
					"item_id": str(entry.get("item_id", "")),
					"quantity": maxi(int(entry.get("quantity", 1)), 1)
				})
				break
	return out

func chest_source_for_tier(tier: String) -> String:
	return "chest_%s" % tier
