extends RefCounted
class_name RAHeroEquipment
# Additive, versioned profile domain. V1/V2 envelopes and unknown profile data survive.
const Progress=preload("res://scripts/systems/player_progress.gd")
const IDS=["astral_plate","eclipse_plate"]
const SLOTS=["chest","head","back"]
const CATALOG={
    "astral_plate":{"name":"Sternenpanzer","slot":"chest","rarity":"rare","unlock":1,"gold":35,"shards":2,"hp":20,"defense":2},
    "eclipse_plate":{"name":"Eklipsenpanzer","slot":"chest","rarity":"epic","unlock":4,"gold":140,"shards":6,"hp":35,"defense":4}
}
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("hero_equipment"):
        profile.hero_equipment={"schema":1,"owned":{},"equipped":{"chest":"","head":"","back":""},"cosmetics":{}}
    var d=profile.hero_equipment
    if not d is Dictionary or int(d.get("schema",0))!=1:return false
    if not d.get("owned") is Dictionary or not d.get("equipped") is Dictionary or not d.get("cosmetics") is Dictionary:return false
    for id in d.owned:
        if not CATALOG.has(id) or not d.owned[id] is Dictionary:return false
        if int(d.owned[id].get("level",0)) not in range(1,11):return false
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
        var level=int(profile.hero_equipment.owned[id].level)
        result.hp+=int(CATALOG[id].hp)+(level-1)*3
        result.defense+=int(CATALOG[id].defense)+(level-1)
    return result
static func can_acquire(profile: Dictionary,id: String) -> bool:
    if not ensure(profile) or not CATALOG.has(id) or profile.hero_equipment.owned.has(id):return false
    var d:Dictionary=CATALOG[id]
    return Progress.level(int(profile.xp))>=int(d.unlock) and int(profile.gold)>=int(d.gold) and int(profile.shards)>=int(d.shards)
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
    return {"gold":25*int(profile.hero_equipment.owned[id].level),"shards":1}
static func upgrade(profile: Dictionary,id: String) -> bool:
    var cost=upgrade_cost(profile,id)
    if cost.is_empty() or int(profile.hero_equipment.owned[id].level)>=10 or int(profile.gold)<int(cost.gold) or int(profile.shards)<int(cost.shards):return false
    profile.gold-=int(cost.gold);profile.shards-=int(cost.shards);profile.hero_equipment.owned[id].level+=1
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
