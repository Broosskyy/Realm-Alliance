extends RefCounted
class_name RASaveStore

const SAVE_PATH: String = "user://realm_alliance_combat_v1.json"

static func load_state() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("Could not read save. Using fresh session.")
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_warning("Invalid save structure. Using fresh session.")
        return {}
    if int(parsed.get("version", -1)) != 1:
        push_warning("Unknown save version. Using fresh session.")
        return {}
    return parsed

static func save_state(data: Dictionary) -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_warning("Failed to open save file for writing.")
        return false
    file.store_string(JSON.stringify(data))
    file.flush()
    return file.get_error() == OK
