extends Node

const ENCOUNTER_PATH := "res://data/encounters_greenvale_p0_v1_4.json"
var data: Dictionary = {}
var monster_by_id: Dictionary = {}

func _ready() -> void:
	var file := FileAccess.open(ENCOUNTER_PATH, FileAccess.READ)
	if not file:
		push_warning("P0 encounter data missing: %s" % ENCOUNTER_PATH)
		data = {"rotation":["M001"],"boss_rotation":["B001"],"monsters":[]}
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("P0 encounter data invalid")
		data = {"rotation":["M001"],"boss_rotation":["B001"],"monsters":[]}
		return
	data = parsed
	monster_by_id.clear()
	for entry in data.get("monsters", []):
		monster_by_id[str(entry.id)] = entry

func encounter_id_for_level(monster_level: int) -> String:
	var boss_every := maxi(int(data.get("boss_every_kills",10)),1)
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
	return str(rotation[non_boss_index % rotation.size()])

func texture_for(monster_level: int, state: String) -> Texture2D:
	var id := encounter_id_for_level(monster_level)
	var requested := state
	# Historical boss special state now resolves to the authored Attack pose.
	if requested == "shield":
		requested = "attack"
	var path := "res://assets/monsters/greenvale/states/%s_%s.png" % [id, requested]
	if ResourceLoader.exists(path):
		return load(path)
	if requested != "idle":
		path = "res://assets/monsters/greenvale/states/%s_idle.png" % id
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

func has_state(monster_level: int, state: String) -> bool:
	var id := encounter_id_for_level(monster_level)
	var requested := "attack" if state == "shield" else state
	return ResourceLoader.exists("res://assets/monsters/greenvale/states/%s_%s.png" % [id, requested])

func production_asset_id(monster_level: int) -> String:
	return encounter_id_for_level(monster_level)
