extends RefCounted
class_name RAContentCache713
# Exactly one data-only pack in this milestone. Never unpack paths or run code.
const Folder="user://realm_updates713"
const Active="user://realm_updates713/news.json"
const Temp="user://realm_updates713/news.pending"
const Backup="user://realm_updates713/news.previous"

static func _valid_news(content:Variant) -> bool:
    return content is Dictionary and content.get("schema")==1 and content.get("id")=="realm-launcher-news-v1" and content.get("title") is String and content.get("message") is String and content.title.length()>0 and content.title.length()<=80 and content.message.length()>0 and content.message.length()<=400

static func _hash(bytes:PackedByteArray) -> String:
    var ctx=HashingContext.new()
    if ctx.start(HashingContext.HASH_SHA256)!=OK:return ""
    if ctx.update(bytes)!=OK:return ""
    return ctx.finish().hex_encode()

static func valid_bytes(pack:Dictionary,body:PackedByteArray) -> bool:
    if not RAUpdateGate713.valid_pack(pack):return false
    if body.size()!=int(pack.bytes) or _hash(body)!=str(pack.sha256):return false
    return _valid_news(JSON.parse_string(body.get_string_from_utf8()))

static func installed(pack:Dictionary) -> bool:
    if not FileAccess.file_exists(Active):return false
    return valid_bytes(pack,FileAccess.get_file_as_bytes(Active))

static func read(pack:Dictionary) -> Dictionary:
    if not installed(pack):return {}
    var item=JSON.parse_string(FileAccess.get_file_as_string(Active))
    return item if item is Dictionary else {}

static func install(pack:Dictionary,body:PackedByteArray) -> bool:
    if not valid_bytes(pack,body):return false
    var absolute=ProjectSettings.globalize_path(Folder)
    if DirAccess.make_dir_recursive_absolute(absolute)!=OK:return false
    var f=FileAccess.open(Temp,FileAccess.WRITE)
    if f==null:return false
    f.store_buffer(body)
    f.flush()
    f.close()
    if not FileAccess.file_exists(Temp) or not valid_bytes(pack,FileAccess.get_file_as_bytes(Temp)):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(Temp))
        return false
    var backup_path=ProjectSettings.globalize_path(Backup)
    var active_path=ProjectSettings.globalize_path(Active)
    var pending_path=ProjectSettings.globalize_path(Temp)
    if FileAccess.file_exists(Backup):DirAccess.remove_absolute(backup_path)
    var had_previous=FileAccess.file_exists(Active)
    if had_previous and DirAccess.rename_absolute(active_path,backup_path)!=OK:
        DirAccess.remove_absolute(pending_path)
        return false
    if DirAccess.rename_absolute(pending_path,active_path)!=OK:
        if had_previous:DirAccess.rename_absolute(backup_path,active_path)
        DirAccess.remove_absolute(pending_path)
        return false
    return installed(pack)
