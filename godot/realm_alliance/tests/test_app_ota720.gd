extends SceneTree
const App=preload("res://scripts/launcher/app_update717.gd")
const Model=preload("res://scripts/systems/combat_session.gd")
var passes=0
var failures=0
func check(ok:bool,n:String):
    if ok:passes+=1
    else:failures+=1;push_error("720 update: "+n)
func _initialize()->void:call_deferred("run")
func run()->void:
    var game=Model.new({})
    check(not game.read_only,"fresh game can start")
    check(game.profile.hero_roster.owned.size()==1,"no extra unlocked heroes")
    var valid={"version_code":721,"package":App.PACKAGE,"certificate_sha256":App.CERT_SHA256,
      "bytes":90000000,"sha256":"0123456789abcdef".repeat(4),
      "url":App.RELEASE_ROOT+"realm-721-android/REALM_ALLIANCE_721.apk"}
    check(App.check(valid,720,721),"720 accepts only later release")
    check(App.download_timeout(131748445)==0.0,"large APK must never inherit metadata 8s timeout")
    check(App.error_text(HTTPRequest.RESULT_TIMEOUT,0)=="Zeitlimit erreicht","timeout visible to player")
    var parsed:Dictionary=JSON.parse_string(JSON.stringify(valid))
    check(App.check(parsed,720,721),"a real HTTP JSON manifest must pass release validator")
    check(not App.check(valid,721,721),"reinstall blocked")
    valid.certificate_sha256="ff".repeat(32)
    check(not App.check(valid,720,721),"wrong cert rejected")
    var launcher=preload("res://scenes/launcher713.tscn").instantiate()
    launcher.auto_check=false
    root.add_child(launcher)
    await process_frame
    check(launcher.VERSION_CODE==720,"launcher version 720")
    check(launcher.find_child("LaunchAppUpdate",true,false)!=null,"installer button available")
    launcher.queue_free()
    await process_frame
    print("REALM 720 OTA TEST: %d passed, %d failed"%[passes,failures])
    quit(1 if failures else 0)
