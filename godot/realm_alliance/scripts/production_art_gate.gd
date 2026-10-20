extends RefCounted
class_name RAProductionArtGate

const ROOT: String = "res://assets/production/"
const HERO_STATES: Array[String] = ["idle", "ready", "windup", "attack_contact", "recovery", "hit"]
const WEAPONS: Array[String] = ["steel", "crystal", "ember", "rune_gold", "shadow_violet"]
const ENEMY_STATES: Array[String] = ["golem_idle_ready", "golem_attack", "golem_hit_damage", "golem_defeated"]

static func missing_paths() -> Array[String]:
    var missing: Array[String] = []
    for state in HERO_STATES:
        var p: String = ROOT + "hero/" + state + ".png"
        if not ResourceLoader.exists(p):
            missing.append(p)
    for variant in WEAPONS:
        var p: String = ROOT + "weapons/" + variant + ".png"
        if not ResourceLoader.exists(p):
            missing.append(p)
    for state in ENEMY_STATES:
        var p: String = ROOT + "enemy/" + state + ".png"
        if not ResourceLoader.exists(p):
            missing.append(p)
    var stage_path: String = ROOT + "world/wolkgarten_battle_plate.png"
    if not ResourceLoader.exists(stage_path):
        missing.append(stage_path)
    return missing

static func available() -> bool:
    return missing_paths().is_empty()
