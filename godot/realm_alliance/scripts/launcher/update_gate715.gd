extends RefCounted
class_name RAUpdateGate715
# Test channel: app code never executes network content.
const BASE="https://raw.githubusercontent.com/Broosskyy/Realm-Alliance/distribution/realm-715-test/godot/realm_alliance/data/updates715/"
const IDS={"realm_stage_ornament":"png_texture","realm_content_catalog":"json_catalog"}
static func _whole(value:Variant) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and float(value)==float(int(value))
static func valid_pack(v:Variant) -> bool:
    if not v is Dictionary:return false
    var id=str(v.get("id",""))
    if not IDS.has(id) or str(v.get("kind",""))!=str(IDS[id]):return false
    var rev=v.get("revision")
    if not _whole(rev) or int(rev)<1 or int(rev)>999:return false
    var length=v.get("bytes")
    if not _whole(length) or int(length)<48 or int(length)>(8388608 if id=="realm_stage_ornament" else 131072):return false
    var digest=v.get("sha256")
    if not digest is String or digest.length()!=64:return false
    var pattern=RegEx.new()
    pattern.compile("^[0-9a-f]{64}$")
    if pattern.search(digest)==null:return false
    var suffix=".png" if id=="realm_stage_ornament" else ".json"
    return v.get("url")==BASE+id+"-v"+str(int(rev))+suffix
static func inspect(v:Variant,app:int,channel:String) -> Dictionary:
    if not v is Dictionary or v.get("schema")!=3 or v.get("channel")!=channel:return {"status":"invalid"}
    var minimum=v.get("min_app_version_code")
    var latest=v.get("latest_app_version_code")
    if not _whole(minimum) or not _whole(latest) or int(minimum)<1 or int(latest)<int(minimum) or int(latest)>1000000:return {"status":"invalid"}
    var packs=v.get("packs")
    if not packs is Array or packs.is_empty() or packs.size()>10:return {"status":"invalid"}
    var seen={}
    for pack in packs:
        if not valid_pack(pack) or seen.has(pack.id):return {"status":"invalid"}
        seen[pack.id]=true
    if app<minimum:return {"status":"app_required"}
    if app<latest:return {"status":"app_optional"}
    return {"status":"content"}
