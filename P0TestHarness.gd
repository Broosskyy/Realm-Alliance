extends Node

signal profile_applied(profile_id: String)
signal recovery_fixture_written(path: String)

const PROFILE_FRESH := "fresh"
const PROFILE_HALF_BOSS := "half_boss"
const PROFILE_BOSS_READY := "boss_ready"
const PROFILE_WHEEL := "wheel"
const PROFILE_VILLAGE := "village"
const PROFILE_RETURN := "return"
const PROFILE_LOW_RESOURCE := "low_resource"
const PROFILE_LEGACY_ZERO_HP := "legacy_zero_hp"

var enabled: bool = OS.is_debug_build()

func available_profiles() -> Array[String]:
	return [
		PROFILE_FRESH,
		PROFILE_HALF_BOSS,
		PROFILE_BOSS_READY,
		PROFILE_WHEEL,
		PROFILE_VILLAGE,
		PROFILE_RETURN,
		PROFILE_LOW_RESOURCE,
		PROFILE_LEGACY_ZERO_HP
	]

func apply_profile(profile_id: String) -> Dictionary:
	if not enabled:
		return {"ok":false,"message":"Test Harness nur in Debug-Builds"}

	_reset_shared_state()

	match profile_id:
		PROFILE_FRESH:
			_apply_fresh()
		PROFILE_HALF_BOSS:
			_apply_half_boss()
		PROFILE_BOSS_READY:
			_apply_boss_ready()
		PROFILE_WHEEL:
			_apply_wheel()
		PROFILE_VILLAGE:
			_apply_village()
		PROFILE_RETURN:
			_apply_return()
		PROFILE_LOW_RESOURCE:
			_apply_low_resource()
		PROFILE_LEGACY_ZERO_HP:
			_apply_legacy_zero_hp()
		_:
			return {"ok":false,"message":"Unbekanntes Testprofil: %s" % profile_id}

	SaveGame.save_game()
	profile_applied.emit(profile_id)
	CoreAnalytics.log_event("test_profile_applied", {"profile":profile_id})
	return {"ok":true,"profile":profile_id}

func _reset_shared_state() -> void:
	PlayerData.gold = 300
	PlayerData.gems = 0
	PlayerData.spins = P0RuntimeContract.STARTING_SPINS
	PlayerData.shields = 0
	PlayerData.player_level = 1
	PlayerData.player_xp = 0
	PlayerData.village_level = 1
	PlayerData.tap_level = 1
	PlayerData.tap_damage = 10
	PlayerData.monster_level = 1
	PlayerData.monster_max_hp = GameConfig.effective_monster_hp(1)
	PlayerData.current_monster_hp = PlayerData.monster_max_hp

	P0VillageSystem.levels = {
		"townhall":1,
		"goldmine":1,
		"forge":1,
		"lucktemple":1
	}
	P0VillageSystem.last_goldmine_claim_unix = int(Time.get_unix_time_from_system())
	PlayerData.stats_changed.emit()
	PlayerData.monster_changed.emit()
	PlayerData.progression_changed.emit()
	P0VillageSystem.village_changed.emit()

func _set_monster_level(level: int, hp_ratio: float = 1.0) -> void:
	PlayerData.monster_level = maxi(level, 1)
	PlayerData.monster_max_hp = GameConfig.effective_monster_hp(PlayerData.monster_level)
	PlayerData.current_monster_hp = clampi(
		int(round(float(PlayerData.monster_max_hp) * hp_ratio)),
		1,
		PlayerData.monster_max_hp
	)
	PlayerData.monster_changed.emit()
	PlayerData.progression_changed.emit()

func _apply_fresh() -> void:
	pass

func _apply_half_boss() -> void:
	_set_monster_level(5)
	PlayerData.gold = 1450

func _apply_boss_ready() -> void:
	_set_monster_level(10)
	PlayerData.gold = 1900
	PlayerData.spins = 48

func _apply_wheel() -> void:
	_set_monster_level(3)
	PlayerData.spins = 3
	PlayerData.gold = 1200

func _apply_village() -> void:
	_set_monster_level(6)
	PlayerData.gold = 2500
	P0VillageSystem.levels["townhall"] = 1
	P0VillageSystem.levels["goldmine"] = 2
	P0VillageSystem.levels["forge"] = 1
	P0VillageSystem.levels["lucktemple"] = 2
	P0VillageSystem.last_goldmine_claim_unix = int(Time.get_unix_time_from_system()) - 600
	P0VillageSystem.village_changed.emit()

