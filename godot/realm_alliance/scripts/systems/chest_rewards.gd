extends RefCounted
class_name RAChestRewards
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("chests"):profile.chests={"schema":1,"sealed":[],"opened":{}}
    var d=profile.chests
    if not Validate.header(d) or not d.get("sealed") is Array or not d.get("opened") is Dictionary:return false
    var seen={}
    for uid in d.sealed:
        if not uid is String or uid=="" or seen.has(uid) or d.opened.has(uid):return false
        seen[uid]=true
    for uid in d.opened:
        if not uid is String or d.opened[uid]!=true:return false
    return true
static func grant(profile: Dictionary,uid: String) -> bool:
    if not ensure(profile) or uid=="" or profile.chests.opened.has(uid) or uid in profile.chests.sealed:return false
    profile.chests.sealed.append(uid);return true
static func open(profile: Dictionary) -> Dictionary:
    if not ensure(profile) or not Gear.ensure(profile) or profile.chests.sealed.is_empty():return {}
    var uid:String=profile.chests.sealed[0]
    var seed_value=uid.sha256_text().substr(0,8).hex_to_int()
    var seasonal=uid.begins_with("event:harvest_2026:")
    var pool=Gear.IDS.filter(func(value):return value!="harvest_wings")
    var id:String="harvest_wings" if seasonal else pool[seed_value%pool.size()]
    var gold=35+seed_value%21
    var shards=2
    var item={"uid":uid,"id":id,"kind":"gear","name":Gear.CATALOG[id].name,"rarity":Gear.CATALOG[id].rarity,"count":1}
    if profile.hero_equipment.owned.has(id):
        shards+=3;item={"uid":uid,"id":"sky_shard","kind":"material","name":"Himmelssplitter","rarity":"common","count":shards}
    else:profile.hero_equipment.owned[id]={"id":id,"level":1,"source":uid}
    profile.chests.sealed.pop_front();profile.chests.opened[uid]=true
    profile.gold=mini(2000000000,int(profile.gold)+gold);profile.shards=mini(2000000000,int(profile.shards)+shards)
    profile.loot.push_front(item)
    if profile.loot.size()>12:profile.loot.resize(12)
    return {"granted":true,"gold":gold,"xp":0,"shards":shards,"item":item}
