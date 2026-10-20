extends RefCounted
class_name RACombatModel

# Presentation-agnostic rules. Reward is applied at most once per wave.
const SAVE_VERSION: int = 1
const WEAPON_IDS: Array[String] = ["iron", "crystal", "ember"]
const WEAPON_BONUS: Array[int] = [0, 8, 18]

var wave: int = 1
var gold: int = 0
var upgrade_level: int = 0
var weapon_index: int = 0
var total_kills: int = 0
var enemy_max_hp: int = 1
var enemy_hp: int = 1

func _init(data: Dictionary = {}) -> void:
    if int(data.get("version", SAVE_VERSION)) == SAVE_VERSION:
        wave = clampi(int(data.get("wave", 1)), 1, 10000)
        gold = clampi(int(data.get("gold", 0)), 0, 2000000000)
        upgrade_level = clampi(int(data.get("upgrade_level", 0)), 0, 500)
        weapon_index = clampi(int(data.get("weapon_index", 0)), 0, WEAPON_IDS.size() - 1)
        total_kills = clampi(int(data.get("total_kills", 0)), 0, 2000000000)
    enemy_max_hp = _hp_for_wave(wave)
    enemy_hp = enemy_max_hp

func _hp_for_wave(number: int) -> int:
    return maxi(1, int(minf(2000000000.0, round(95.0 * pow(1.17, number - 1)))))

func hero_damage() -> int:
    return 15 + upgrade_level * 6 + WEAPON_BONUS[weapon_index]

func upgrade_cost() -> int:
    return 20 + upgrade_level * 17

func try_upgrade() -> bool:
    var cost := upgrade_cost()
    if gold < cost or upgrade_level >= 500:
        return false
    gold -= cost
    upgrade_level += 1
    return true

func cycle_weapon() -> int:
    weapon_index = (weapon_index + 1) % WEAPON_IDS.size()
    return weapon_index

func attack(multiplier: float = 1.0) -> Dictionary:
    # No duplicate rewards if taps, skill and auto happen during death animation.
    if enemy_hp <= 0:
        return {"valid": false, "damage": 0, "killed": false, "gold_gain": 0}
    var damage := maxi(1, int(round(hero_damage() * maxf(0.1, multiplier))))
    enemy_hp = maxi(0, enemy_hp - damage)
    var killed := enemy_hp == 0
    var gained := 0
    if killed:
        total_kills += 1
        gained = 12 + wave * 5
        gold = mini(2000000000, gold + gained)
    return {"valid": true, "damage": damage, "killed": killed, "gold_gain": gained}

func advance_wave() -> bool:
    if enemy_hp > 0:
        return false
    wave += 1
    enemy_max_hp = _hp_for_wave(wave)
    enemy_hp = enemy_max_hp
    return true

func snapshot() -> Dictionary:
    # Persist the NEXT wave on lethal hit to prevent double rewards after a reload.
    return {
        "version": SAVE_VERSION,
        "wave": wave + (1 if enemy_hp <= 0 else 0),
        "gold": gold,
        "upgrade_level": upgrade_level,
        "weapon_index": weapon_index,
        "total_kills": total_kills
    }
