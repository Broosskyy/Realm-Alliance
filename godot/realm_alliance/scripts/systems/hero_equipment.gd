extends RefCounted
class_name RAHeroEquipment
# Additive, versioned profile domain. V1/V2 envelopes and unknown profile data survive.
const Progress=preload("res://scripts/systems/player_progress.gd")
const WingProgress=preload("res://scripts/systems/wing_progression710.gd")
const IDS=["astral_plate","eclipse_plate","sentinel_circlet","sky_wings","harvest_wings"]
const SLOTS=["chest","head","shoulder","back","wings","accessory"]
const CATALOG={
    "harvest_wings":{"name":"Ernteschwingen","slot":"wings","rarity":"epic","unlock":4,"gold":0,"shards":0,"hp":20,"defense":2,"event":true},
    "astral_plate":{"name":"Sternenpanzer","slot":"chest","rarity":"rare","unlock":1,"gold":35,"shards":2,"hp":20,"defense":2},
    "eclipse_plate":{"name":"Eklipsenpanzer","slot":"chest","rarity":"epic","unlock":4,"gold":140,"shards":6,"hp":35,"defense":4},
    "sentinel_circlet":{"name":"Wächterdiadem","slot":"head","rarity":"rare","unlock":2,"gold":30,"shards":2,"hp":5,"defense":1},
    "sky_wings":{"name":"Himmelsflügel","slot":"wings","rarity":"epic","unlock":3,"gold":60,"shards":4,"hp":15,"defense":1}
}
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("hero_equipment"):
        profile.hero_equipment={"schema":1,"owned":{},"equipped":{"chest":"","head":"","shoulder":"","back":"","wings":"","accessory":""},"cosmetics":{}}
    var d=profile.hero_equipment
    if not d is Dictionary or int(d.get("schema",0))!=1:return false
    if d.has("wing_revision") and not WingProgress.valid_level(d.wing_revision,1):return false
    if not d.get("owned") is Dictionary or not d.get("equipped") is Dictionary or not d.get("cosmetics") is Dictionary:return false
    for id in d.owned:
        if not CATALOG.has(id) or not d.owned[id] is Dictionary:return false
        if not WingProgress.valid_level(d.owned[id].get("level",0),max_level(id)):return false
    for slot in SLOTS:
        var id=str(d.equipped.get(slot,""))
        if id!="" and (not d.owned.has(id) or str(CATALOG[id].slot)!=slot):return false
    for slot in d.cosmetics:
        var id=str(d.cosmetics[slot])
        if slot not in SLOTS or (id!="" and (not d.owned.has(id) or str(CATALOG[id].slot)!=slot)):return false
    return true
static func stats(profile: Dictionary) -> Dictionary:
    var result={"hp":0,"defense":0}
    if not ensure(profile):return result
    for slot in SLOTS:
        var id=str(profile.hero_equipment.equipped.get(slot,""))
        if id=="":continue
        var values=item_stats(profile,id)
        result.hp+=values.hp;result.defense+=values.defense
    return result
static func item_stats(profile: Dictionary,id: String) -> Dictionary:
    if not CATALOG.has(id):return {"hp":0,"defense":0}
    var level=1
    if ensure(profile) and profile.hero_equipment.owned.has(id):level=int(profile.hero_equipment.owned[id].level)
    return {"hp":int(CATALOG[id].hp)+(level-1)*3,"defense":int(CATALOG[id].defense)+level-1}
static func can_acquire(profile: Dictionary,id: String) -> bool:
    if not ensure(profile) or not CATALOG.has(id) or profile.hero_equipment.owned.has(id):return false
    var d:Dictionary=CATALOG[id]
    return not bool(d.get("event",false)) and Progress.level(int(profile.xp))>=int(d.unlock) and int(profile.gold)>=int(d.gold) and int(profile.shards)>=int(d.shards)
static func acquire(profile: Dictionary,id: String) -> bool:
    if not can_acquire(profile,id):return false
    var d:Dictionary=CATALOG[id]
    profile.gold-=int(d.gold);profile.shards-=int(d.shards)
    profile.hero_equipment.owned[id]={"id":id,"level":1,"source":"local_forge_v1"}
    return true
static func equip(profile: Dictionary,id: String) -> bool:
    if not ensure(profile) or not profile.hero_equipment.owned.has(id):return false
    profile.hero_equipment.equipped[CATALOG[id].slot]=id
    return true
static func unequip(profile: Dictionary,slot: String) -> bool:
    if not ensure(profile) or slot not in SLOTS:return false
    profile.hero_equipment.equipped[slot]=""
    return true
static func upgrade_cost(profile: Dictionary,id: String) -> Dictionary:
    if not ensure(profile) or not profile.hero_equipment.owned.has(id):return {}
    return WingProgress.cost(int(profile.hero_equipment.owned[id].level)) if is_wings(id) else {"gold":25*int(profile.hero_equipment.owned[id].level),"shards":1}
static func upgrade(profile: Dictionary,id: String) -> bool:
    var cost=upgrade_cost(profile,id)
    if cost.is_empty() or int(profile.hero_equipment.owned[id].level)>=max_level(id) or int(profile.gold)<int(cost.gold) or int(profile.shards)<int(cost.shards):return false
    profile.gold-=int(cost.gold);profile.shards-=int(cost.shards);profile.hero_equipment.owned[id].level+=1
    if is_wings(id):profile.hero_equipment.wing_revision=1
    return true
static func set_cosmetic(profile: Dictionary,slot: String,id: String) -> bool:
    if not ensure(profile) or slot not in SLOTS:return false
    if id!="" and (not profile.hero_equipment.owned.has(id) or str(CATALOG[id].slot)!=slot):return false
    # Empty override deliberately hides that layer; removing override restores equipped art.
    profile.hero_equipment.cosmetics[slot]=id
    return true
static func visible_id(profile: Dictionary,slot: String) -> String:
    if not ensure(profile):return ""
    return str(profile.hero_equipment.cosmetics.get(slot,profile.hero_equipment.equipped.get(slot,"")))

# Legacy level 1 means +0; no paid upgrade or stat is discarded.
static func is_wings(id:String) -> bool:
    return CATALOG.has(id) and CATALOG[id].slot=="wings"
static func max_level(id:String) -> int:
    return WingProgress.MAX_PLUS+1 if is_wings(id) else 10
static func plus(profile:Dictionary,id:String) -> int:
    if not is_wings(id):return 0
    return clampi(item_level(profile,id)-1,0,WingProgress.MAX_PLUS)
static func display_level(profile:Dictionary,id:String) -> String:
    return "+%d"%plus(profile,id) if is_wings(id) else "Lv. %d"%item_level(profile,id)
static func item_level(profile:Dictionary,id:String) -> int:
    var domain=profile.get("hero_equipment",{})
    if not domain is Dictionary:return 1
    var owned=domain.get("owned",{})
    if not owned is Dictionary:return 1
    var item=owned.get(id,{})
    if not item is Dictionary:return 1
    var value=item.get("level",1)
    return int(value) if WingProgress.valid_level(value,max_level(id)) else 1
