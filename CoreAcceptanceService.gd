extends Node

const EncounterCatalogValidator = preload("res://EncounterCatalogValidator.gd")
const REQUIRED_VISIBLE_VIEWS := ["home", "wheel", "village"]
const STARTING_SPINS := P0RuntimeContract.STARTING_SPINS
const STARTING_GOLD := P0RuntimeContract.STARTING_GOLD

var session_start_unix: int = 0
var session_start_monster_level: int = 1
var session_start_gold: int = 0
var session_start_spins: int = 0

func _heroes_in_core_scope() -> bool:
	return BuildInfo.BUILD_NUMBER >= 2060

func begin_session() -> void:
	session_start_unix = int(Time.get_unix_time_from_system())
	session_start_monster_level = PlayerData.monster_level
	session_start_gold = PlayerData.gold
	session_start_spins = PlayerData.spins
	CoreAnalytics.log_event("core_session_start", {
		"monster_level": session_start_monster_level,
		"gold": session_start_gold,
		"spins": session_start_spins,
		"seconds_away": SaveGame.seconds_away_on_last_load,
		"save_recovered": SaveGame.recovered_from_backup
	})

func validate_runtime_contract() -> Array[String]:
	var errors: Array[String] = P0RuntimeContract.validate()
	if not _heroes_in_core_scope():
		if FeatureFlags.SHOW_HEROES:
			errors.append("P0 violation: Heroes visible")
		if FeatureFlags.ENABLE_HERO_AUTODPS:
			errors.append("P0 violation: Hero Auto-DPS active")
	if FeatureFlags.SHOW_ATTACK:
		errors.append("P0 violation: Attack visible")
	if FeatureFlags.SHOW_DEFENSE:
		errors.append("P0 violation: Defense visible")
	if WheelSystem.total_weight() != 100:
		errors.append("Wheel weights must sum to 100")
	var boss_level := P0MonsterVisualSystem.boss_every_kills()
	var elite_level := boss_level - 1
	if elite_level < 1:
		errors.append("Invalid boss interval: boss level %d" % boss_level)
	elif P0MonsterVisualSystem.production_asset_id(elite_level) != "M010":
		errors.append("Encounter %d must be M010 elite" % elite_level)
	elif P0MonsterVisualSystem.monster_classification(elite_level) != "elite":
		errors.append("Encounter %d must be elite classification" % elite_level)
	if P0MonsterVisualSystem.encounter_id_for_level(boss_level) != "B001":
		errors.append("Encounter %d must be B001" % boss_level)
	for catalog_error in EncounterCatalogValidator.validate_greenvale():
		errors.append("encounter catalog: %s" % catalog_error)
	return errors

func log_contract_status() -> void:
	var errors := validate_runtime_contract()
	if errors.is_empty():
		CoreAnalytics.log_event("core_contract_pass")
		return
	for error in errors:
		push_error(error)
	CoreAnalytics.log_event("core_contract_fail", {"errors": errors})

func acceptance_snapshot() -> Dictionary:
	return {
		"source_version": BuildInfo.SOURCE_VERSION,
		"master_concept": BuildInfo.MASTER_CONCEPT,
		"session_seconds": maxi(int(Time.get_unix_time_from_system()) - session_start_unix, 0),
		"monster_level": PlayerData.monster_level,
		"gold": PlayerData.gold,
		"spins": PlayerData.spins,
		"shields": PlayerData.shields,
		"village": P0VillageSystem.export_save_data(),
		"last_seen_unix": SaveGame.last_seen_unix,
		"seconds_away_on_load": SaveGame.seconds_away_on_last_load,
		"save_recovered": SaveGame.recovered_from_backup,
		"contract_errors": validate_runtime_contract()
	}
