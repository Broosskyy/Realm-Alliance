extends RefCounted
class_name RAEquipment
const Definition = preload("res://scripts/systems/skill_definition.gd")
const IDS = ["steel", "crystal", "ember", "rune_gold", "shadow_violet"]
# Contract for future authored attachments; only existing compatible looks are selectable.
const SLOTS = ["weapon", "chest", "shoulder", "head", "back", "wings", "skin", "aura"]

static func definition(id: String) -> Dictionary:
    for d in Definition.catalog().weapons:
        if d.id == id:
            return d
    return Definition.catalog().weapons[0]

static func damage(profile: Dictionary) -> int:
    var id: String = profile.equipped
    return item_damage(profile,id)

static func item_damage(profile: Dictionary,id: String) -> int:
    var item: Dictionary = profile.inventory.get(id,{"level":1})
    return int(definition(id).base_damage) + 6 * (int(item.level) - 1)

static func upgrade_cost(profile: Dictionary) -> int:
    return 20 + (int(profile.inventory[profile.equipped].level) - 1) * 17

static func upgrade(profile: Dictionary) -> bool:
    return upgrade_item(profile,str(profile.equipped))

static func upgrade_item(profile: Dictionary,id: String) -> bool:
    if id not in IDS or not profile.inventory.has(id):return false
    var item: Dictionary = profile.inventory[id]
    var cost = 20 + (int(item.level)-1)*17
    var shard_cost = 1 if int(item.level) >= 3 else 0
    if int(item.level) >= 20 or profile.gold < cost or profile.shards < shard_cost:
        return false
    profile.gold -= cost
    profile.shards -= shard_cost
    item.level = int(item.level) + 1
    return true
