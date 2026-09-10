extends Node

signal economy_transaction_committed(result: Dictionary)

const CONTRACT_VERSION := "economy-transaction-v1"

func _can_local_commit() -> bool:
	return OnlineAuthorityService.mode == "local_development"

func commit_spin_local(intent: Dictionary, reward: Dictionary) -> Dictionary:
	if not _can_local_commit():
		return OnlineAuthorityService.rejected_result(intent, "ONLINE_AUTHORITY_REQUIRED", "Aktion muss online bestätigt werden", true)
	var request_id := str(intent.get("request_id",""))
	if OnlineAuthorityService.has_resolved_request(request_id):
		return {"ok":false,"error_code":"DUPLICATE_REQUEST","request_id":request_id}
	if PlayerData.spins <= 0:
		return OnlineAuthorityService.rejected_result(intent, "INSUFFICIENT_SPINS", "Keine Spins verfügbar", false)

	OnlineAuthorityService.register_pending_intent(intent)
	PlayerData.spins -= 1

	var reward_type := str(reward.get("reward_type","none"))
	var amount := maxi(int(reward.get("reward_value",0)),0)
	match reward_type:
		"gold", "gold_fallback", "special_gold":
			PlayerData.gold += amount
		"shield":
			PlayerData.shields = mini(PlayerData.shields + amount, GameConfig.MAX_SHIELDS)
		"spins":
			PlayerData.spins += amount
	PlayerData.stats_changed.emit()

	var changes := {
		"gold":PlayerData.gold,
		"gems":PlayerData.gems,
		"spins":PlayerData.spins,
		"shields":PlayerData.shields
	}
	var presentation := reward.duplicate(true)
	var authority_result := OnlineAuthorityService.local_result(intent, changes, presentation)
	var result := {
		"ok":bool(authority_result.get("ok",false)),
		"contract_version":CONTRACT_VERSION,
		"request_id":request_id,
		"revision":int(authority_result.get("revision",0)),
		"changes":changes
	}
	economy_transaction_committed.emit(result)
	return result

func build_currency_intent(operation: String, currency: String, amount: int, context: Dictionary = {}) -> Dictionary:
	var payload := context.duplicate(true)
	payload["currency"] = currency
	payload["amount"] = amount
	return OnlineAuthorityService.build_intent(operation, payload)


func commit_gold_spend_local(intent: Dictionary, cost: int, domain_changes: Dictionary = {}) -> Dictionary:
	if not _can_local_commit():
		return OnlineAuthorityService.rejected_result(intent, "ONLINE_AUTHORITY_REQUIRED", "Aktion muss online bestätigt werden", true)
	var request_id := str(intent.get("request_id",""))
	if OnlineAuthorityService.has_resolved_request(request_id):
		return {"ok":false,"error_code":"DUPLICATE_REQUEST","request_id":request_id}
	var safe_cost := maxi(cost,0)
	if PlayerData.gold < safe_cost:
		return OnlineAuthorityService.rejected_result(intent, "INSUFFICIENT_GOLD", "Nicht genug Gold", false)

	OnlineAuthorityService.register_pending_intent(intent)
	PlayerData.gold -= safe_cost
	PlayerData.stats_changed.emit()
	var changes := {
		"gold":PlayerData.gold,
		"gems":PlayerData.gems,
		"spins":PlayerData.spins,
		"shields":PlayerData.shields,
		"domain":domain_changes.duplicate(true)
	}
	var authority_result := OnlineAuthorityService.local_result(intent, changes, {})
	var result := {
		"ok":bool(authority_result.get("ok",false)),
		"request_id":request_id,
		"revision":int(authority_result.get("revision",0)),
		"cost":safe_cost,
		"changes":changes
	}
	economy_transaction_committed.emit(result)
	return result

func commit_reward_local(intent: Dictionary, reward: Dictionary, domain_changes: Dictionary = {}) -> Dictionary:
	if not _can_local_commit():
		return OnlineAuthorityService.rejected_result(intent, "ONLINE_AUTHORITY_REQUIRED", "Belohnung muss online bestätigt werden", true)
	var request_id := str(intent.get("request_id",""))
	if OnlineAuthorityService.has_resolved_request(request_id):
		return {"ok":false,"error_code":"DUPLICATE_REQUEST","request_id":request_id}

	OnlineAuthorityService.register_pending_intent(intent)
	var gold := maxi(int(reward.get("gold",0)),0)
	var gems := maxi(int(reward.get("gems",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var shields := maxi(int(reward.get("shields",0)),0)
	var realm_keys := maxi(int(reward.get("realm_keys",0)),0)

	PlayerData.gold += gold
	PlayerData.gems += gems
	PlayerData.spins += spins
	PlayerData.shields = mini(PlayerData.shields + shields, GameConfig.MAX_SHIELDS)
	if realm_keys > 0:
		MetaProgressSystem.grant_realm_keys(realm_keys)
	PlayerData.stats_changed.emit()

	var changes := {
		"gold":PlayerData.gold,
		"gems":PlayerData.gems,
		"spins":PlayerData.spins,
		"shields":PlayerData.shields,
		"realm_keys":MetaProgressSystem.realm_keys,
		"domain":domain_changes.duplicate(true)
	}
	var authority_result := OnlineAuthorityService.local_result(intent, changes, reward)
	var result := {
		"ok":bool(authority_result.get("ok",false)),
		"request_id":request_id,
		"revision":int(authority_result.get("revision",0)),
		"reward":reward.duplicate(true),
		"changes":changes
	}
	economy_transaction_committed.emit(result)
	return result


func commit_domain_state_local(intent: Dictionary, domain_changes: Dictionary, presentation: Dictionary = {}) -> Dictionary:
	if not _can_local_commit():
		return OnlineAuthorityService.rejected_result(intent, "ONLINE_AUTHORITY_REQUIRED", "Aktion muss online bestätigt werden", true)
	var request_id := str(intent.get("request_id",""))
	if OnlineAuthorityService.has_resolved_request(request_id):
		return {"ok":false,"error_code":"DUPLICATE_REQUEST","request_id":request_id}
	OnlineAuthorityService.register_pending_intent(intent)
	var authority_result := OnlineAuthorityService.local_result(
		intent,
		{"domain":domain_changes.duplicate(true)},
		presentation
	)
	var result := {
		"ok":bool(authority_result.get("ok",false)),
		"request_id":request_id,
		"revision":int(authority_result.get("revision",0)),
		"changes":domain_changes.duplicate(true)
	}
	economy_transaction_committed.emit(result)
	return result
