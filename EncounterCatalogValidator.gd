extends RefCounted
class_name EncounterCatalogValidator

const VALID_CLASSIFICATIONS := ["normal", "tough", "elite", "boss", "special"]
const LEGACY_MONSTER_IDS := ["slime", "goblin", "boar_brute", "ancient_treant"]
const LEGACY_PLACEHOLDER_PATHS := [
	"res://assets/monsters/greenvale/monster_slime_01_placeholder.png",
	"res://assets/monsters/greenvale/monster_goblin_01_placeholder.png",
	"res://assets/monsters/greenvale/monster_boar_brute_01_placeholder.png",
	"res://assets/monsters/greenvale/monster_boar_boss_placeholder.png",
	"res://assets/monsters/greenvale/monster_treant_boss_01_placeholder.png"
]
const STATES := ["idle", "attack", "hit", "defeat"]
const CURATED_EARLY_ONBOARDING := ["M001", "M012", "M002", "M003", "M004", "M005"]
const CURATED_PHASE2_ROTATION := [
	"M001", "M012", "M002", "M003", "M004", "M005",
	"M006", "M013", "M008", "M011", "M004", "M012", "M003", "M010"
]

static func validate_catalog(catalog: Dictionary, region_id: String = "greenvale") -> Array[String]:
	var errors: Array[String] = []
	if catalog.is_empty():
		errors.append("encounter catalog empty")
		return errors

	var monsters: Array = catalog.get("monsters", [])
	var by_id := {}
	for entry in monsters:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var mid := str(entry.get("id", ""))
		if mid.is_empty():
			errors.append("monster entry missing id")
			continue
		if by_id.has(mid):
			errors.append("duplicate monster id %s" % mid)
		by_id[mid] = entry
		errors.append_array(_validate_monster_entry(entry, region_id))

	var rotation: Array = catalog.get("rotation", [])
	if rotation.is_empty():
		errors.append("rotation empty")
	for rid in rotation:
		if not by_id.has(str(rid)):
			errors.append("rotation references unknown id %s" % str(rid))

	for boss_id in catalog.get("boss_rotation", []):
		if not by_id.has(str(boss_id)):
			errors.append("boss_rotation references unknown id %s" % str(boss_id))

	errors.append_array(_validate_curated_sequence(rotation, by_id))

	var boss_every := maxi(int(catalog.get("boss_every_kills", 10)), 1)
	if rotation.size() != boss_every - 1:
		errors.append(
			"rotation size %d must equal boss_every-1 (%d)" % [rotation.size(), boss_every - 1]
		)

	for overflow_id in catalog.get("rotation_overflow", []):
		if not by_id.has(str(overflow_id)):
			errors.append("rotation_overflow references unknown id %s" % str(overflow_id))

	errors.append_array(_validate_no_legacy_runtime_refs(catalog))
	return errors

static func _validate_monster_entry(entry: Dictionary, region_id: String) -> Array[String]:
	var errors: Array[String] = []
	var mid := str(entry.get("id", ""))
	var status := str(entry.get("production_status", ""))
	if status == "deprecated":
		return errors

	var cls := str(entry.get("classification", ""))
	if cls not in VALID_CLASSIFICATIONS:
		errors.append("%s: invalid classification %s" % [mid, cls])

	var stats: Dictionary = entry.get("stats", {})
	if stats.is_empty():
		errors.append("%s: missing stats block" % mid)
	else:
		if int(stats.get("base_hp", 0)) <= 0:
			errors.append("%s: base_hp must be > 0" % mid)
		if float(stats.get("hp_scaling", 1.0)) <= 0.0:
			errors.append("%s: hp_scaling must be > 0" % mid)
		if int(stats.get("xp_reward", 0)) <= 0:
			errors.append("%s: xp_reward must be > 0" % mid)
		var loot_source := str(stats.get("loot_source", ""))
		if loot_source.is_empty():
			errors.append("%s: loot_source missing" % mid)
		elif not LootTableService.sources.has(loot_source):
			errors.append("%s: unknown loot_source %s" % [mid, loot_source])

	var root := RegionProgressionSystem.monster_asset_root(region_id)
	for state in STATES:
		var path := "%s/%s_%s.png" % [root, mid, state]
		if not ResourceLoader.exists(path):
			errors.append("%s: missing production asset %s" % [mid, path])

	return errors

static func _validate_curated_sequence(rotation: Array, by_id: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if rotation.size() < CURATED_EARLY_ONBOARDING.size():
		errors.append("rotation shorter than early onboarding block")
		return errors
	for i in range(CURATED_EARLY_ONBOARDING.size()):
		if str(rotation[i]) != CURATED_EARLY_ONBOARDING[i]:
			errors.append(
				"early onboarding mismatch at %d: expected %s got %s" % [
					i + 1,
					CURATED_EARLY_ONBOARDING[i],
					str(rotation[i])
				]
			)
	if rotation.size() >= CURATED_PHASE2_ROTATION.size():
		for i in range(CURATED_PHASE2_ROTATION.size()):
			if str(rotation[i]) != CURATED_PHASE2_ROTATION[i]:
				errors.append(
					"phase2 rotation mismatch at %d: expected %s got %s" % [
						i + 1,
						CURATED_PHASE2_ROTATION[i],
						str(rotation[i])
					]
				)
	var elite_index := rotation.find("M010")
	if elite_index < 0:
		errors.append("M010 missing from rotation")
	elif elite_index != rotation.size() - 1:
		errors.append("M010 must be last pre-boss slot (index %d)" % elite_index)
	for reserve_id in ["M007", "M014"]:
		if reserve_id in rotation:
			errors.append("reserve overlap monster %s must not be in active rotation" % reserve_id)
	if "M006" in rotation and "M007" in rotation:
		errors.append("only one owl (M006/M007) allowed in active rotation")
	return errors

static func _validate_no_legacy_runtime_refs(catalog: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for legacy_id in LEGACY_MONSTER_IDS:
		for key in ["rotation", "rotation_overflow", "boss_rotation"]:
			if str(legacy_id) in catalog.get(key, []):
				errors.append("legacy monster id %s referenced in %s" % [legacy_id, key])
	for path in LEGACY_PLACEHOLDER_PATHS:
		if _catalog_references_asset(catalog, path):
			errors.append("catalog references legacy placeholder %s" % path)
	return errors

static func _catalog_references_asset(catalog: Dictionary, asset_path: String) -> bool:
	for entry in catalog.get("monsters", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if str(entry.get("asset_path", "")) == asset_path:
			return true
	return false

static func validate_greenvale() -> Array[String]:
	var path := RegionProgressionSystem.encounter_catalog_path("greenvale")
	if path.is_empty() or not FileAccess.file_exists(path):
		return ["greenvale encounter catalog missing"]
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ["greenvale encounter catalog unreadable"]
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return ["greenvale encounter catalog parse failed"]
	return validate_catalog(parsed, "greenvale")
