extends Node

var data: Dictionary = {}
var monster_by_id: Dictionary = {}
var loaded_region_id: String = ""
var loaded_catalog_path: String = ""

func _ready() -> void:
	reload_for_region(RegionProgressionSystem.combat_region_id())

func reload_for_region(region_id: String, force: bool = false) -> void:
	var catalog_path := RegionProgressionSystem.encounter_catalog_path(region_id)
	if catalog_path.is_empty():
		data = {"rotation": ["M001"], "boss_rotation": ["B001"], "monsters": [], "boss_every_kills": 10}
		monster_by_id.clear()
		loaded_region_id = region_id
		loaded_catalog_path = ""
		return
	if not force and loaded_catalog_path == catalog_path and not data.is_empty():
		loaded_region_id = region_id
		return
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	if not file:
		push_warning("Encounter catalog missing: %s" % catalog_path)
		data = {"rotation": ["M001"], "boss_rotation": ["B001"], "monsters": [], "boss_every_kills": 10}
		monster_by_id.clear()
		loaded_region_id = region_id
		loaded_catalog_path = catalog_path
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Encounter catalog invalid: %s" % catalog_path)
		data = {"rotation": ["M001"], "boss_rotation": ["B001"], "monsters": [], "boss_every_kills": 10}
		monster_by_id.clear()
		loaded_region_id = region_id
		loaded_catalog_path = catalog_path
		return
	data = parsed
	monster_by_id.clear()
	for entry in data.get("monsters", []):
		monster_by_id[str(entry.id)] = entry
	loaded_region_id = region_id
	loaded_catalog_path = catalog_path

func _boss_every() -> int:
	return maxi(int(data.get("boss_every_kills", RegionProgressionSystem.boss_every())), 1)

func boss_every_kills() -> int:
	return _boss_every()

func encounter_id_for_level(monster_level: int) -> String:
	var boss_every := _boss_every()
	if monster_level % boss_every == 0:
		var bosses: Array = data.get("boss_rotation", ["B001"])
		if bosses.is_empty():
			return "B001"
		var boss_index := maxi(int(monster_level / boss_every) - 1, 0) % bosses.size()
		return str(bosses[boss_index])
	var rotation: Array = data.get("rotation", ["M001"])
	if rotation.is_empty():
		return "M001"
	var non_boss_index := monster_level - 1 - int((monster_level - 1) / boss_every)
	if non_boss_index < rotation.size():
		return str(rotation[non_boss_index])
	var overflow: Array = data.get("rotation_overflow", [])
	if overflow.is_empty():
		return str(rotation[non_boss_index % rotation.size()])
	return str(overflow[(non_boss_index - rotation.size()) % overflow.size()])

func _texture_path(encounter_id: String, state: String) -> String:
	var requested := "attack" if state == "shield" else state
	var root := RegionProgressionSystem.monster_asset_root(loaded_region_id)
	if root.is_empty():
		root = "res://assets/monsters/greenvale/states"
	return "%s/%s_%s.png" % [root, encounter_id, requested]

func texture_for(monster_level: int, state: String) -> Texture2D:
	var id := encounter_id_for_level(monster_level)
	var path := _texture_path(id, state)
	if ResourceLoader.exists(path):
		return load(path)
	if state != "idle" and state != "shield":
		path = _texture_path(id, "idle")
		if ResourceLoader.exists(path):
			return load(path)
	return null

func display_name(monster_level: int) -> String:
	var id := encounter_id_for_level(monster_level)
	return str(monster_by_id.get(id, {}).get("name", id))

func is_boss(monster_level: int) -> bool:
	return encounter_id_for_level(monster_level).begins_with("B")

func encounter_definition(monster_level: int) -> Dictionary:
	var id := encounter_id_for_level(monster_level)
	return monster_by_id.get(id, {})

func monster_classification(monster_level: int) -> String:
	var def := encounter_definition(monster_level)
	if is_boss(monster_level):
		return "boss"
	return str(def.get("classification", "normal"))

func is_elite_or_special(monster_level: int) -> bool:
	var cls := monster_classification(monster_level)
	return cls in ["elite", "special"]

func display_scale(monster_level: int) -> float:
	var def := encounter_definition(monster_level)
	var visual: Dictionary = def.get("visual", {})
	var scale := float(visual.get("display_scale", 1.0))
	if is_boss(monster_level) and scale <= 1.0:
		return 1.08
	return scale

func display_offset(monster_level: int) -> Vector2:
	var def := encounter_definition(monster_level)
	var visual: Dictionary = def.get("visual", {})
	return Vector2(float(visual.get("offset_x", 0.0)), float(visual.get("offset_y", 0.0)))

func has_state(monster_level: int, state: String) -> bool:
	var id := encounter_id_for_level(monster_level)
	var requested := "attack" if state == "shield" else state
	return ResourceLoader.exists(_texture_path(id, requested))

func production_asset_id(monster_level: int) -> String:
	return encounter_id_for_level(monster_level)

func rotation_monster_ids() -> Array:
	return data.get("rotation", []).duplicate()

func boss_rotation_ids() -> Array:
	return data.get("boss_rotation", []).duplicate()
