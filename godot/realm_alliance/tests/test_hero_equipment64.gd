extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Store=preload("res://scripts/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:
    var s=Session.new()
    check(s.player_max_hp==150 and s.defense==0,"legacy/default hero receives no invented gear bonuses")
    check(s.profile.hero_equipment.owned.is_empty(),"new catalog does not invent owned items")
    check(not s.change_gear("astral_plate"),"unowned armor cannot be equipped")
    check(not s.change_gear("astral_plate","acquire"),"acquire requires actual currency")
    s.gold=1000;s.profile.shards=100
    check(not s.change_gear("eclipse_plate","acquire"),"level requirement enforced")
    check(s.change_gear("astral_plate","acquire") and s.gold==965 and s.profile.shards==98,"acquire spends exact stable catalog costs")
    check(not s.change_gear("astral_plate","acquire"),"duplicate acquisition cannot spend twice")
    s.player_hp=100
    check(s.change_gear("astral_plate") and s.player_max_hp==170 and s.player_hp==120 and s.defense==2,"equipping preserves missing health and adds genuine stats")
    s._enemy_strike(1,false)
    var reduced=s.player_hp
    var bare=Session.new();bare.player_hp=120;bare._enemy_strike(1,false)
    check(reduced==bare.player_hp+2,"armor reduces actual incoming damage")
    check(s.change_gear("chest","unequip") and s.player_max_hp==150,"unequip removes only the relevant bonuses")
    s.change_gear("astral_plate")
    var damaged=s.player_hp
    for i in 8:s.change_gear("chest","unequip");s.change_gear("astral_plate")
    check(s.player_hp==damaged,"repeated equipment swaps cannot heal")
    check(s.change_gear("astral_plate","upgrade") and s.player_max_hp==173 and s.defense==3,"upgrades change armor statistics")
    check(Gear.set_cosmetic(s.profile,"chest","") and Gear.visible_id(s.profile,"chest")=="","cosmetic hide is separate from equipped statistics")
    check(s.defense==3,"cosmetic override cannot remove gameplay armor")
    check(not Gear.set_cosmetic(s.profile,"head","astral_plate"),"cosmetics respect compatible slots")
    var restored=Session.new(s.snapshot())
    check(restored.player_hp==s.player_hp and restored.defense==3,"checkpoint and new gear round-trip")
    check(Store._valid(s.snapshot()),"extended profile remains valid inside existing V2 save envelope")
    var legacy=Session.new({"version":1,"gold":987,"weapon_index":1,"upgrade_level":2,"total_kills":6})
    check(legacy.gold==987 and legacy.profile.inventory.crystal.level==3,"V1 migration keeps real currency and weapon levels")
    check(legacy.profile.hero_equipment.owned.is_empty(),"legacy migration adds empty optional equipment domain")
    var future=s.snapshot();future.profile.hero_equipment.schema=99
    var blocked=Session.new(future)
    check(blocked.read_only and blocked.profile.hero_equipment.schema==99,"future domain is preserved and blocks automatic writeback")
    check(not blocked.change_gear("astral_plate","upgrade"),"future domain cannot mutate")
    var dead=Session.new();dead.gold=100;dead.profile.shards=10;dead.change_gear("astral_plate","acquire");dead.player_hp=0
    check(dead.change_gear("astral_plate") and dead.player_hp==0,"equipping cannot resurrect a defeated hero")
    check(not s.change_gear("unknown","acquire"),"unknown item IDs cannot consume currency")
    print("Hero equipment 6.4: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
