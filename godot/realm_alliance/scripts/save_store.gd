extends RefCounted
class_name RASaveStore
const SAVE_PATH = "user://realm_alliance_combat_v2.json"
const LEGACY_PATH = "user://realm_alliance_combat_v1.json"
const RESET_MARKER="user://realm_alliance_guest_reset_715.flag"
const WebJournal=preload("res://scripts/web_save_journal.gd")
static var write_blocked: bool = false
static var _local_commit: int = 0

static func _newest(disk: Dictionary, journal: Dictionary) -> Dictionary:
    # Both candidates are independently validated; wall clock is a local ordering
    # aid only, incremented monotonically within this client, not online authority.
    if _valid(journal) and (not _valid(disk) or int(journal.get("_local_commit",0))>=int(disk.get("_local_commit",0))):
        return journal
    return disk

static func _read(path: String) -> Dictionary:
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(path)) != OK:
        return {}
    return parser.data if parser.data is Dictionary else {}

static func load_state() -> Dictionary:
    write_blocked = false
    # Keep stale journal/backups from resurrecting intentionally reset local progress.
    if FileAccess.file_exists(RESET_MARKER):
        _local_commit=0
        return {}
    var journal=WebJournal.read()
    var disk=_read(SAVE_PATH) if FileAccess.file_exists(SAVE_PATH) else {}
    _local_commit=maxi(int(journal.get("_local_commit",0)),int(disk.get("_local_commit",0)))
    if int(journal.get("version",0))>2 or int(disk.get("version",0))>2:
        write_blocked=true
        return {"load_error":"Neuerer Spielstand: Laden und Speichern gesperrt.","read_only":true}
    var newest=_newest(disk,journal)
    if _valid(newest):
        if FileAccess.file_exists(SAVE_PATH) and not _valid(disk):
            DirAccess.copy_absolute(SAVE_PATH,SAVE_PATH+".damaged")
            newest.load_error="Web-Sicherung wiederhergestellt; beschädigte Datei bleibt erhalten."
        return newest
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
    var payload=data.duplicate(true)
    if OS.has_feature("web"):
        _local_commit=maxi(_local_commit+1,int(Time.get_unix_time_from_system()*1000000))
        payload._local_commit=_local_commit
    f.store_string(JSON.stringify(payload))
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
        if not WebJournal.commit(payload):return false
    if FileAccess.file_exists(RESET_MARKER):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(RESET_MARKER))
    return true

static func install_import(data: Dictionary) -> bool:
    # This path is reached only after the player confirms a validated import.
    if not _valid(data): return false
    if not WebJournal.backup_before_import():return false
    if FileAccess.file_exists(SAVE_PATH):
        var backup=SAVE_PATH+".before-import-"+str(Time.get_ticks_usec())
        if DirAccess.copy_absolute(SAVE_PATH,backup)!=OK: return false
    var blocked=write_blocked
    write_blocked=false
    if save_state(data): return true
    write_blocked=blocked
    return false

# Invoked only from a locally authenticated-as-guest screen after confirmation.
# A persistent tombstone prevents old backups or an IndexedDB journal from reviving.
static func reset_guest() -> bool:
    # Tombstone FIRST. If any removal fails, old data must never be loaded.
    var marker=FileAccess.open(RESET_MARKER,FileAccess.WRITE)
    if marker==null:return false
    marker.store_string("Guest reset: all earlier player state is invalid.")
    marker.flush()
    var wrote=marker.get_error()==OK
    marker.close()
    if not wrote:return false
    var targets=[SAVE_PATH,SAVE_PATH+".bak",SAVE_PATH+".tmp",SAVE_PATH+".damaged",LEGACY_PATH]
    # Remove local import backups too; they contain complete previous inventories.
    var directory=DirAccess.open("user://")
    if directory!=null:
        directory.list_dir_begin()
        var name=directory.get_next()
        while name!="":
            if not directory.current_is_dir() and name.begins_with("realm_alliance_combat_v2.json.before-import-"):
                targets.append("user://"+name)
            name=directory.get_next()
        directory.list_dir_end()
    var all_removed=true
    for path in targets:
        if FileAccess.file_exists(path):
            if DirAccess.remove_absolute(ProjectSettings.globalize_path(path))!=OK:all_removed=false
    if not all_removed:return false
    if not WebJournal.clear_guest():return false
    if OS.has_feature("web"):JavaScriptBridge.force_fs_sync()
    _local_commit=0
    write_blocked=false
    return load_state().is_empty()

static func fresh_profile_ok() -> bool:
    # Validate the real model factory, not the source file deletion alone.
    var new_game=preload("res://scripts/systems/combat_session.gd").new({})
    var p:Dictionary=new_game.profile
    if new_game.read_only:return false
    if int(p.get("xp",-1))!=0 or int(p.get("gold",-1))!=0 or int(p.get("shards",-1))!=0 or int(p.get("kills",-1))!=0:return false
    if p.get("inventory") is not Dictionary or p.inventory.size()!=1 or not p.inventory.has("steel"):return false
    if p.get("hero_roster") is not Dictionary or p.hero_roster.owned.size()!=1 or not p.hero_roster.owned.has("runenpaladin"):return false
    if p.get("companions") is not Dictionary or not p.companions.owned.is_empty() or str(p.companions.active)!="":return false
    if p.has("character712"):return false
    return true
