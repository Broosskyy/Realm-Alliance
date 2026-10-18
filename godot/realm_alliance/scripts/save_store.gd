extends RefCounted
class_name RASaveStore
const SAVE_PATH = "user://realm_alliance_combat_v2.json"
const LEGACY_PATH = "user://realm_alliance_combat_v1.json"
static var write_blocked: bool = false

static func _read(path: String) -> Dictionary:
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(path)) != OK:
        return {}
    return parser.data if parser.data is Dictionary else {}

static func load_state() -> Dictionary:
    write_blocked = false
    if FileAccess.file_exists(SAVE_PATH):
        var d = _read(SAVE_PATH)
        if int(d.get("version",0)) > 2:
            write_blocked = true
            return {"load_error":"Neuerer Spielstand: Laden und Speichern gesperrt.","read_only":true}
        if _valid(d):
            return d
        if FileAccess.file_exists(SAVE_PATH+".bak"):
            d = _read(SAVE_PATH+".bak")
            if _valid(d):
                d.load_error = "Sicherung wiederhergestellt; beschädigte Datei bleibt erhalten."
                DirAccess.copy_absolute(SAVE_PATH,SAVE_PATH+".damaged")
                return d
        write_blocked = true
        return {"load_error":"Spielstand beschädigt. Original bleibt unverändert; Speichern gesperrt.","read_only":true}
    if FileAccess.file_exists(LEGACY_PATH):
        var d = _read(LEGACY_PATH)
        if int(d.get("version",0)) == 1:
            return d
        write_blocked = true
        return {"load_error":"Alter Spielstand nicht lesbar. Original bleibt unverändert.","read_only":true}
    return {}

static func _valid(d: Dictionary) -> bool:
    if int(d.get("version",0)) != 2 or not d.get("profile") is Dictionary or not d.get("checkpoint") is Dictionary:
        return false
    var p:Dictionary=d.profile
    for key in ["gold","xp","kills","shards","run_serial","best_wave"]:
        if not p.has(key) or not (p[key] is int or p[key] is float):
            return false
    if not p.get("inventory") is Dictionary or not p.inventory.has(str(p.get("equipped",""))) or not p.get("claims") is Dictionary or not p.get("loot") is Array:
        return false
    for item in p.inventory.values():
        if not item is Dictionary or not item.has("level") or int(item.level)<1:
            return false
    return p.get("look") is String and p.get("aura") is bool


static func save_state(data: Dictionary) -> bool:
    if write_blocked or not _valid(data):
        return false
    var temp = SAVE_PATH+".tmp"
    var f = FileAccess.open(temp,FileAccess.WRITE)
    if f == null:
        return false
    f.store_string(JSON.stringify(data))
    f.flush()
    var ok = f.get_error() == OK
    f.close()
    if not ok or not _valid(_read(temp)):
        return false
    if FileAccess.file_exists(SAVE_PATH):
        if _valid(_read(SAVE_PATH)):
            if DirAccess.copy_absolute(SAVE_PATH,SAVE_PATH+".bak") != OK:
                return false
    if DirAccess.rename_absolute(temp,SAVE_PATH)!=OK:
        return false
    # FileAccess.close() schedules IDB sync for the temporary file. The atomic
    # rename happens afterwards, so explicitly queue another persistent sync.
    if OS.has_feature("web"):
        JavaScriptBridge.force_fs_sync()
    return true

static func install_import(data: Dictionary) -> bool:
    # This path is reached only after the player confirms a validated import.
    if not _valid(data): return false
    if FileAccess.file_exists(SAVE_PATH):
        var backup=SAVE_PATH+".before-import-"+str(Time.get_ticks_usec())
        if DirAccess.copy_absolute(SAVE_PATH,backup)!=OK: return false
    var blocked=write_blocked
    write_blocked=false
    if save_state(data): return true
    write_blocked=blocked
    return false
