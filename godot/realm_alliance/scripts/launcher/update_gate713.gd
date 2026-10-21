extends RefCounted
class_name RAUpdateGate713
# Strictly metadata/data only. Remote GDScript or other executable code is not supported.
const CONTENT_BASE="https://raw.githubusercontent.com/Broosskyy/Realm-Alliance/feature/work-713-1b-content/godot/realm_alliance/data/updates713/"
static func inspect(data:Variant,installed:int,channel:String) -> Dictionary:
    if not data is Dictionary:
        return {"status":"invalid","message":"Ungültige Updateantwort."}
    if data.get("schema")!=1 or data.get("channel")!=channel:
        return {"status":"invalid","message":"Unbekannter Kanal oder Manifestformat."}
    for key in ["min_app_version_code","latest_app_version_code"]:
        var v=data.get(key)
        if not (v is int or v is float) or not is_finite(float(v)) or float(v)!=float(int(v)) or int(v)<1 or int(v)>1000000:
            return {"status":"invalid","message":"Ungültige Versionsnummer."}
    var minimum=int(data.min_app_version_code)
    var latest=int(data.latest_app_version_code)
    var packs=data.get("packs",[])
    if latest<minimum or not packs is Array or packs.size()>1:
        return {"status":"invalid","message":"Ungültige Updateinformationen."}
    for pack in packs:
        if not valid_pack(pack):
            return {"status":"invalid","message":"Ungültiges oder unsicheres Inhaltspaket."}
    if installed<minimum:
        return {"status":"app_required","message":"Ein App-Update ist nötig. Offline spielen bleibt möglich."}
    if installed<latest:
        return {"status":"app_optional","message":"Neue App-Version verfügbar; Installation erfolgt über Android bzw. den Store."}
    if not packs.is_empty():
        return {"status":"content_pending","message":"Ein neues, verifiziertes Inhaltspaket wird geprüft."}
    return {"status":"current","message":"Deine Spielversion ist aktuell."}

static func valid_pack(p:Variant) -> bool:
    if not p is Dictionary:return false
    if p.get("id")!="launcher_news" or p.get("kind")!="json_news":return false
    var count=p.get("bytes")
    if not (count is int or count is float) or not is_finite(float(count)) or float(count)!=float(int(count)):
        return false
    if int(count)<1 or int(count)>1048576:return false
    var sha=p.get("sha256")
    if not sha is String or sha.length()!=64:return false
    var pattern=RegEx.new()
    pattern.compile("^[0-9a-f]{64}$")
    if pattern.search(sha)==null:return false
    var url=p.get("url")
    return url is String and url.begins_with(CONTENT_BASE) and url==CONTENT_BASE+"news-v1.json"
