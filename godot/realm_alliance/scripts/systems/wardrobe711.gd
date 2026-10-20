extends RefCounted
class_name RAWardrobe711
# Additive cosmetic domain: no combat bonuses and no replacement of owned heroes.
const Valid=preload("res://scripts/systems/domain_validation.gd")
const IDS=["forest_path","sand_traveler"]
const CATALOG={
    "forest_path":{"name":"Waldpfad","rarity":"rare","kills":25,"wave":1,"requirement":"25 Gegner besiegen","description":"Weiche grüne Stofflagen, Blattspange und ein langer Reisemantel."},
    "sand_traveler":{"name":"Sandwanderer","rarity":"epic","kills":0,"wave":15,"requirement":"Kampfstufe 15 erreichen","description":"Helle Wickelgewänder, bordeauxrote Schärpe und ein wehender Wüstenmantel."}
}
static func ensure(profile:Dictionary) -> bool:
    if not profile.has("wardrobe"):
        profile.wardrobe={"schema":1,"owned":{},"active":""}
    return valid_domain(profile.wardrobe)
static func valid_domain(d) -> bool:
    if not Valid.header(d) or not d.get("owned") is Dictionary or not d.get("active") is String:return false
    for id in d.owned:
        if id not in IDS or not d.owned[id] is Dictionary:return false
    return d.active=="" or (d.active in IDS and d.owned.has(d.active))
static func ready(profile:Dictionary,id:String) -> bool:
    if not ensure(profile) or id not in IDS or profile.wardrobe.owned.has(id):return false
    var d:Dictionary=CATALOG[id]
    return int(profile.get("kills",0))>=int(d.kills) and int(profile.get("best_wave",1))>=int(d.wave)
static func claim(profile:Dictionary,id:String) -> bool:
    if not ready(profile,id):return false
    profile.wardrobe.owned[id]={"source":"milestone711"}
    return true
static func equip(profile:Dictionary,id:String) -> bool:
    if not ensure(profile) or (id!="" and not profile.wardrobe.owned.has(id)):return false
    if profile.wardrobe.active==id:return false
    profile.wardrobe.active=id
    return true
static func active(profile:Dictionary) -> String:
    if not profile.has("wardrobe"):return ""
    return str(profile.wardrobe.active) if valid_domain(profile.wardrobe) else ""
static func icon(id:String) -> String:
    return "res://assets/work711/wardrobe/"+id+"/torso.png" if id in IDS else ""
