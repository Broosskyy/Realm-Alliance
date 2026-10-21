extends SceneTree
const Gate=preload("res://scripts/launcher/update_gate713.gd")
const Cache=preload("res://scripts/launcher/content_cache713.gd")
var checks=0
var failed=0
func assert_case(value:bool,label:String) -> void:
    checks+=1
    if not value:failed+=1;push_error("Launcher 713: "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var good={"schema":1,"channel":"test","min_app_version_code":713,"latest_app_version_code":713,"packs":[]}
    assert_case(Gate.inspect(good,713,"test").status=="current","current")
    assert_case(Gate.inspect(good,712,"test").status=="app_required","required update")
    var item=good.duplicate(true)
    item.min_app_version_code=712
    assert_case(Gate.inspect(item,712,"test").status=="app_optional","optional update")
    assert_case(Gate.inspect(good,713,"stable").status=="invalid","channel")
    assert_case(Gate.inspect(null,713,"test").status=="invalid","not a dictionary")
    item=good.duplicate(true)
    item.schema=999
    assert_case(Gate.inspect(item,713,"test").status=="invalid","schema")
    item=good.duplicate(true)
    var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://data/update713_manifest.json"))
    var pack=manifest.packs[0]
    item.packs=[pack]
    assert_case(Gate.inspect(item,713,"test").status=="content_pending","valid content")
    var source=FileAccess.get_file_as_bytes("res://data/updates713/news-v1.json")
    assert_case(Cache.valid_bytes(pack,source),"pack digest and typed JSON")
    assert_case(Cache.install(pack,source),"atomic installation")
    assert_case(Cache.installed(pack),"cached verified")
    assert_case(Cache.read(pack).title=="Neues aus dem Reich","downloaded content available")
    var tampered=source.duplicate()
    tampered[0]=88
    assert_case(not Cache.valid_bytes(pack,tampered),"tampered payload rejected")
    assert_case(not Cache.install(pack,tampered),"bad update cannot replace previous")
    assert_case(Cache.installed(pack),"previous content remains valid")
    var unsafe=pack.duplicate(true)
    unsafe.url="http://malicious.invalid/patch.json"
    assert_case(not Gate.valid_pack(unsafe),"reject insecure endpoint")
    unsafe=pack.duplicate(true)
    unsafe.sha256="0"
    assert_case(not Gate.valid_pack(unsafe),"reject missing digest")
    item=good.duplicate(true)
    item.latest_app_version_code=0
    assert_case(Gate.inspect(item,713,"test").status=="invalid","bad version")
    var screen=preload("res://scenes/launcher713.tscn").instantiate()
    screen.auto_check=false
    root.add_child(screen)
    await process_frame
    for name in ["LaunchStatus","LaunchPlay","LaunchAccount","LaunchRetry","LaunchProgress","LaunchScroll"]:
        assert_case(is_instance_valid(screen.find_child(name,true,false)),name+" exists")
    screen.queue_free()
    await process_frame
    print("REALM 713 launcher: %d/%d"%[checks-failed,checks])
    quit(1 if failed>0 else 0)
