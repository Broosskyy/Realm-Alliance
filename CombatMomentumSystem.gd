extends Node

signal momentum_changed(tier: int, multiplier: float)

const MAX_TIER := 5
const TAP_WINDOW_SECONDS := 1.15
const BONUS_PER_TIER := 0.04

var tier: int = 0
var _time_since_tap: float = 999.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if tier <= 0:
		return
	_time_since_tap += delta
	if _time_since_tap > TAP_WINDOW_SECONDS:
		tier = 0
		momentum_changed.emit(tier, 1.0)

func register_tap() -> Dictionary:
	if _time_since_tap <= TAP_WINDOW_SECONDS:
		tier = mini(tier + 1, MAX_TIER)
	else:
		tier = 1
	_time_since_tap = 0.0
	var multiplier := damage_multiplier()
	momentum_changed.emit(tier, multiplier)
	return {"tier":tier, "multiplier":multiplier}

func damage_multiplier() -> float:
	return 1.0 + float(maxi(tier - 1, 0)) * BONUS_PER_TIER

func effective_tap_damage(base_damage: int) -> int:
	var realm_base := CoreProgressionSynergySystem.apply_tap_synergy(base_damage)
	return maxi(1, int(round(float(realm_base) * damage_multiplier())))

func reset() -> void:
	if tier == 0:
		_time_since_tap = 999.0
		return
	tier = 0
	_time_since_tap = 999.0
	momentum_changed.emit(tier, 1.0)
