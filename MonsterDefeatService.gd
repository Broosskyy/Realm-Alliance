extends Node

signal defeat_committed(result: Dictionary)

const CONFIG_VERSION := "v1.81-monster-defeat-remote-authority-01"

var transaction_active: bool = false
var defeat_sequence: int = 0

func _ready() -> void:
	if not RemoteGameplayService.combat_result_received.is_connected(_on_remote_combat_result):
		RemoteGameplayService.combat_result_received.connect(_on_remote_combat_result)

func _on_remote_combat_result(result: Dictionary) -> void:
	transaction_active = false
	defeat_committed.emit(result)

func commit_defeat(source: String) -> Dictionary:
	if transaction_active:
		return {"ok":false,"message":"Defeat transaction already active"}
	if PlayerData.current_monster_hp > 0:
		return {"ok":false,"message":"Monster is not defeated"}

	transaction_active = true
	defeat_sequence += 1

	var defeated_level := PlayerData.monster_level
	var defeated_id := P0MonsterVisualSystem.production_asset_id(defeated_level)
	var boss_defeated := P0MonsterVisualSystem.is_boss(defeated_level)

	if OnlineAuthorityService.mode == "online":
		var remote_started := RemoteGameplayService.request_monster_defeat(
			source,defeated_level,defeated_id,boss_defeated
		)
		if not bool(remote_started.get("ok",false)):
			transaction_active = false
			return {
				"ok":false,
				"message":"Kampfergebnis konnte nicht online bestätigt werden",
				"error_code":str(remote_started.get("error_code","REMOTE_COMBAT_FAILED"))
			}
		return {
			"ok":true,
			"pending":true,
			"source":source,
			"defeated_level":defeated_level,
			"encounter_id":defeated_id,
			"boss":boss_defeated,
			"authority":"server_pending",
			"authority_request_id":str(remote_started.get("request_id",""))
		}

	var authority_intent := OnlineAuthorityService.build_intent("monster_defeat", {
		"source":source,
		"monster_level":PlayerData.monster_level,
		"encounter_id":P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level)
	})

	var defeat_id := "defeat_%d_%d_%d" % [
		ServerClockService.now_unix(),
		defeated_level,
		defeat_sequence
	]

	# Authoritative reward booking happens exactly once inside this boundary.
	var reward := PlayerData.reward_monster_kill()

	var boss_bonus_spins := 0
	var boss_bonus_dice := 0
	if boss_defeated:
		boss_bonus_spins = 2
		PlayerData.add_spin(boss_bonus_spins)
		if FeatureFlags.SHOW_DICE:
			boss_bonus_dice = int(DiceJourneySystem.config.get("boss_bonus_dice",1))
			DiceJourneySystem.grant_dice(boss_bonus_dice)
		if FeatureFlags.SHOW_EVENTS or FeatureFlags.SHOW_RANKINGS or FeatureFlags.SHOW_REALM_CHEST:
			MetaProgressSystem.register_boss_defeat()
		LiveOpsRankingSystem.register_boss_defeat()

	var next_level := defeated_level + 1
	PlayerData.spawn_next_monster()

	var result := {
		"ok":true,
		"defeat_id":defeat_id,
		"source":source,
		"config_version":CONFIG_VERSION,
		"authority_request_id":str(authority_intent.get("request_id","")),
		"authority_revision_before":OnlineAuthorityService.server_revision,
		"defeated_level":defeated_level,
		"encounter_id":defeated_id,
		"boss":boss_defeated,
		"reward":reward.duplicate(true),
		"reward_gold":int(reward.get("gold",0)),
		"bonus_spin":bool(reward.get("bonus_spin",false)),
		"boss_bonus_spins":boss_bonus_spins,
		"boss_bonus_dice":boss_bonus_dice,
		"next_level":next_level
	}

	var authority_result := OnlineAuthorityService.local_result(authority_intent, {
		"monster_level":PlayerData.monster_level,
		"gold":PlayerData.gold,
		"spins":PlayerData.spins,
		"player_level":PlayerData.player_level
	}, {"defeat_id":defeat_id,"boss":boss_defeated,"reward_gold":int(result.reward_gold)})
	result["authority_revision_after"] = int(authority_result.get("revision",0))
	result["authority"] = str(authority_result.get("authority","local_development"))

	# Save before any UI/VFX presentation. After this point the old defeated
	# monster can never be rewarded again on resume.
	SaveGame.save_game()

	CoreAnalytics.log_event("monster_defeat", {
		"defeat_id":defeat_id,
		"source":source,
		"monster_level":defeated_level,
		"encounter_id":defeated_id,
		"boss":boss_defeated,
		"reward_gold":int(result.reward_gold),
		"next_level":next_level,
		"config_version":CONFIG_VERSION
	})
	CoreAnalytics.log_event("monster_transaction_committed", {
		"defeat_id":defeat_id,
		"source":source,
		"defeated_level":defeated_level,
		"next_level":next_level,
		"boss":boss_defeated,
		"config_version":CONFIG_VERSION
	})

	transaction_active = false
	defeat_committed.emit(result)
	return result
