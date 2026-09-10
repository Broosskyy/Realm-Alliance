extends Node

const SAVE_PATH := "user://savegame.json"
const TEMP_SAVE_PATH := "user://savegame.tmp"
const BACKUP_SAVE_PATH := "user://savegame.bak"
const SAVE_VERSION := 35

signal save_completed
signal load_completed

var last_seen_unix: int = 0
var seconds_away_on_last_load: int = 0
var recovered_from_backup: bool = false
var load_source: String = "none"
var save_sequence: int = 0
var last_save_ok: bool = false

func save_game() -> void:
	last_save_ok = false
	var now_unix := ServerClockService.now_unix()
	last_seen_unix = now_unix
	var data := {
		"version": SAVE_VERSION,
		"save_sequence": save_sequence + 1,
		"last_seen_unix": last_seen_unix,
		"gold": PlayerData.gold,
		"gems": PlayerData.gems,
		"spins": PlayerData.spins,
		"shields": PlayerData.shields,
		"player_level": PlayerData.player_level,
		"player_xp": PlayerData.player_xp,
		"village_level": PlayerData.village_level,
		"tap_level": PlayerData.tap_level,
		"tap_damage": PlayerData.tap_damage,
		"monster_level": PlayerData.monster_level,
		"monster_max_hp": PlayerData.monster_max_hp,
		"current_monster_hp": PlayerData.current_monster_hp,
		"owned_cosmetics": PlayerData.owned_cosmetics,
		"no_ads_owned": PlayerData.no_ads_owned,
		"daily_streak": PlayerData.daily_streak,
		"last_daily_claim_unix": PlayerData.last_daily_claim_unix,
		"hero_system": HeroSystem.export_save_data(),
		"unlock_service": UnlockService.export_save_data(),
		"quest_system": QuestSystem.export_save_data(),
		"p0_village": P0VillageSystem.export_save_data(),
		"settings": SettingsService.export_save_data(),
		"account_state": AccountState.export_save_data(),
		"social_hub": SocialHubSystem.export_save_data(),
		"spin_presentation": SpinPresentationState.export_save_data(),
		"dice_journey": DiceJourneySystem.export_save_data(),
		"meta_progress": MetaProgressSystem.export_save_data(),
		"puzzle": PuzzleSystem.export_save_data(),
		"tower_defense": TowerDefenseSystem.export_save_data(),
		"lane_battle": LaneAttackSystem.export_save_data(),
		"liveops_ranking": LiveOpsRankingSystem.export_save_data(),
		"afk_rewards": AfkRewardSystem.export_save_data(),
		"journey_progression": JourneyProgressionSystem.export_save_data(),
		"puzzle_progression": PuzzleProgressionSystem.export_save_data(),
		"tower_defense_progression": TowerDefenseProgressionSystem.export_save_data(),
		"lane_battle_progression": LaneBattleProgressionSystem.export_save_data(),
		"hero_progression": HeroProgressionSystem.export_save_data(),
		"objectives": ObjectiveSystem.export_save_data(),
		"village_progression": VillageProgressionSystem.export_save_data(),
		"online_authority": OnlineAuthorityService.export_local_sync_state(),
		"server_clock": ServerClockService.export_sync_state(),
		"player_snapshot_sync": PlayerSnapshotService.sync_metadata(),
		"sync_reconciliation": SyncReconciliationService.export_sync_state(),
		"auth_session_descriptor": AuthSessionService.session_descriptor()
	}

	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Could not open temporary save")
		return
	file.store_string(JSON.stringify(data))
	file.close()

	var user_dir := DirAccess.open("user://")
	if user_dir == null:
		push_error("Could not open user://")
		return

	if FileAccess.file_exists(BACKUP_SAVE_PATH):
		user_dir.remove("savegame.bak")
	if FileAccess.file_exists(SAVE_PATH):
		var backup_error := user_dir.rename("savegame.json", "savegame.bak")
		if backup_error != OK:
			push_error("Save backup failed: %s" % backup_error)
			return

	var rename_error := user_dir.rename("savegame.tmp", "savegame.json")
	if rename_error != OK:
		push_error("Save rename failed: %s" % rename_error)
		if FileAccess.file_exists(BACKUP_SAVE_PATH):
			user_dir.rename("savegame.bak", "savegame.json")
		return

	if FileAccess.file_exists(BACKUP_SAVE_PATH):
		user_dir.remove("savegame.bak")
	save_sequence += 1
	last_save_ok = true
	save_completed.emit()