func _apply_return() -> void:
	_set_monster_level(7, 0.45)
	PlayerData.gold = 1620
	PlayerData.spins = 11
	P0VillageSystem.levels["goldmine"] = 2
	P0VillageSystem.last_goldmine_claim_unix = int(Time.get_unix_time_from_system()) - 1800
	P0VillageSystem.village_changed.emit()

func _apply_low_resource() -> void:
	_set_monster_level(4)
	PlayerData.gold = 20
	PlayerData.spins = 0
	PlayerData.shields = GameConfig.MAX_SHIELDS
	PlayerData.stats_changed.emit()


func _apply_legacy_zero_hp() -> void:
	_set_monster_level(4)
	# Simulates the V1.12 post-reward/pre-continue persisted state.
	PlayerData.gold = 1400
	PlayerData.current_monster_hp = 0
	PlayerData.monster_changed.emit()

func write_corrupt_primary_with_backup_fixture() -> Dictionary:
	if not enabled:
		return {"ok":false,"message":"Nur in Debug-Builds"}
	SaveGame.save_game()
	var dir := DirAccess.open("user://")
	if dir == null:
		return {"ok":false,"message":"user:// nicht verfügbar"}

	if FileAccess.file_exists(SaveGame.BACKUP_SAVE_PATH):
		dir.remove("savegame.bak")
	if FileAccess.file_exists(SaveGame.SAVE_PATH):
		var copy_error := dir.copy("savegame.json", "savegame.bak")
		if copy_error != OK:
			return {"ok":false,"message":"Backup-Kopie fehlgeschlagen"}

	var broken := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
	if broken == null:
		return {"ok":false,"message":"Primärsave nicht beschreibbar"}
	broken.store_string("{BROKEN_TEST_SAVE")
	broken.close()
	recovery_fixture_written.emit(SaveGame.SAVE_PATH)
	return {"ok":true,"message":"Korruptes Primärsave + gültiges Backup erzeugt"}

func write_invalid_primary_with_backup_fixture() -> Dictionary:
	if not enabled:
		return {"ok":false,"message":"Nur in Debug-Builds"}
	SaveGame.save_game()
	var dir := DirAccess.open("user://")
	if dir == null:
		return {"ok":false,"message":"user:// nicht verfügbar"}

	if FileAccess.file_exists(SaveGame.BACKUP_SAVE_PATH):
		dir.remove("savegame.bak")
	if FileAccess.file_exists(SaveGame.SAVE_PATH):
		var copy_error := dir.copy("savegame.json", "savegame.bak")
		if copy_error != OK:
			return {"ok":false,"message":"Backup-Kopie fehlgeschlagen"}

	var invalid := {
		"version":SaveGame.SAVE_VERSION,
		"last_seen_unix":int(Time.get_unix_time_from_system()),
		"gold":-999,
		"spins":P0RuntimeContract.STARTING_SPINS,
		"shields":0,
		"monster_level":1,
		"monster_max_hp":100,
		"current_monster_hp":100
	}
	var broken := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
	if broken == null:
		return {"ok":false,"message":"Primärsave nicht beschreibbar"}
	broken.store_string(JSON.stringify(invalid))
	broken.close()
	return {"ok":true,"message":"Logisch ungültiges Primärsave + gültiges Backup erzeugt"}


func debug_snapshot() -> Dictionary:
	return {
		"monster_level":PlayerData.monster_level,
		"monster_id":P0MonsterVisualSystem.encounter_id_for_level(PlayerData.monster_level),
		"monster_hp":PlayerData.current_monster_hp,
		"monster_max_hp":PlayerData.monster_max_hp,
		"gold":PlayerData.gold,
		"spins":PlayerData.spins,
		"shields":PlayerData.shields,
		"tap_damage":PlayerData.tap_damage,
		"village":P0VillageSystem.export_save_data(),
		"pending_goldmine":P0VillageSystem.pending_goldmine_gold(),
		"contract_errors":CoreAcceptanceService.validate_runtime_contract(),
		"boot":P0BootDiagnostics.snapshot(),
		"save_load_source":SaveGame.load_source,
		"save_sequence":SaveGame.save_sequence,
		"last_save_ok":SaveGame.last_save_ok
	}
