extends RefCounted
class_name RAQuestSystem
const Validate=preload("res://scripts/systems/domain_validation.gd")
# Permanent local objectives. No wall-clock dailies or online authority.
const CATALOG=[
 {"id":"first_five","description":"Besiege 5 Gegner.","name":"Wächterdienst","metric":"kills","goal":5,"gold":40,"shards":2,"achievement":false},
 {"id":"skill_practice","description":"Setze 5 Skills erfolgreich ein.","name":"Magische Disziplin","metric":"skills","goal":5,"gold":30,"shards":2,"achievement":false},
 {"id":"first_upgrade","description":"Werte eine Waffe auf.","name":"Geschärfter Stahl","metric":"upgrades","goal":1,"gold":35,"shards":2,"achievement":false},
 {"id":"boss_hunter","description":"Besiege einen Boss.","name":"Koloss bezwungen","metric":"bosses","goal":1,"gold":75,"shards":3,"achievement":true},
 {"id":"sword_collector","description":"Sammle alle 5 Schwerter.","name":"Fünf Klingen","metric":"weapons","goal":5,"gold":60,"shards":3,"achievement":true},
 {"id":"ten_stages","description":"Schließe 10 Kämpfe ab.","name":"Pfadfinder","metric":"kills","goal":10,"gold":100,"shards":4,"achievement":true}
]
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("quests"):
        var upgrades=0
        for item in profile.inventory.values():upgrades+=maxi(0,int(item.level)-1)
        var bosses=0
        for key in profile.claims:
            if str(key).ends_with(":4"):bosses+=1
        profile.quests={"schema":1,"counters":{"skills":0,"upgrades":upgrades,"bosses":bosses},"claimed":{}}
    var d=profile.quests
    if not Validate.header(d) or not d.get("counters") is Dictionary or not d.get("claimed") is Dictionary:return false
    for value in d.counters.values():
        if not Validate.integer(value,0,2000000000):return false
    for id in d.claimed:
        if definition(id).is_empty() or d.claimed[id]!=true:return false
    return true
static func definition(id: String) -> Dictionary:
    for d in CATALOG:
        if d.id==id:return d
    return {}
static func record(profile: Dictionary,metric: String) -> void:
    if ensure(profile) and metric in ["skills","upgrades","bosses"]:profile.quests.counters[metric]=mini(2000000000,int(profile.quests.counters.get(metric,0))+1)
static func progress(profile: Dictionary,id: String) -> int:
    var d=definition(id)
    if not ensure(profile) or d.is_empty():return 0
    if d.metric=="kills":return int(profile.kills)
    if d.metric=="weapons":return profile.inventory.size()
    return int(profile.quests.counters.get(d.metric,0))
static func claim(profile: Dictionary,id: String) -> bool:
    var d=definition(id)
    if not ensure(profile) or d.is_empty() or profile.quests.claimed.has(id) or progress(profile,id)<int(d.goal):return false
    profile.quests.claimed[id]=true
    profile.gold=mini(2000000000,int(profile.gold)+int(d.gold));profile.shards=mini(2000000000,int(profile.shards)+int(d.shards))
    return true
