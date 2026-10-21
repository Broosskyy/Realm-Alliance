extends SceneTree
const Gate=preload("res://scripts/launcher/update_gate714.gd")
const Cache=preload("res://scripts/launcher/content_cache714.gd")
var checks=0
var failures=0
func verify(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("714 "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var m=JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/updater714_manifest_v1.json"))
    var p1=m.packs[0]
    var p2=p1.duplicate(true)
    p2.revision="graphics-v2"
    p2.bytes=940
    p2.sha256="510ed220494a72a450613d86ea827efd299a78fd29f92f5413a670825d9477b9"
    p2.url=Gate.CONTENT_BASE+"realm-v2.json"
    var d1=FileAccess.get_file_as_bytes("res://tests/fixtures/updater714_v1.json")
    var d2=FileAccess.get_file_as_bytes("res://tests/fixtures/updater714_v2.json")
    verify(Gate.inspect(m,714,"test").status=="content","v1 accepted")
    verify(Gate.inspect(m,713,"test").status=="app_required","old 713 requires app update")
    verify(Gate.inspect(m,714,"stable").status=="invalid","channel isolated")
    verify(Gate.valid_pack(p1) and Gate.valid_pack(p2),"both patch versions valid")
    verify(Cache.valid(p1,d1) and Cache.valid(p2,d2),"SHA, JSON, real SVG decoded")
    verify(Cache.install(p1,d1),"v1 install")
    verify(Cache.installed(p1) and Cache.last().revision=="graphics-v1","v1 persisted")
    var tex=Cache.preview_texture()
    verify(tex!=null and tex.get_size()==Vector2(480,128),"real texture decoded")
    verify(Cache.install(p2,d2),"v2 install same app")
    verify(Cache.installed(p2) and Cache.last().revision=="graphics-v2","v2 now active")
    var altered=d2.duplicate()
    altered[30]=88
    verify(not Cache.valid(p2,altered) and not Cache.install(p2,altered),"tampered patch rejected")
    verify(Cache.last().revision=="graphics-v2","failed update keeps last good")
    var bad=p2.duplicate(true)
    bad.url="https://untrusted.invalid/banner.svg"
    verify(not Gate.valid_pack(bad),"untrusted URL refused")
    bad=p2.duplicate(true)
    bad.sha256="0"
    verify(not Gate.valid_pack(bad),"missing digest refused")
    var instance=preload("res://scenes/launcher713.tscn").instantiate()
    instance.auto_check=false
    root.add_child(instance)
    await process_frame
    var preview=instance.find_child("RemotePatchBanner",true,false)
    var announcement=instance.find_child("PatchAnnouncement",true,false)
    verify(is_instance_valid(preview) and preview.visible and preview.texture!=null,"remote image visible in launcher")
    verify(is_instance_valid(announcement) and announcement.visible and announcement.text.contains("Kristallnacht"),"remote text visible in launcher")
    instance.queue_free()
    await process_frame
    print("REALM 714 patch tests: %d/%d"%[checks-failures,checks])
    quit(1 if failures else 0)
