extends SceneTree
const App=preload("res://scripts/launcher/app_update717.gd")
const Model=preload("res://scripts/systems/combat_session.gd")
var passes=0
var failures=0
func check(ok:bool,n:String):
    if ok:passes+=1
    else:failures+=1;push_error("718 update: "+n)
func _initialize()->void:call_deferred("run")
func run()->void:
    var game=Model.new({})
    check(not game.read_only,"fresh game can start")
    check(game.profile.hero_roster.owned.size()==1,"no extra unlocked heroes")
    var valid={"version_code":719,"package":App.PACKAGE,"certificate_sha256":App.CERT_SHA256,
      "bytes":90000000,"sha256":"0123456789abcdef".repeat(4),
      "url":App.RELEASE_ROOT+"realm-719-android/REALM_ALLIANCE_719.apk"}
    check(App.check(valid,718,719),"718 accepts only later release")
    check(not App.check(valid,719,719),"reinstall blocked")
    valid.certificate_sha256="ff".repeat(32)
    check(not App.check(valid,718,719),"wrong cert rejected")
    var launcher=preload("res://scenes/launcher713.tscn").instantiate()
    launcher.auto_check=false
    root.add_child(launcher)
    await process_frame
    check(launcher.VERSION_CODE==718,"launcher version 718")
    check(launcher.find_child("LaunchAppUpdate",true,false)!=null,"installer button available")
    launcher.queue_free()
    await process_frame
    print("REALM 718 OTA TEST: %d passed, %d failed"%[passes,failures])
    quit(1 if failures else 0)
