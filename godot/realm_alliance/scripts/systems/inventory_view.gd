extends RefCounted
class_name RAInventoryView
const Equipment=preload("res://scripts/systems/equipment.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Chests=preload("res://scripts/systems/chest_rewards.gd")
static func items(profile: Dictionary,filter: String="all",rarity_sort: bool=false) -> Array:
    var result=[]
    if filter in ["all","weapon"]:
        for id in Equipment.IDS:
            if not profile.inventory.has(id):continue
            var d=Equipment.definition(id)
            result.append({"id":id,"kind":"weapon","name":d.name,"rarity":d.rarity,"level":int(profile.inventory[id].level),"active":profile.equipped==id,"icon":"res://assets/production/weapons/"+id+".png"})
    if filter in ["all","gear"] and Gear.ensure(profile):
        for id in Gear.IDS:
            if not profile.hero_equipment.owned.has(id):continue
            var d:Dictionary=Gear.CATALOG[id]
            result.append({"id":id,"kind":"gear","name":d.name,"rarity":d.rarity,"level":int(profile.hero_equipment.owned[id].level),"active":str(profile.hero_equipment.equipped.get(d.slot,""))==id,"icon":"res://assets/equipment/"+id+".png"})
    if filter in ["all","material"]:
        if int(profile.shards)>0:result.append({"id":"sky_shard","kind":"material","name":"Himmelssplitter","rarity":"common","count":int(profile.shards),"icon":"res://assets/ui/work61/shard.svg"})
        if Chests.ensure(profile) and not profile.chests.sealed.is_empty():result.append({"id":"boss_chest","kind":"chest","name":"Wächtertruhe","rarity":"epic","count":profile.chests.sealed.size(),"icon":"res://assets/ui/work61/chest.svg"})
    result.sort_custom(func(a,b):
        if rarity_sort:
            var ranks={"common":0,"rare":1,"epic":2}
            if ranks[a.rarity]!=ranks[b.rarity]:return ranks[a.rarity]>ranks[b.rarity]
        return str(a.name)<str(b.name))
    return result
