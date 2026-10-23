extends SceneTree
const Gate=preload("res://scripts/launcher/app_update717.gd")
var checks=0
var failed=0
func verify(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failed+=1
        push_error("REALM 722: "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
    var launcher=preload("res://scenes/launcher713.tscn").instantiate()
    launcher.auto_check=false
    root.add_child(launcher)
    await process_frame
    verify(launcher.VERSION_CODE==722,"correct app version")
    var download=launcher.find_child("NativeApkDownload",true,false)
    verify(download is HTTPRequest,"separate APK request exists")
    if download is HTTPRequest:
        verify(download.timeout==0.0,"APK has unlimited overall timeout")
        verify(download.use_threads,"threaded APK file stream")
        verify(download.max_redirects>=12,"GitHub redirects supported")
        verify(not download.keep_partial_download,"no corrupt partial APK resume")
    verify(launcher.find_child("LaunchAppUpdate",true,false) is Button,"manual retry button retained")
    var spec={"version_code":723,"package":Gate.PACKAGE,"certificate_sha256":Gate.CERT_SHA256,
        "bytes":131748445,"sha256":"a".repeat(64),
        "url":Gate.RELEASE_ROOT+"realm-723-android/REALM_ALLIANCE_723.apk"}
    verify(Gate.check(JSON.parse_string(JSON.stringify(spec)),722,723),"JSON numeric types")
    verify(Gate.download_timeout(131748445)==0.0,"large file timeout rule")
    verify(Gate.error_text(HTTPRequest.RESULT_TIMEOUT,0).length()>4,"error is readable")
    launcher.queue_free()
    await process_frame
    print("REALM 722 AUTOLOADER %d/%d" % [checks-failed,checks])
    quit(1 if failed else 0)
