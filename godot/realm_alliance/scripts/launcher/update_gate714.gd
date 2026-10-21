extends RefCounted
class_name RAUpdateGate714
# Version 714: nur Daten/Grafiken; niemals nachgeladenen ausführbaren Code ausführen.
const CONTENT_BASE="https://raw.githubusercontent.com/Broosskyy/Realm-Alliance/distribution/realm-714-test/godot/realm_alliance/data/updates714/"
static func valid_pack(p:Variant) -> bool:
    if not p is Dictionary:return false
    if p.get("id")!="realm_announcement" or p.get("kind")!="svg_announcement":return false
    var rev=str(p.get("revision",""))
    var match_rev=RegEx.new()
    match_rev.compile("^graphics-v[1-9][0-9]{0,2}$")
    if match_rev.search(rev)==null:return false
    var value=p.get("bytes")
    if not (value is int or value is float) or not is_finite(float(value)) or float(value)!=float(int(value)) or int(value)<100 or int(value)>16384:return false
    var hash=str(p.get("sha256",""))
    var hash_regex=RegEx.new()
    hash_regex.compile("^[0-9a-f]{64}$")
    if hash_regex.search(hash)==null:return false
    return p.get("url")==CONTENT_BASE+"realm-"+rev.trim_prefix("graphics-")+".json"

static func inspect(raw:Variant,installed:int,channel:String) -> Dictionary:
    if not raw is Dictionary or raw.get("schema")!=2 or raw.get("channel")!=channel:
        return {"status":"invalid","message":"Ungültige Updateantwort oder Kanal."}
    for field in ["min_app_version_code","latest_app_version_code"]:
        var code=raw.get(field)
        if not (code is int or code is float) or not is_finite(float(code)) or float(code)!=float(int(code)) or int(code)<1 or int(code)>1000000:
            return {"status":"invalid","message":"Ungültige Versionsdaten."}
    var minimum=int(raw.min_app_version_code)
    var latest=int(raw.latest_app_version_code)
    if latest<minimum:return {"status":"invalid","message":"Ungültige Mindestversion."}
    var packs=raw.get("packs")
    if not packs is Array or packs.size()!=1 or not valid_pack(packs[0]):
        return {"status":"invalid","message":"Inhaltsliste abgelehnt."}
    if installed<minimum:return {"status":"app_required","message":"Neue App-Version erforderlich. Lokales Spielen bleibt möglich."}
    if installed<latest:return {"status":"app_optional","message":"Eine neue App-Version steht bereit."}
    return {"status":"content","message":"Versioniertes 2D-Inhaltspaket verfügbar."}
