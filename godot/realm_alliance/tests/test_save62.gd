extends SceneTree
const Store=preload("res://scripts/save_store.gd")
const Session=preload("res://scripts/systems/combat_session.gd")
var failures=0
var checks=0
func check(ok: bool,text: String) -> void:
    checks+=1
    if not ok: failures+=1;push_error("FAIL "+text)
func write(path: String, text: String) -> void:
    var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(text);f.close()
func _initialize() -> void:
    # Refuse to touch a normal player's profile; CI and documented local commands
    # must use a separate test data directory via XDG_DATA_HOME.
    if not OS.get_environment("XDG_DATA_HOME").contains("realm62-test"):
        push_error("Run save tests with XDG_DATA_HOME=/tmp/realm62-test-save")
        quit(1);return
    for path in [Store.SAVE_PATH,Store.SAVE_PATH+".bak",Store.SAVE_PATH+".tmp",Store.SAVE_PATH+".damaged",Store.LEGACY_PATH]:
        if FileAccess.file_exists(path):DirAccess.remove_absolute(path)
    var legacy={"version":1,"gold":321,"wave":4,"weapon_index":1,"upgrade_level":2,"total_kills":3}
    var bytes=JSON.stringify(legacy)
    write(Store.LEGACY_PATH,bytes)
    check(int(Store.load_state().gold)==321 and int(Store.load_state().wave)==4,"reads original v1")
    var s=Session.new(Store.load_state())
    check(Store.save_state(s.snapshot()),"writes migrated v2")
    check(FileAccess.get_file_as_string(Store.LEGACY_PATH)==bytes,"v1 byte contents unchanged")
    check(Store.load_state().profile.gold==321,"v2 takes precedence")
    s.gold=654
    check(Store.save_state(s.snapshot()),"atomic next write succeeds")
    check(JSON.parse_string(FileAccess.get_file_as_string(Store.SAVE_PATH+".bak")).profile.gold==321,"backup contains preceding valid profile")
    write(Store.SAVE_PATH,'{"broken":')
    var recovered=Store.load_state()
    check(recovered.profile.gold==321 and recovered.has("load_error"),"corrupt v2 restores backup with notice")
    check(FileAccess.get_file_as_string(Store.SAVE_PATH+".damaged")=='{"broken":',"corrupt source retained")
    check(Store.save_state(Session.new(recovered).snapshot()),"recovered backup can be committed")
    write(Store.SAVE_PATH,'{"version":99,"future":"preserve-me"}')
    check(Store.load_state().read_only,"future schema enters explicit read-only mode")
    check(not Store.save_state(s.snapshot()) and FileAccess.get_file_as_string(Store.SAVE_PATH).contains("preserve-me"),"future schema never overwritten")
    DirAccess.remove_absolute(Store.SAVE_PATH+".bak")
    write(Store.SAVE_PATH,'{"version":2,"profile":{"gold":5}}')
    check(Store.load_state().read_only,"invalid nested data rejected without reset write")
    check(not Store.save_state(s.snapshot()),"corrupt no-backup profile protected")
    for path in [Store.SAVE_PATH,Store.SAVE_PATH+".bak",Store.SAVE_PATH+".tmp",Store.SAVE_PATH+".damaged",Store.LEGACY_PATH]:
        if FileAccess.file_exists(path):DirAccess.remove_absolute(path)
    print("Save 6.2: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
