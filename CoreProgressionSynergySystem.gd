extends Node

signal synergy_changed

const DATA_PATH := "res://data/core_synergy_v174.json"
var config: Dictionary = {}

func _ready() -> void:
	_load()
	VillageProgressionSystem.village_progression_changed.connect(_emit_changed)
	HeroProgressionSystem.hero_progression_changed.connect(_emit_changed)
	HeroSystem.heroes_changed.connect(_emit_changed)

func _load() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		config = {}
		return
	var parsed = JSON.parse_string(f.get_as_text())
	config = parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _emit_changed() -> void:
	synergy_changed.emit()

func tap_bonus_ratio() -> float:
	var village_step := float(config.get("tap_bonus_per_village_prosperity_level", 0.02))
	var hero_step := float(config.get("tap_bonus_per_selected_hero_mastery_level", 0.015))
	var cap := maxf(float(config.get("tap_bonus_cap", 0.20)), 0.0)
	var village_levels := maxi(VillageProgressionSystem.prosperity_level - 1, 0)
	var hero_id := HeroSystem.get_selected_hero_id()
	var hero_mastery := maxi(int(HeroProgressionSystem.mastery_level.get(hero_id, 1)) - 1, 0)
	return clampf(float(village_levels) * village_step + float(hero_mastery) * hero_step, 0.0, cap)

func tap_multiplier() -> float:
	return 1.0 + tap_bonus_ratio()

func apply_tap_synergy(base_damage: int) -> int:
	return maxi(1, int(round(float(maxi(base_damage, 1)) * tap_multiplier())))

func boss_village_xp() -> int:
	return maxi(int(config.get("boss_defeat_village_xp", 1)), 0)

func summary_text() -> String:
	var bonus := int(round(tap_bonus_ratio() * 100.0))
	var hero_id := HeroSystem.get_selected_hero_id()
	var hero_mastery := int(HeroProgressionSystem.mastery_level.get(hero_id, 1))
	return "REALM-KRAFT · +%d%% TAP · DORF %d · HELD %d" % [
		bonus,
		VillageProgressionSystem.prosperity_level,
		hero_mastery
	]
