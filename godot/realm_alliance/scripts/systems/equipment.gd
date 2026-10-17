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
    var item: Dictionary = profile.inventory[id]
    return int(definition(id).base_damage) + 6 * (int(item.level) - 1)

static func upgrade_cost(profile: Dictionary) -> int:
    return 20 + (int(profile.inventory[profile.equipped].level) - 1) * 17

static func upgrade(profile: Dictionary) -> bool:
    var item: Dictionary = profile.inventory[profile.equipped]
    var cost = upgrade_cost(profile)
    var shard_cost = 1 if int(item.level) >= 3 else 0
    if int(item.level) >= 20 or profile.gold < cost or profile.shards < shard_cost:
        return false
    profile.gold -= cost
    profile.shards -= shard_cost
    item.level = int(item.level) + 1
    return true
