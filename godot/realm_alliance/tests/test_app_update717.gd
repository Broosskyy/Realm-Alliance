extends SceneTree
const App=preload("res://scripts/launcher/app_update717.gd")
var checks=0
var failures=0
func verify(pass:bool,name:String) -> void:
    checks+=1
    if not pass:failures+=1;push_error("AppUpdater717: "+name)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var spec={
        "version_code":718,
        "package":App.PACKAGE,
        "certificate_sha256":App.CERT_SHA256,
        "bytes":79500000,
        "sha256":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "url":App.RELEASE_ROOT+"realm-718-android/REALM_ALLIANCE_718.apk"
    }
    verify(App.check(spec,717,718),"valid future signed release metadata accepted")
    verify(not App.check(spec,718,718),"no same-version install")
    verify(not App.check(spec,717,719),"no mismatched advertised version")
    var bad=spec.duplicate(true)
    bad.url="https://evil.example/REALM_ALLIANCE_718.apk"
    verify(not App.check(bad,717,718),"malicious download host rejected")
    bad=spec.duplicate(true)
    bad.certificate_sha256="0".repeat(64)
    verify(not App.check(bad,717,718),"incorrect signing identity rejected")
    bad=spec.duplicate(true)
    bad.package="com.evil.fake"
    verify(not App.check(bad,717,718),"different app ID rejected")
    bad=spec.duplicate(true)
    bad.bytes=App.MAX_BYTES+1
    verify(not App.check(bad,717,718),"oversize APK rejected")
    bad=spec.duplicate(true)
    bad.sha256="BAD"
    verify(not App.check(bad,717,718),"invalid SHA256 rejected")
    bad=spec.duplicate(true)
    bad.url=App.RELEASE_ROOT+"realm-717-android/REALM_ALLIANCE_717.apk"
    verify(not App.check(bad,717,718),"version-tag mismatch rejected")
    verify(App.sha256_file("user://missing717.apk")=="","missing binary safely rejected")
    verify(not App.ready(spec,"user://missing717.apk"),"cannot open installer for absent file")
    print("REALM 717 app update: %d/%d"%[checks-failures,checks])
    quit(1 if failures else 0)
