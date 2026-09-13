extends RefCounted
class_name EncounterProgressService

## V2.08 — encounter stage / boss cycle presentation helpers.

static func boss_every() -> int:
	return RegionProgressionSystem.boss_every()

static func stage_in_cycle(monster_level: int) -> int:
	return ((maxi(monster_level, 1) - 1) % boss_every()) + 1

static func until_boss(monster_level: int) -> int:
	if P0MonsterVisualSystem.is_boss(monster_level):
		return 0
	return boss_every() - stage_in_cycle(monster_level)

static func active_region_name() -> String:
	return RegionProgressionSystem.active_region_name_upper()

static func progress_label(monster_level: int) -> String:
	var region := active_region_name()
	if P0MonsterVisualSystem.is_boss(monster_level):
		return "%s · BOSS · %d / %d" % [region, boss_every(), boss_every()]
	var cls := P0MonsterVisualSystem.monster_classification(monster_level)
	if cls in ["elite", "special"]:
		return "%s · ELITE · %d / %d BIS BOSS" % [region, stage_in_cycle(monster_level), boss_every()]
	if cls == "tough":
		return "%s · STARK · %d / %d BIS BOSS" % [region, stage_in_cycle(monster_level), boss_every()]
	return "%s · %d / %d BIS BOSS" % [region, stage_in_cycle(monster_level), boss_every()]

static func boss_proximity_label(monster_level: int) -> String:
	if P0MonsterVisualSystem.is_boss(monster_level):
		return "BOSS · %s" % P0MonsterVisualSystem.display_name(monster_level).to_upper()
	var remaining := until_boss(monster_level)
	if remaining == 1:
		return "BOSS BEREIT"
	if remaining <= 3:
		return "BOSS IN %d" % remaining
	if stage_in_cycle(monster_level) == int(boss_every() / 2):
		return "HALBZEIT · %d / %d" % [stage_in_cycle(monster_level), boss_every()]
	return ""

static func encounter_progress_snapshot(monster_level: int) -> Dictionary:
	return {
		"region_id": RegionProgressionSystem.active_region_id(),
		"region_name": RegionProgressionSystem.active_region_name(),
		"monster_level": monster_level,
		"encounter_id": P0MonsterVisualSystem.production_asset_id(monster_level),
		"monster_name": P0MonsterVisualSystem.display_name(monster_level),
		"classification": P0MonsterVisualSystem.monster_classification(monster_level),
		"stage_in_cycle": stage_in_cycle(monster_level),
		"until_boss": until_boss(monster_level),
		"is_boss": P0MonsterVisualSystem.is_boss(monster_level),
		"progress_label": progress_label(monster_level)
	}
