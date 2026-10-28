extends SceneTree
const Gate=preload("res://scripts/launcher/update_gate730.gd")
const Cache=preload("res://scripts/launcher/content_cache730.gd")
var checks=0
var failed=0
func verify(value:bool,message:String) -> void:
    checks+=1
    if not value:
        failed+=1
        push_error("730: "+message)
func _initialize() -> void:call_deferred("run")
func spec(id:String,kind:String,revision:int,body:PackedByteArray) -> Dictionary:
    var ext=".png" if kind=="png_texture" else ".json"
    return {"id":id,"kind":kind,"revision":revision,"bytes":body.size(),"sha256":Cache._digest(body),"url":Gate.BASE+id+"-v"+str(revision)+ext}
func run() -> void:
    var png=FileAccess.get_file_as_bytes("res://assets/equipment/astral_plate.png")
    var artwork=spec("realm_armor_art","png_texture",1,png)
    var obj={"schema":1,"id":"realm_armor_catalog","revision":1,"items":[{"id":"astral_plate_preview","name":"Astrale Plattenrüstung","slot":"chest","art":"realm_armor_art","rarity":"epic","description":"Live geladenes Rüstungsbild."}]}
    var bytes=JSON.stringify(obj).to_utf8_buffer()
    var catalog=spec("realm_armor_catalog","json_armor",1,bytes)
    verify(Gate.valid_pack(artwork) and Gate.valid_pack(catalog),"only approved URLs")
    verify(Cache.valid(artwork,png) and Cache.valid(catalog,bytes),"signed length and SHA, typed schema")
    verify(Cache.install(artwork,png) and Cache.install(catalog,bytes),"install both packs")
    verify(Cache.installed(artwork) and Cache.installed(catalog),"verify cached packs")
    var texture=Cache.texture("realm_armor_art")
    verify(texture!=null and texture.get_width()>=32,"real PNG decodes")
    verify(Cache.armor_catalog().items[0].id=="astral_plate_preview","catalog can be loaded")
    var altered=png.duplicate()
    altered[20]=altered[20]^1
    verify(not Cache.valid(artwork,altered) and not Cache.install(artwork,altered),"damaged graphic rejected")
    verify(Cache.installed(artwork),"old graphic preserved")
    var evil=artwork.duplicate(true)
    evil.url="https://evil.invalid/x.png"
    verify(not Gate.valid_pack(evil),"untrusted URL rejected")
    var duplicate={"schema":3,"channel":"test","min_app_version_code":730,"latest_app_version_code":730,"packs":[artwork,artwork]}
    verify(Gate.inspect(duplicate,730,"test").status=="invalid","duplicate rejected")
    obj.revision=2
    obj.items[0].name="Astrale Plattenrüstung II"
    var b2=JSON.stringify(obj).to_utf8_buffer()
    var second=spec("realm_armor_catalog","json_armor",2,b2)
    verify(Cache.install(second,b2),"content revision 2 without new APK")
    verify(Cache.armor_catalog().items[0].name=="Astrale Plattenrüstung II","new revision read")
    var src=FileAccess.get_file_as_string("res://scripts/main.gd")
    verify(src.contains("VerifiedRemoteWorldProp730"),"in-game loader is wired")
    print("REALM 730 CONTENT %d/%d"%[checks-failed,checks])
    quit(1 if failed else 0)
