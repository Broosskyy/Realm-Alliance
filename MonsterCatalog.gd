extends Node

signal monster_definition_changed(definition: Dictionary)

var definitions: Dictionary = {}
var current_definition: Dictionary = {}

func _ready() -> void:
	_load_defs()
	refresh_for_level(PlayerData.monster_level)
	PlayerData.monster_changed.connect(func(): refresh_for_level(PlayerData.monster_level))

func _load_defs() -> void:
	var file := FileAccess.open("res://data/monsters.json", FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for monster in parsed.get("monsters", []):
		definitions[str(monster.id)] = monster

func refresh_for_level(level: int) -> void:
	var id := monster_id_for_level(level)
	var definition: Dictionary = definitions.get(id, {})
	if definition != current_definition:
		current_definition = definition
		monster_definition_changed.emit(current_definition)

func monster_id_for_level(level: int) -> String:
	if level % 10 == 0:
		return "ancient_treant"
	var cycle := (level - 1) % 3
	match cycle:
		0: return "slime"
		1: return "goblin"
		_: return "boar_brute"

func asset_id_for_level(level: int) -> String:
	match monster_id_for_level(level):
		"slime": return "monster_slime"
		"goblin": return "monster_goblin"
		"boar_brute": return "monster_boar"
		"ancient_treant": return "monster_treant_boss"
	return "monster_slime"

func display_name_for_level(level: int) -> String:
	var definition: Dictionary = definitions.get(monster_id_for_level(level), {})
	return str(definition.get("name", "Monster"))

func tier_for_level(level: int) -> String:
	var definition: Dictionary = definitions.get(monster_id_for_level(level), {})
	return str(definition.get("tier", "normal"))

func is_boss_level(level: int) -> bool:
	return level % 10 == 0
