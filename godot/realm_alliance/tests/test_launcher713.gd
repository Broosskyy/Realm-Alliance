extends SceneTree
const Gate=preload("res://scripts/launcher/update_gate713.gd")
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
    item.packs=[{"id":"cosmetic_test"}]
    assert_case(Gate.inspect(item,713,"test").status=="content_pending","no false patch claim")
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
    print("REALM 713 launcher: %d/%d"%(checks-failed,checks))
    quit(1 if failed>0 else 0)
