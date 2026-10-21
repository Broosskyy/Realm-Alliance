extends RefCounted
class_name RAUpdateGate713
# Versionsprüfung, kein Ausführen von heruntergeladenem Programmcode.
static func inspect(data:Variant, installed:int, channel:String) -> Dictionary:
    if not data is Dictionary:
        return {"status":"invalid","message":"Ungültige Updateantwort."}
    if data.get("schema") != 1 or data.get("channel") != channel:
        return {"status":"invalid","message":"Unbekannter Updatekanal oder Manifestformat."}
    for name in ["min_app_version_code","latest_app_version_code"]:
        var v=data.get(name)
        if not (v is int or v is float) or not is_finite(float(v)) or float(v)!=float(int(v)) or int(v)<1 or int(v)>1000000:
            return {"status":"invalid","message":"Ungültige Versionsnummer."}
    var minimum=int(data.min_app_version_code)
    var latest=int(data.latest_app_version_code)
    var packs=data.get("packs",[])
    if latest<minimum or not packs is Array or packs.size()>64:
        return {"status":"invalid","message":"Ungültige Updateinformationen."}
    for pack in packs:
        if not pack is Dictionary or not pack.get("id") is String:
            return {"status":"invalid","message":"Ungültige Paketliste."}
    if installed<minimum:
        return {"status":"app_required","message":"Deine App benötigt ein reguläres Update. Offline spielen bleibt möglich."}
    if installed<latest:
        return {"status":"app_optional","message":"Eine neue App-Version ist verfügbar. Installation über Android bzw. den Store."}
    if not packs.is_empty():
        return {"status":"content_pending","message":"Neue Inhalte angekündigt. Der erste Launcher lädt noch keine Datenpakete."}
    return {"status":"current","message":"Du verwendest die aktuelle Spielversion."}
