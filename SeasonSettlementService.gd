extends Node

signal settlement_changed
signal settlement_claim_result(result: Dictionary)

const CONTRACT_VERSION := "season-settlement-v1"

var settlement: Dictionary = {}
var settlement_revision: int = 0

func request_settlement() -> Dictionary:
	return _post("pvp_season_settlement",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_season_settlement")
	})

func claim() -> Dictionary:
	var settlement_id := str(settlement.get("settlement_id",""))
	var claim_id := str(settlement.get("claim_id",""))
	if settlement_id.is_empty() or claim_id.is_empty():
		return {"ok":false,"error_code":"NO_SEASON_SETTLEMENT"}
	if str(settlement.get("state","")) != "claimable":
		return {"ok":false,"error_code":"SETTLEMENT_NOT_CLAIMABLE"}
	return _post("pvp_season_claim",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_season_claim"),
		"settlement_id":settlement_id,
		"claim_id":claim_id,
		"expected_revision":settlement_revision
	})

func accept_settlement(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < settlement_revision:
		return false
	var incoming = envelope.get("settlement",{})
	if typeof(incoming) != TYPE_DICTIONARY:
		return false
	var state := str(incoming.get("state","pending"))
	if state not in ["pending","claimable","claimed","expired"]:
		state = "pending"
	settlement = {
		"settlement_id":str(incoming.get("settlement_id","")),
		"season_id":str(incoming.get("season_id","")),
		"final_league":str(incoming.get("final_league","")),
		"final_rank":maxi(int(incoming.get("final_rank",0)),0),
		"final_rating":maxi(int(incoming.get("final_rating",0)),0),
		"reward_preview":Dictionary(incoming.get("reward_preview",{})).duplicate(true),
		"claim_id":str(incoming.get("claim_id","")),
		"state":state,
		"settled_unix":maxi(int(incoming.get("settled_unix",0)),0)
	}
	settlement_revision = revision
	settlement_changed.emit()
	return true

func accept_claim(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		settlement_claim_result.emit(envelope)
		return false
	var claim_id := str(envelope.get("claim_id",""))
	if claim_id.is_empty():
		return false
	# Final reward delivery is delegated to the central RewardLedgerService.
	var accepted := RewardLedgerService.accept_claim_envelope(envelope)
	if accepted:
		settlement["state"] = "claimed"
		settlement_revision = maxi(int(envelope.get("revision",settlement_revision)),settlement_revision)
		settlement_changed.emit()
	settlement_claim_result.emit(envelope)
	return accepted

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
