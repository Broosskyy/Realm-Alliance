extends RefCounted
class_name RASkillDefinition

static var _catalog: Dictionary = {}

static func catalog() -> Dictionary:
    if _catalog.is_empty():
        _catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/combat_catalog.json"))
    return _catalog

static func all() -> Dictionary:
    var result: Dictionary = {}
    for definition in catalog().skills:
        result[definition.id] = definition
    return result
