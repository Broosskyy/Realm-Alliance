extends Node

signal ledger_changed
signal reward_claim_completed(result: Dictionary)

const CONTRACT_VERSION := "reward-ledger-v1"

var entries: Dictionary = {}
var ledger_revision: int = 0
var pending_claim_ids: Dictionary = {}

func request_ledger() -> Dictionary:
	return _post("reward_ledger_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("reward_ledger")
	})

func claim(claim_id: String) -> Dictionary:
	if claim_id.is_empty():
		return {"ok":false,"error_code":"MISSING_CLAIM_ID"}
	if pending_claim_ids.has(claim_id):
		return {"ok":false,"error_code":"CLAIM_ALREADY_PENDING"}
	var entry: Dictionary = entries.get(claim_id,{})
	if entry.is_empty():
		return {"ok":false,"error_code":"UNKNOWN_CLAIM"}
	if str(entry.get("state","")) == "claimed":
		return {"ok":false,"error_code":"ALREADY_CLAIMED"}
	pending_claim_ids[claim_id] = true
	var result := _post("reward_claim",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("reward_claim"),
		"claim_id":claim_id,
		"expected_revision":ledger_revision
	})
	if not bool(result.get("ok",false)):
		pending_claim_ids.erase(claim_id)
	return result

func accept_ledger_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < ledger_revision:
		return false
	var incoming = envelope.get("entries",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	var normalized: Dictionary = {}
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var claim_id := str(item.get("claim_id",""))
		if claim_id.is_empty():
			continue
		normalized[claim_id] = _sanitize_entry(item)
	entries = normalized
	ledger_revision = revision
	ledger_changed.emit()
	return true

func accept_claim_envelope(envelope: Dictionary) -> bool:
	var claim_id := str(envelope.get("claim_id",""))
	if claim_id.is_empty():
		return false
	pending_claim_ids.erase(claim_id)
	if not bool(envelope.get("ok",false)):
		reward_claim_completed.emit(envelope)
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < ledger_revision:
		return false

	var reward = envelope.get("reward",{})
	var economy = envelope.get("economy",{})
	if typeof(reward) != TYPE_DICTIONARY:
		return false
	if typeof(economy) == TYPE_DICTIONARY and not economy.is_empty():
		if not _apply_economy_snapshot(economy):
			return false

	var entry: Dictionary = entries.get(claim_id,{
		"claim_id":claim_id,
		"source":str(envelope.get("source","")),
		"reward":reward.duplicate(true)
	})
	entry["state"] = "claimed"
	entry["claimed_unix"] = maxi(int(envelope.get("server_unix",0)),0)
	entry["reward"] = reward.duplicate(true)
	entries[claim_id] = entry
	ledger_revision = revision
	ledger_changed.emit()
	reward_claim_completed.emit(envelope)
	return true

func available_claims(source_prefix: String = "") -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for claim_id in entries.keys():
		var entry: Dictionary = entries[claim_id]
		if str(entry.get("state","")) != "claimable":
			continue
		if not source_prefix.is_empty() and not str(entry.get("source","")).begins_with(source_prefix):
			continue
		rows.append(entry.duplicate(true))
	return rows

func _sanitize_entry(item: Dictionary) -> Dictionary:
	var state := str(item.get("state","locked"))
	if state not in ["locked","claimable","claimed","expired"]:
		state = "locked"
	return {
		"claim_id":str(item.get("claim_id","")),
		"source":str(item.get("source","")),
		"state":state,
		"reward":Dictionary(item.get("reward",{})).duplicate(true),
		"available_unix":maxi(int(item.get("available_unix",0)),0),
		"expires_unix":maxi(int(item.get("expires_unix",0)),0),
		"claimed_unix":maxi(int(item.get("claimed_unix",0)),0)
	}

func _apply_economy_snapshot(economy: Dictionary) -> bool:
	for key in ["gold","gems","spins","shields"]:
		if not economy.has(key):
			return false
	PlayerData.gold = maxi(int(economy.get("gold",0)),0)
	PlayerData.gems = maxi(int(economy.get("gems",0)),0)
	PlayerData.spins = maxi(int(economy.get("spins",0)),0)
	PlayerData.shields = clampi(int(economy.get("shields",0)),0,GameConfig.MAX_SHIELDS)
	PlayerData.stats_changed.emit()
	return true

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
