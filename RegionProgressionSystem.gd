extends Node

signal region_progress_changed(region_id: String)

const DATA_PATH := "res://data/regions.json"
const CONFIG_VERSION := "v2.08-region-catalog-01"

var regions: Array = []
var region_by_id: Dictionary = {}

# Player state (persisted via SaveGame)
var current_region_id: String = "greenvale"
var region_progress: Dictionary = {}

func _ready() -> void:
	_load_config()
	_ensure_region_progress_defaults()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("Region config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	regions = parsed.get("regions", [])
	region_by_id.clear()
	for region in regions:
		var rid := str(region.get("id", ""))
		if not rid.is_empty():
			region_by_id[rid] = region

func _ensure_region_progress_defaults() -> void:
	for region in regions:
		var rid := str(region.get("id", ""))
		if rid.is_empty():
			continue
		if not region_progress.has(rid):
			region_progress[rid] = _default_progress_entry()

func _default_progress_entry() -> Dictionary:
	return {
		"encounters_cleared": 0,
		"bosses_defeated": 0,
		"boss_cycle_complete": false,
		"highest_stage": 0
	}

func region_def(id: String) -> Dictionary:
	return region_by_id.get(id, {})

func is_unlocked(id: String) -> bool:
	var region := region_def(id)
	if region.is_empty():
		return false
	return PlayerData.player_level >= int(region.get("unlock_level", 999999))

func is_playable(id: String) -> bool:
	if not is_unlocked(id):
		return false
	if bool(region_def(id).get("preview_only", false)):
		return false
	return not str(region_def(id).get("encounter_catalog", "")).is_empty()

func unlocked_regions() -> Array:
	var out: Array = []
	for region in regions:
		if is_unlocked(str(region.get("id", ""))):
			out.append(region)
	return out

func playable_regions() -> Array:
	var out: Array = []
	for region in regions:
		if is_playable(str(region.get("id", ""))):
			out.append(region)
	return out

func combat_region_id() -> String:
	# Combat authority: first playable region with encounter content.
	for region in regions:
		var rid := str(region.get("id", ""))
		if is_playable(rid):
			return rid
	return "greenvale"

func active_region_id() -> String:
	if is_playable(current_region_id):
		return current_region_id
	return combat_region_id()

func active_region_name() -> String:
	return str(region_def(active_region_id()).get("name", "Grünhain"))

func active_region_name_upper() -> String:
	return active_region_name().to_upper()

func encounter_catalog_path(region_id: String = "") -> String:
	var rid := region_id if not region_id.is_empty() else combat_region_id()
	return str(region_def(rid).get("encounter_catalog", ""))

func monster_asset_root(region_id: String = "") -> String:
	var rid := region_id if not region_id.is_empty() else combat_region_id()
	return str(region_def(rid).get("monster_asset_root", ""))

func background_asset_path(region_id: String = "") -> String:
	var rid := region_id if not region_id.is_empty() else active_region_id()
	return str(region_def(rid).get("background_asset", ""))

func boss_every(region_id: String = "") -> int:
	var rid := region_id if not region_id.is_empty() else combat_region_id()
	return maxi(int(region_def(rid).get("boss_every", 10)), 1)

func loot_source_for(kind: String, region_id: String = "") -> String:
	var rid := region_id if not region_id.is_empty() else combat_region_id()
	var sources: Dictionary = region_def(rid).get("loot_sources", {})
	var source_id := str(sources.get(kind, ""))
	if source_id.is_empty():
		# Legacy fallback for global tables.
		return "boss" if kind == "boss" else kind
	return source_id

func progress_entry(region_id: String) -> Dictionary:
	_ensure_region_progress_defaults()
	return region_progress.get(region_id, _default_progress_entry())

func record_encounter_cleared(region_id: String, stage: int, boss: bool) -> void:
	_ensure_region_progress_defaults()
	var entry: Dictionary = region_progress.get(region_id, _default_progress_entry()).duplicate(true)
	entry["encounters_cleared"] = int(entry.get("encounters_cleared", 0)) + 1
	entry["highest_stage"] = maxi(int(entry.get("highest_stage", 0)), stage)
	if boss:
		entry["bosses_defeated"] = int(entry.get("bosses_defeated", 0)) + 1
		var boss_ids: Array = region_def(region_id).get("boss_ids", [])
		if boss_ids.size() > 0 and int(entry.get("bosses_defeated", 0)) >= boss_ids.size():
			entry["boss_cycle_complete"] = true
	region_progress[region_id] = entry
	region_progress_changed.emit(region_id)

func next_region() -> Dictionary:
	for region in regions:
		if not is_unlocked(str(region.get("id", ""))):
			return region
	return {}

func progress_to_next_region() -> Dictionary:
	var next := next_region()
	if next.is_empty():
		return {"complete": true, "progress": 1.0}
	var target := maxi(int(next.get("unlock_level", 1)), 1)
	var previous_unlock := 1
	for region in regions:
		var unlock := int(region.get("unlock_level", 1))
		if unlock < target:
			previous_unlock = maxi(previous_unlock, unlock)
	var span := maxi(target - previous_unlock, 1)
	var current := clampi(PlayerData.player_level - previous_unlock, 0, span)
	return {
		"complete": false,
		"region_id": str(next.get("id", "")),
		"name": str(next.get("name", "")),
		"unlock_level": target,
		"levels_remaining": maxi(target - PlayerData.player_level, 0),
		"progress": clampf(float(current) / float(span), 0.0, 1.0)
	}

func export_save_data() -> Dictionary:
	return {
		"config_version": CONFIG_VERSION,
		"current_region_id": current_region_id,
		"region_progress": region_progress.duplicate(true)
	}

func import_save_data(data: Dictionary) -> void:
	if typeof(data) != TYPE_DICTIONARY or data.is_empty():
		return
	current_region_id = str(data.get("current_region_id", "greenvale"))
	region_progress = data.get("region_progress", {}).duplicate(true)
	_ensure_region_progress_defaults()

func reset_runtime() -> void:
	current_region_id = "greenvale"
	region_progress.clear()
	_ensure_region_progress_defaults()
