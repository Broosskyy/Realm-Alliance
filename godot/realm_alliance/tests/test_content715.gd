extends SceneTree
const Gate=preload("res://scripts/launcher/update_gate715.gd")
const Cache=preload("res://scripts/launcher/content_cache715.gd")
const Store=preload("res://scripts/save_store.gd")
const Combat=preload("res://scripts/systems/combat_session.gd")
var checks=0
var failed=0
func test(v:bool,n:String) -> void:
    checks+=1
    if not v:
        failed+=1
        push_error("715: "+n)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/update715_manifest.json"))
    var p=manifest.packs[0]
    var q=manifest.packs[1]
    var picture=FileAccess.get_file_as_bytes("res://tests/fixtures/realm715_crystal.png")
    var catalog=FileAccess.get_file_as_bytes("res://tests/fixtures/realm715_catalog.json")
    test(Gate.inspect(manifest,715,"test").status=="content","manifest accepts two resources")
    test(Gate.inspect(manifest,714,"test").status=="app_required","714 cannot load 715 catalog")
    test(Gate.inspect(manifest,715,"stable").status=="invalid","channel isolated")
    test(Cache.valid(p,picture),"PNG length SHA and real image decoding")
    test(Cache.valid(q,catalog),"JSON SHA and schema")
    test(Cache.install(p,picture),"PNG written")
    test(Cache.install(q,catalog),"catalog written")
    test(Cache.installed(p) and Cache.installed(q),"both packs installed")
    test(Cache.texture("realm_stage_ornament")!=null,"PNG sprite loadable")
    var loaded_catalog=Cache.catalog()
    test(not loaded_catalog.is_empty() and loaded_catalog.get("items",[]) is Array and loaded_catalog.get("items",[]).size()>0 and str(loaded_catalog.get("items",[])[0].get("name",""))=="Smaragd-Vorposten","catalog read after install")
    var tampered=picture.duplicate()
    tampered[20]=tampered[20]^1
    test(not Cache.valid(p,tampered) and not Cache.install(p,tampered),"corrupt image rejected")
    test(Cache.installed(p),"previous PNG remains valid")
    var wrong=q.duplicate(true)
    wrong.url="https://evil.invalid/quests.json"
    test(not Gate.valid_pack(wrong),"remote URL locked")
    var reused=manifest.duplicate(true)
    reused.packs.append(p)
    test(Gate.inspect(reused,715,"test").status=="invalid","duplicate pack id forbidden")
    var initial=Combat.new({})
    var snapshot=initial.snapshot()
    test(Store._valid(snapshot),"initial save snapshot valid")
    test(Store.save_state(snapshot),"create test save")
    test(not Store.load_state().is_empty(),"save reloads")
    test(Store.reset_guest(),"guest reset clears all local sources")
    test(Store.load_state().is_empty(),"reset blocks recovery from disk or backup")
    test(FileAccess.file_exists(Store.RESET_MARKER),"tombstone survives before new save")
    test(Store.save_state(snapshot),"new guest can save")
    test(not FileAccess.file_exists(Store.RESET_MARKER),"first new valid save clears tombstone")
    test(not Store.load_state().is_empty(),"fresh guest save persists")
    test(Store.reset_guest() and Store.load_state().is_empty(),"second reset is idempotent")
    var launcher=preload("res://scenes/launcher713.tscn").instantiate()
    launcher.auto_check=false
    root.add_child(launcher)
    await process_frame
    test(is_instance_valid(launcher.find_child("RemotePatchBanner",true,false)),"launcher displays content slot")
    launcher.queue_free()
    await process_frame
    print("REALM 715 content+guest: %d/%d"%[checks-failed,checks])
    quit(1 if failed else 0)
