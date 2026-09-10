extends RefCounted
class_name P0RuntimeContract

const VISIBLE_CORE_VIEWS := ["home", "wheel", "village"]
const BOSS_INTERVAL := 10
const STARTING_SPINS := 10
const STARTING_GOLD := 300
const MAX_SHIELDS := 3
const REFERENCE_RESOLUTION := Vector2i(1080, 1920)
const MIN_REFERENCE_TOUCH := Vector2i(96, 96)

static func validate() -> Array[String]:
	var errors: Array[String] = []
	if GameConfig.MAX_SHIELDS != MAX_SHIELDS:
		errors.append("MAX_SHIELDS drift")
	if PlayerData.spins < 0:
		errors.append("Negative spins")
	if PlayerData.gold < 0:
		errors.append("Negative gold")
	if PlayerData.shields < 0 or PlayerData.shields > MAX_SHIELDS:
		errors.append("Shield bounds broken")
	if PlayerData.current_monster_hp < 0:
		errors.append("Negative monster HP")
	if PlayerData.current_monster_hp > PlayerData.monster_max_hp:
		errors.append("Current monster HP above max")
	if PlayerData.monster_level < 1:
		errors.append("Invalid monster level")
	if P0MonsterVisualSystem.encounter_id_for_level(10) != "B001":
		errors.append("Boss interval broken")
	if WheelSystem.total_weight() != 100:
		errors.append("Wheel weights must total 100")
	for building_id in ["townhall","goldmine","forge","lucktemple"]:
		if P0VillageSystem.get_level(building_id) < 1 or P0VillageSystem.get_level(building_id) > 3:
			errors.append("Village level bounds broken: %s" % building_id)
	return errors
