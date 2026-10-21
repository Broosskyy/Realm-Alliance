extends RefCounted
class_name RAContentCache714
const Gate=preload("res://scripts/launcher/update_gate714.gd")
const DIRECTORY="user://realm_content714"
const LIVE="user://realm_content714/active.json"
const STAGING="user://realm_content714/pending.json"
const BACKUP="user://realm_content714/backup.json"
static func _digest(bytes:PackedByteArray) -> String:
    var c=HashingContext.new()
    if c.start(HashingContext.HASH_SHA256)!=OK:return ""
    if c.update(bytes)!=OK:return ""
    return c.finish().hex_encode()

static func _image(svg:String) -> Image:
    if not svg.begins_with('<svg xmlns="http://www.w3.org/2000/svg" width="480" height="128" viewBox="0 0 480 128">'):return null
    if svg.length()>12000:return null
    var lowered=svg.to_lower()
    for forbidden in ["<script","<style","<image","<foreignobject","<iframe","<!","href=","onload=","url(","data:","file:"]:
        if lowered.contains(forbidden):return null
    var img=Image.new()
    if img.load_svg_from_buffer(svg.to_utf8_buffer())!=OK:return null
    if img.get_width()!=480 or img.get_height()!=128:return null
    return img

static func valid(pack:Dictionary,raw:PackedByteArray) -> bool:
    if not Gate.valid_pack(pack) or raw.size()!=int(pack.bytes) or _digest(raw)!=str(pack.sha256):return false
    var data=JSON.parse_string(raw.get_string_from_utf8())
    if not data is Dictionary or data.get("schema")!=1 or data.get("id")!="realm_announcement" or data.get("revision")!=pack.revision:return false
    for key in ["title","message","banner_svg"]:
        if not data.get(key) is String:return false
    if str(data.title).length()<1 or str(data.title).length()>75 or str(data.message).length()<1 or str(data.message).length()>300:return false
    return _image(data.banner_svg)!=null

static func _read_file(path:String) -> Dictionary:
    if not FileAccess.file_exists(path):return {}
    var envelope=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not envelope is Dictionary or not envelope.get("pack") is Dictionary or not envelope.get("data_b64") is String:return {}
    var data=Marshalls.base64_to_raw(envelope.data_b64)
    if not valid(envelope.pack,data):return {}
    var body=JSON.parse_string(data.get_string_from_utf8())
    return body if body is Dictionary else {}

static func last() -> Dictionary:
    var current=_read_file(LIVE)
    if not current.is_empty():return current
    return _read_file(BACKUP)

static func installed(pack:Dictionary) -> bool:
    var current=last()
    return not current.is_empty() and current.get("revision")==pack.get("revision")

static func preview_texture() -> Texture2D:
    var data=last()
    if data.is_empty():return null
    var img=_image(str(data.banner_svg))
    return ImageTexture.create_from_image(img) if img!=null else null

static func install(pack:Dictionary,raw:PackedByteArray) -> bool:
    if not valid(pack,raw):return false
    var parent=ProjectSettings.globalize_path(DIRECTORY)
    if DirAccess.make_dir_recursive_absolute(parent)!=OK:return false
    var pending=FileAccess.open(STAGING,FileAccess.WRITE)
    if pending==null:return false
    pending.store_string(JSON.stringify({"pack":pack,"data_b64":Marshalls.raw_to_base64(raw)}))
    pending.flush()
    pending.close()
    if _read_file(STAGING).is_empty():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(STAGING))
        return false
    var live=ProjectSettings.globalize_path(LIVE)
    var back=ProjectSettings.globalize_path(BACKUP)
    var temp=ProjectSettings.globalize_path(STAGING)
    if FileAccess.file_exists(BACKUP):DirAccess.remove_absolute(back)
    var old_exists=FileAccess.file_exists(LIVE)
    if old_exists and DirAccess.rename_absolute(live,back)!=OK:
        DirAccess.remove_absolute(temp)
        return false
    if DirAccess.rename_absolute(temp,live)!=OK:
        if old_exists:DirAccess.rename_absolute(back,live)
        DirAccess.remove_absolute(temp)
        return false
    return installed(pack)
