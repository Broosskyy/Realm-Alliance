extends RefCounted
class_name RARewardSystem
const Equipment = preload("res://scripts/systems/equipment.gd")

static func grant(profile: Dictionary, key: String, enemy: Dictionary, tier: int) -> Dictionary:
    if profile.claims.has(key):
        return {"granted":false}
    profile.claims[key] = true
    var gold = int(enemy.gold) + tier * 3
    if Equipment.definition(profile.equipped).trait == "momentum":
        gold = int(round(gold * 1.2))
    var xp = int(enemy.xp) + tier * 4
    profile.gold = mini(2000000000, int(profile.gold) + gold)
    profile.xp = mini(2000000000, int(profile.xp) + xp)
    profile.kills = int(profile.kills) + 1
    profile.shards = int(profile.shards) + 1
    var drop: String = enemy.drop
    var item: Dictionary = {"uid":key,"kind":"material","id":"sky_shard","name":"Himmelssplitter","rarity":"common","count":1}
    if drop != "" and not profile.inventory.has(drop):
        var d = Equipment.definition(drop)
        profile.inventory[drop] = {"id":drop,"level":1,"rarity":d.rarity}
        item = {"uid":key,"kind":"weapon","id":drop,"name":d.name,"rarity":d.rarity,"count":1}
    elif drop != "":
        profile.shards += 2
        item.count = 3
    profile.loot.push_front(item)
    if profile.loot.size() > 12:
        profile.loot.resize(12)
    return {"granted":true,"gold":gold,"xp":xp,"item":item}