func load_game() -> void:
	recovered_from_backup = false
	load_source = "none"

	var parsed := _read_save_dictionary(SAVE_PATH)
	if not _is_save_dictionary_valid(parsed):
		parsed = {}

	if parsed.is_empty() and FileAccess.file_exists(BACKUP_SAVE_PATH):
		var backup := _read_save_dictionary(BACKUP_SAVE_PATH)
		if _is_save_dictionary_valid(backup):
			parsed = backup
			recovered_from_backup = true
			load_source = "backup"

	if parsed.is_empty():
		SpinPresentationState.apply_save_data({})
		DiceJourneySystem.apply_save_data({})
		MetaProgressSystem.apply_save_data({})
		PuzzleProgressionSystem.apply_save_data({})
		PuzzleSystem.apply_save_data({})
		TowerDefenseProgressionSystem.apply_save_data({})
		TowerDefenseSystem.apply_save_data({})
		LaneBattleProgressionSystem.apply_save_data({})
		HeroProgressionSystem.apply_save_data({})
		ObjectiveSystem.apply_save_data({})
		VillageProgressionSystem.apply_save_data({})
		LaneAttackSystem.apply_save_data({})
		LiveOpsRankingSystem.apply_save_data({})
		AfkRewardSystem.apply_save_data({})
		JourneyProgressionSystem.apply_save_data({})
		SocialHubSystem.apply_save_data({})
		last_seen_unix = ServerClockService.now_unix()
		seconds_away_on_last_load = 0
		load_source = "fresh"
		load_completed.emit()
		return

	if load_source == "none":
		load_source = "primary"

	var now_unix := ServerClockService.now_unix()
	last_seen_unix = int(parsed.get("last_seen_unix", now_unix))
	seconds_away_on_last_load = maxi(now_unix - last_seen_unix, 0)
	save_sequence = maxi(int(parsed.get("save_sequence", 0)), 0)

	PlayerData.apply_save_data(parsed)
	HeroSystem.apply_save_data(parsed.get("hero_system", {}))
	UnlockService.apply_save_data(parsed.get("unlock_service", {}))
	QuestSystem.apply_save_data(parsed.get("quest_system", {}))
	P0VillageSystem.apply_save_data(parsed.get("p0_village", {}))
	VillageProgressionSystem.apply_save_data(parsed.get("village_progression", {}))
	SettingsService.apply_save_data(parsed.get("settings", {}))
	if parsed.has("account_state"):
		AccountState.apply_save_data(parsed.get("account_state", {}))
	SocialHubSystem.apply_save_data(parsed.get("social_hub", {}))
	SpinPresentationState.apply_save_data(parsed.get("spin_presentation", {}))
	DiceJourneySystem.apply_save_data(parsed.get("dice_journey", {}))
	MetaProgressSystem.apply_save_data(parsed.get("meta_progress", {}))
	PuzzleProgressionSystem.apply_save_data(parsed.get("puzzle_progression", {}))
	PuzzleSystem.apply_save_data(parsed.get("puzzle", {}))
	TowerDefenseProgressionSystem.apply_save_data(parsed.get("tower_defense_progression", {}))
	TowerDefenseSystem.apply_save_data(parsed.get("tower_defense", {}))
	LaneBattleProgressionSystem.apply_save_data(parsed.get("lane_battle_progression", {}))
	HeroProgressionSystem.apply_save_data(parsed.get("hero_progression", {}))
	ObjectiveSystem.apply_save_data(parsed.get("objectives", {}))
	LaneAttackSystem.apply_save_data(parsed.get("lane_battle", {}))
	LiveOpsRankingSystem.apply_save_data(parsed.get("liveops_ranking", {}))
	AfkRewardSystem.apply_save_data(parsed.get("afk_rewards", {}))
	JourneyProgressionSystem.apply_save_data(parsed.get("journey_progression", {}))

	var repaired := _repair_legacy_zero_hp_monster()

	# A backup recovery must recreate a clean primary save. Remove only the
	# rejected primary/temp first, leaving the valid backup intact until the
	# atomic save succeeds.
	if recovered_from_backup:
		_remove_rejected_primary_files()
		save_game()
		if last_save_ok:
			push_warning("Recovered Realm Alliance save from backup and restored primary")
		else:
			push_error("Backup loaded, but primary restore failed")
	elif repaired:
		save_game()

	load_completed.emit()

func _read_save_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _is_save_dictionary_valid(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	var version := int(data.get("version", 0))
	if version < 1 or version > SAVE_VERSION:
		return false
	if int(data.get("gold", 0)) < 0:
		return false
	if int(data.get("spins", 0)) < 0:
		return false
	var shields := int(data.get("shields", 0))
	if shields < 0 or shields > GameConfig.MAX_SHIELDS:
		return false
	var monster_level := int(data.get("monster_level", 1))
	var monster_max_hp := int(data.get("monster_max_hp", 1))
	var monster_hp := int(data.get("current_monster_hp", 1))
	if monster_level < 1 or monster_max_hp <= 0:
		return false
	# HP=0 is intentionally accepted for the V1.12 legacy repair path.
	if monster_hp < 0 or monster_hp > monster_max_hp:
		return false
	return true

func _remove_rejected_primary_files() -> void:
	var user_dir := DirAccess.open("user://")
	if user_dir == null:
		return
	for filename in ["savegame.json", "savegame.tmp"]:
		if FileAccess.file_exists("user://" + filename):
			user_dir.remove(filename)

func delete_save() -> void:
	var user_dir := DirAccess.open("user://")
	if user_dir == null:
		return
	for filename in ["savegame.json", "savegame.tmp", "savegame.bak"]:
		if FileAccess.file_exists("user://" + filename):
			user_dir.remove(filename)
	last_seen_unix = 0
	seconds_away_on_last_load = 0
	recovered_from_backup = false
	load_source = "none"
	save_sequence = 0
	last_save_ok = false


func _repair_legacy_zero_hp_monster() -> bool:
	# V1.12 could persist an already rewarded encounter at HP=0 before
	# the Continue button advanced to the next monster. Never reward again.
	if PlayerData.current_monster_hp > 0:
		return false
	var repaired_from_level := PlayerData.monster_level
	PlayerData.spawn_next_monster()
	push_warning("Repaired legacy HP=0 encounter from level %d to %d" % [
		repaired_from_level,
		PlayerData.monster_level
	])
	CoreAnalytics.log_event("save_repair_zero_hp", {
		"from_level":repaired_from_level,
		"to_level":PlayerData.monster_level
	})
	return true
