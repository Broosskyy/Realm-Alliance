extends RefCounted
# Use the same stat functions as the equipped item; mutate a private preview only.
const Equipment=preload("res://scripts/systems/equipment.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
static func weapon(profile:Dictionary,id:String) -> Dictionary:
    if id not in Equipment.IDS or not profile.inventory.has(id):return {}
    var level=int(profile.inventory[id].level)
    var copy=profile.duplicate(true)
    copy.inventory[id].level=mini(20,level+1)
    var cost=Equipment.item_upgrade_cost(profile,id)
    return {"level":level,"maximum":level>=20,"cost":cost,"current":Equipment.item_damage(profile,id),"next":Equipment.item_damage(copy,id),"affordable":level<20 and int(profile.gold)>=int(cost.gold) and int(profile.shards)>=int(cost.shards)}
static func gear(profile:Dictionary,id:String) -> Dictionary:
    if not Gear.CATALOG.has(id):return {}
    var copy=profile.duplicate(true)
    var owned=profile.hero_equipment.owned.has(id)
    var level=int(profile.hero_equipment.owned[id].level) if owned else 1
    copy.hero_equipment.owned[id]={"level":mini(10,level+1)}
    var cost=Gear.upgrade_cost(profile,id) if owned else {}
    return {"level":level,"maximum":level>=10,"cost":cost,"current":Gear.item_stats(profile,id),"next":Gear.item_stats(copy,id),"affordable":owned and level<10 and int(profile.gold)>=int(cost.gold) and int(profile.shards)>=int(cost.shards)}
