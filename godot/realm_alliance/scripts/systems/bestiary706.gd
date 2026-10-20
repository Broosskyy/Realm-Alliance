extends RefCounted
# Additive save domain. Only newly awarded victories count; old totals are not guessed.
const V=preload("res://scripts/systems/domain_validation.gd")
const World=preload("res://scripts/systems/world_progress.gd")
const Events=preload("res://scripts/systems/event69.gd")
const GOALS=[5,15,30]
const GOLD=[20,60,120]
const SHARDS=[1,2,3]
static var _catalog:Dictionary={}
static func catalog() -> Dictionary:
    if _catalog.is_empty():
        for region in World.IDS:
            for i in 5:
                var d=World.encounter(region,i);d.region=region;d.stage=i;d.location=World.NAMES[region]+" · Etappe %d"%(i+1);_catalog[d.id]=d
        for event_id in Events.catalog():
            for entry in Events.catalog()[event_id].encounters:
                var d=entry.duplicate(true);d.region="event";d.stage=0;d.location=Events.catalog()[event_id].name;_catalog[d.id]=d
    return _catalog
static func ensure(p:Dictionary) -> bool:
    if not p.has("bestiary"):p.bestiary={"schema":1,"kills":{},"claimed":{}}
    var d=p.bestiary
    if not V.header(d) or not d.get("kills") is Dictionary or not d.get("claimed") is Dictionary:return false
    for id in d.kills:
        if not catalog().has(id) or not V.integer(d.kills[id],0,2000000000):return false
    for id in d.claimed:
        if not catalog().has(id) or not V.integer(d.claimed[id],1,3):return false
        if int(d.kills.get(id,0))<int(GOALS[int(d.claimed[id])-1]):return false
    return true
static func key(enemy_id:String) -> String:
    return enemy_id.get_slice(":",enemy_id.get_slice_count(":")-1)
static func record(p:Dictionary,enemy_id:String) -> void:
    var id=key(enemy_id)
    if not ensure(p) or not catalog().has(id):return
    p.bestiary.kills[id]=mini(2000000000,int(p.bestiary.kills.get(id,0))+1)
static func count(p:Dictionary,id:String) -> int:
    return int(p.bestiary.kills.get(id,0)) if ensure(p) else 0
static func rank(p:Dictionary,id:String) -> int:
    return int(p.bestiary.claimed.get(id,0)) if ensure(p) else 0
static func can_claim(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not catalog().has(id):return false
    var tier=rank(p,id)
    return tier<3 and count(p,id)>=int(GOALS[tier])
static func claim(p:Dictionary,id:String) -> bool:
    if not can_claim(p,id):return false
    var tier=rank(p,id)
    p.gold=mini(2000000000,int(p.gold)+int(GOLD[tier]));p.shards=mini(2000000000,int(p.shards)+int(SHARDS[tier]))
    p.bestiary.claimed[id]=tier+1
    return true
static func discovered(p:Dictionary) -> int:
    if not ensure(p):return 0
    var result=0
    for kills in p.bestiary.kills.values():
        if int(kills)>0:result+=1
    return result
static func art(id:String) -> String:
    var visual=str(catalog()[id].visual)
    match visual:
        "golem":return "res://assets/work704/golem/idle.png"
        "boar":return "res://assets/enemies/ember_boar/idle.png"
        "slime":return "res://assets/expansion/slime/idle.png"
        "pumpkin","shadow","harvest_boss":return "res://assets/events69/"+visual+"/idle.png"
        _:return "res://assets/expansion702/"+visual+"/idle.png"
