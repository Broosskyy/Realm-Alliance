extends Node

signal remote_state_applied(revision: int)

const CONTRACT_VERSION := "remote-state-apply-v1"

func apply_snapshot(snapshot: Dictionary, revision: int) -> Dictionary:
	var normalized_result := PlayerSnapshotService.normalize_remote_snapshot(snapshot)
	if not bool(normalized_result.get("ok",false)):
		return normalized_result
	if revision < OnlineAuthorityService.server_revision:
		return {"ok":false,"error_code":"STALE_REVISION"}

	var normalized: Dictionary = normalized_result.get("snapshot",{})
	var economy: Dictionary = normalized.get("economy",{})
	var progression: Dictionary = normalized.get("progression",{})
	var domains: Dictionary = normalized.get("domains",{})

	# Apply only after the entire envelope shape has passed validation.
	PlayerData.gold = int(economy.get("gold",0))
	PlayerData.gems = int(economy.get("gems",0))
	PlayerData.spins = int(economy.get("spins",0))
	PlayerData.shields = int(economy.get("shields",0))
	PlayerData.player_level = int(progression.get("player_level",1))
	PlayerData.player_xp = int(progression.get("player_xp",0))
	PlayerData.tap_level = int(progression.get("tap_level",1))
	PlayerData.tap_damage = int(progression.get("tap_damage",1))
	PlayerData.monster_level = int(progression.get("monster_level",1))
	PlayerData.monster_max_hp = int(progression.get("monster_max_hp",1))
	PlayerData.current_monster_hp = int(progression.get("current_monster_hp",PlayerData.monster_max_hp))
	PlayerData.village_level = int(progression.get("village_level",1))
	PlayerData.daily_streak = int(progression.get("daily_streak",0))
	PlayerData.last_daily_claim_unix = int(progression.get("last_daily_claim_unix",0))

	if normalized.has("account") and typeof(normalized.get("account")) == TYPE_DICTIONARY:
		AccountState.apply_save_data(normalized.get("account",{}))
	if typeof(domains.get("heroes",{})) == TYPE_DICTIONARY:
		HeroSystem.apply_save_data(domains.get("heroes",{}))
	if typeof(domains.get("village",{})) == TYPE_DICTIONARY:
		P0VillageSystem.apply_save_data(domains.get("village",{}))
	if typeof(domains.get("village_progression",{})) == TYPE_DICTIONARY:
		VillageProgressionSystem.apply_save_data(domains.get("village_progression",{}))
	if typeof(domains.get("journey_progression",{})) == TYPE_DICTIONARY:
		JourneyProgressionSystem.apply_save_data(domains.get("journey_progression",{}))
	if typeof(domains.get("puzzle_progression",{})) == TYPE_DICTIONARY:
		PuzzleProgressionSystem.apply_save_data(domains.get("puzzle_progression",{}))
	if typeof(domains.get("tower_defense_progression",{})) == TYPE_DICTIONARY:
		TowerDefenseProgressionSystem.apply_save_data(domains.get("tower_defense_progression",{}))
	if typeof(domains.get("lane_battle_progression",{})) == TYPE_DICTIONARY:
		LaneBattleProgressionSystem.apply_save_data(domains.get("lane_battle_progression",{}))
	if typeof(domains.get("hero_progression",{})) == TYPE_DICTIONARY:
		HeroProgressionSystem.apply_save_data(domains.get("hero_progression",{}))
	if typeof(domains.get("meta_progress",{})) == TYPE_DICTIONARY:
		MetaProgressSystem.apply_save_data(domains.get("meta_progress",{}))
	if typeof(domains.get("liveops",{})) == TYPE_DICTIONARY:
		LiveOpsRankingSystem.apply_save_data(domains.get("liveops",{}))

	PlayerData.stats_changed.emit()
	PlayerData.progression_changed.emit()
	PlayerData.monster_changed.emit()
	remote_state_applied.emit(revision)
	return {"ok":true,"revision":revision}
