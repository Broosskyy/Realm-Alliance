extends Node

const CONTRACT_VERSION := "player-snapshot-v3"

func build_local_snapshot() -> Dictionary:
	return {
		"contract_version":CONTRACT_VERSION,
		"revision":OnlineAuthorityService.server_revision,
		"server_unix":ServerClockService.now_unix(),
		"economy":{
			"gold":PlayerData.gold,
			"gems":PlayerData.gems,
			"spins":PlayerData.spins,
			"shields":PlayerData.shields
		},
		"progression":{
			"player_level":PlayerData.player_level,
			"player_xp":PlayerData.player_xp,
			"tap_level":PlayerData.tap_level,
			"tap_damage":PlayerData.tap_damage,
			"monster_level":PlayerData.monster_level,
			"monster_max_hp":PlayerData.monster_max_hp,
			"current_monster_hp":PlayerData.current_monster_hp,
			"village_level":PlayerData.village_level,
			"daily_streak":PlayerData.daily_streak,
			"last_daily_claim_unix":PlayerData.last_daily_claim_unix
		},
		"account":AccountState.export_save_data(),
		"domains":{
			"heroes":HeroSystem.export_save_data(),
			"village":P0VillageSystem.export_save_data(),
			"village_progression":VillageProgressionSystem.export_save_data(),
			"journey_progression":JourneyProgressionSystem.export_save_data(),
			"puzzle_progression":PuzzleProgressionSystem.export_save_data(),
			"tower_defense_progression":TowerDefenseProgressionSystem.export_save_data(),
			"lane_battle_progression":LaneBattleProgressionSystem.export_save_data(),
			"hero_progression":HeroProgressionSystem.export_save_data(),
			"meta_progress":MetaProgressSystem.export_save_data(),
			"liveops":LiveOpsRankingSystem.export_save_data()
		}
	}

func snapshot_fingerprint(snapshot: Dictionary) -> String:
	var serialized := JSON.stringify(snapshot)
	return str(hash(serialized))

func sync_metadata() -> Dictionary:
	var snapshot := build_local_snapshot()
	return {
		"contract_version":CONTRACT_VERSION,
		"revision":OnlineAuthorityService.server_revision,
		"server_unix":ServerClockService.now_unix(),
		"fingerprint":snapshot_fingerprint(snapshot),
		"pending_intent_count":OnlineAuthorityService.pending_intents.size()
	}


func build_sync_request() -> Dictionary:
	var snapshot := build_local_snapshot()
	return {
		"contract_version":"player-sync-request-v1",
		"client_build":BuildInfo.SOURCE_VERSION,
		"known_revision":OnlineAuthorityService.server_revision,
		"snapshot_fingerprint":snapshot_fingerprint(snapshot),
		"pending_intents":OnlineAuthorityService.pending_intents.duplicate(true),
		"client_snapshot":snapshot
	}

func validate_remote_envelope(envelope: Dictionary) -> Dictionary:
	if envelope.is_empty():
		return {"ok":false,"error_code":"EMPTY_ENVELOPE"}
	var revision := int(envelope.get("revision",-1))
	if revision < 0:
		return {"ok":false,"error_code":"MISSING_REVISION"}
	if revision < OnlineAuthorityService.server_revision:
		return {"ok":false,"error_code":"STALE_REVISION","remote_revision":revision,"local_revision":OnlineAuthorityService.server_revision}
	if not envelope.has("server_unix"):
		return {"ok":false,"error_code":"MISSING_SERVER_TIME"}
	return {"ok":true,"revision":revision,"server_unix":int(envelope.get("server_unix",0))}


func normalize_remote_snapshot(snapshot: Dictionary) -> Dictionary:
	if typeof(snapshot) != TYPE_DICTIONARY:
		return {"ok":false,"error_code":"INVALID_SNAPSHOT"}
	var economy = snapshot.get("economy",{})
	var progression = snapshot.get("progression",{})
	var domains = snapshot.get("domains",{})
	if typeof(economy) != TYPE_DICTIONARY or typeof(progression) != TYPE_DICTIONARY or typeof(domains) != TYPE_DICTIONARY:
		return {"ok":false,"error_code":"INVALID_SNAPSHOT_SHAPE"}

	var normalized := snapshot.duplicate(true)
	normalized["economy"] = {
		"gold":maxi(int(economy.get("gold",0)),0),
		"gems":maxi(int(economy.get("gems",0)),0),
		"spins":maxi(int(economy.get("spins",0)),0),
		"shields":clampi(int(economy.get("shields",0)),0,GameConfig.MAX_SHIELDS)
	}
	var monster_level := maxi(int(progression.get("monster_level",1)),1)
	var monster_max_hp := maxi(int(progression.get("monster_max_hp",GameConfig.effective_monster_hp(monster_level))),1)
	normalized["progression"] = {
		"player_level":maxi(int(progression.get("player_level",1)),1),
		"player_xp":maxi(int(progression.get("player_xp",0)),0),
		"tap_level":maxi(int(progression.get("tap_level",1)),1),
		"tap_damage":maxi(int(progression.get("tap_damage",1)),1),
		"monster_level":monster_level,
		"monster_max_hp":monster_max_hp,
		"current_monster_hp":clampi(int(progression.get("current_monster_hp",monster_max_hp)),0,monster_max_hp),
		"village_level":maxi(int(progression.get("village_level",1)),1),
		"daily_streak":maxi(int(progression.get("daily_streak",0)),0),
		"last_daily_claim_unix":maxi(int(progression.get("last_daily_claim_unix",0)),0)
	}
	return {"ok":true,"snapshot":normalized}
