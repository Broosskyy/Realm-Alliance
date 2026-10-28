extends RefCounted
class_name RAContentCache715
const Gate=preload("res://scripts/launcher/update_gate730.gd")
const DIR="user://realm_content730"
static func _digest(body:PackedByteArray) -> String:
    var ctx=HashingContext.new()
    if ctx.start(HashingContext.HASH_SHA256)!=OK:return ""
    if ctx.update(body)!=OK:return ""
    return ctx.finish().hex_encode()
static func _base(id:String) -> String:return DIR+"/"+id
static func _typed(pack:Dictionary,body:PackedByteArray) -> bool:
    if pack.kind=="png_texture":
        if body.size()<24 or body.slice(0,8)!=PackedByteArray([137,80,78,71,13,10,26,10]):return false
        var image=Image.new()
        if image.load_png_from_buffer(body)!=OK:return false
        return image.get_width()>=32 and image.get_height()>=32 and image.get_width()<=2048 and image.get_height()<=2048
    if pack.kind=="json_catalog":
        var data=JSON.parse_string(body.get_string_from_utf8())
        if not data is Dictionary or data.get("schema")!=1 or data.get("id")!="realm_content_catalog" or data.get("revision")!=pack.revision:return false
        var entries=data.get("items")
        if not entries is Array or entries.size()>20:return false
        for entry in entries:
            if not entry is Dictionary or entry.get("id")!="crystal_outpost" or entry.get("art")!="realm_stage_ornament":return false
            if not entry.get("name") is String or not entry.get("description") is String:return false
            if entry.name.length()<2 or entry.name.length()>80 or entry.description.length()<4 or entry.description.length()>350:return false
        return true
    if pack.kind=="json_armor":
        var value=JSON.parse_string(body.get_string_from_utf8())
        if not value is Dictionary or value.get("schema")!=1 or value.get("id")!="realm_armor_catalog" or value.get("revision")!=pack.revision:return false
        var items=value.get("items")
        if not items is Array or items.is_empty() or items.size()>16:return false
        var ids={}
        var pattern=RegEx.new()
        pattern.compile("^[a-z][a-z0-9_]{2,47}$")
        for item in items:
            if not item is Dictionary:return false
            var item_id=str(item.get("id",""))
            if pattern.search(item_id)==null or ids.has(item_id):return false
            ids[item_id]=true
            if item.get("slot")!="chest" or item.get("art")!="realm_armor_art":return false
            if item.get("rarity") not in ["common","rare","epic","legendary"]:return false
            if not item.get("name") is String or not item.get("description") is String:return false
            if item.name.length()<3 or item.name.length()>80 or item.description.length()<4 or item.description.length()>240:return false
        return true
    return false
static func valid(pack:Dictionary,body:PackedByteArray) -> bool:
    return Gate.valid_pack(pack) and body.size()==int(pack.bytes) and _digest(body)==str(pack.sha256) and _typed(pack,body)
static func _read(id:String,suffix:String="") -> Dictionary:
    if not Gate.IDS.has(id):return {}
    var p=_base(id)+suffix
    if not FileAccess.file_exists(p+".data") or not FileAccess.file_exists(p+".meta"):return {}
    var info=JSON.parse_string(FileAccess.get_file_as_string(p+".meta"))
    if not info is Dictionary or not valid(info,FileAccess.get_file_as_bytes(p+".data")):return {}
    return {"pack":info,"body":FileAccess.get_file_as_bytes(p+".data")}
static func latest(id:String) -> Dictionary:
    var live=_read(id)
    return live if not live.is_empty() else _read(id,".bak")
static func installed(pack:Dictionary) -> bool:
    var found=latest(str(pack.get("id","")))
    return not found.is_empty() and found.pack.sha256==pack.get("sha256")
static func install(pack:Dictionary,body:PackedByteArray) -> bool:
    if not valid(pack,body) or DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))!=OK:return false
    var name=_base(str(pack.id))
    var f=FileAccess.open(name+".next.data",FileAccess.WRITE)
    if f==null:return false
    f.store_buffer(body);f.flush()
    var success=f.get_error()==OK
    f.close()
    if not success:return false
    var m=FileAccess.open(name+".next.meta",FileAccess.WRITE)
    if m==null:return false
    m.store_string(JSON.stringify(pack));m.flush()
    success=m.get_error()==OK
    m.close()
    if not success or _read(str(pack.id),".next").is_empty():return false
    # Keep independently valid backup: interrupted writes cannot replace known-good pack.
    var old=_read(str(pack.id))
    if not old.is_empty():
        for ext in [".data",".meta"]:
            if DirAccess.copy_absolute(ProjectSettings.globalize_path(name+ext),ProjectSettings.globalize_path(name+".bak"+ext))!=OK:return false
    for ext in [".data",".meta"]:
        if FileAccess.file_exists(name+ext):
            if DirAccess.remove_absolute(ProjectSettings.globalize_path(name+ext))!=OK:return false
        if DirAccess.rename_absolute(ProjectSettings.globalize_path(name+".next"+ext),ProjectSettings.globalize_path(name+ext))!=OK:return false
    return installed(pack)
static func texture(id:String) -> Texture2D:
    var item=latest(id)
    if item.is_empty() or item.pack.kind!="png_texture":return null
    var image=Image.new()
    if image.load_png_from_buffer(item.body)!=OK:return null
    return ImageTexture.create_from_image(image)
static func catalog() -> Dictionary:
    var item=latest("realm_content_catalog")
    if item.is_empty():return {}
    var value=JSON.parse_string(item.body.get_string_from_utf8())
    return value if value is Dictionary else {}

static func armor_catalog() -> Dictionary:
    var record=latest("realm_armor_catalog")
    if record.is_empty():return {}
    var data=JSON.parse_string(record.body.get_string_from_utf8())
    return data if data is Dictionary else {}
