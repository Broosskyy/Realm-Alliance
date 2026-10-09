extends SceneTree

const CombatModel = preload("res://scripts/combat_model.gd")
var failures: int = 0

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("FAILED: " + message)
    else:
        print("PASS: " + message)

func _initialize() -> void:
    var model = CombatModel.new()
    _check(model.wave == 1, "starts at wave 1")
    _check(model.enemy_hp == model.enemy_max_hp, "enemy starts with full HP")
    _check(model.hero_damage() == 15, "base player damage")
    _check(not model.try_upgrade(), "cannot purchase unaffordable upgrade")
    _check(not model.advance_wave(), "cannot skip a living enemy")

    var hit: Dictionary = model.attack(10.0)
    _check(bool(hit["killed"]), "strong attack defeats first enemy")
    _check(model.gold == 17, "first kill awards 17 gold")
    _check(model.total_kills == 1, "kill counted once")

    var repeat: Dictionary = model.attack(10.0)
    _check(not bool(repeat["valid"]), "cannot hit an already defeated enemy")
    _check(model.gold == 17 and model.total_kills == 1, "no duplicate reward")

    _check(model.advance_wave(), "cleared wave advances")
    _check(model.wave == 2 and model.enemy_hp > 0, "next wave spawns enemy")
    model.attack(100.0)
    _check(model.try_upgrade(), "purchase upgrade after earning gold")
    _check(model.upgrade_level == 1, "upgrade level increases")

    model.cycle_weapon()
    _check(model.weapon_index == 1, "weapon index cycles")
    _check(model.hero_damage() > 15, "equipment and upgrades change damage")

    var saved: Dictionary = model.snapshot()
    var restored = CombatModel.new(saved)
    _check(restored.wave == model.wave, "save restores wave")
    _check(restored.weapon_index == model.weapon_index, "save restores equipment")
    _check(restored.gold == model.gold, "save restores gold")
    _check(restored.enemy_hp == restored.enemy_max_hp, "resume begins at wave checkpoint")
    print("Combat model: ", 16 - failures, "/16 checks passed.")
    quit(1 if failures > 0 else 0)
