extends RefCounted
class_name RASaveMigration
const Equipment = preload("res://scripts/systems/equipment.gd")

static func normalize(data: Dictionary) -> Dictionary:
    if int(data.get("version", 1)) == 2:
        return data.duplicate(true)
    var legacy_level = clampi(int(data.get("upgrade_level", 0)), 0, 500)
    var index = clampi(int(data.get("weapon_index", 0)), 0, 2)
    var kills = clampi(int(data.get("total_kills", 0)), 0, 2000000000)
    var inventory: Dictionary = {"steel":{"id":"steel","level":1,"rarity":"common"}}
    if not data.is_empty():
        for id in ["steel", "crystal", "ember"]:
            inventory[id] = {"id":id,"level":legacy_level + 1,"rarity":Equipment.definition(id).rarity}
    var result={
        "version":2,
        "profile":{"gold":clampi(int(data.get("gold", 0)),0,2000000000),"xp":mini(2000000000,kills * 20),"kills":kills,"shards":0,"inventory":inventory,"equipped":Equipment.IDS[index],"look":"canonical","aura":false,"run_serial":1,"best_wave":maxi(1,int(data.get("wave",1))),"claims":{},"loot":[],"legacy_snapshot":data.duplicate(true)},
        "checkpoint":{"tier":clampi((int(data.get("wave",1)) - 1) / 5,0,100),"encounter":(maxi(1,int(data.get("wave",1))) - 1) % 5,"run_id":"run-1"},
        "load_error":str(data.get("load_error", "")),"read_only":bool(data.get("read_only", false))
    }
    if data.is_empty():
        result.profile.hero_roster={"schema":1,"active":"runenpaladin","owned":{"runenpaladin":{"xp":0,"source":"starter709"}},"independent_xp":true,"starter_revision":1}
    return result
