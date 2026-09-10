extends Node
signal season_reset_changed
signal season_reset_acknowledged
const CONTRACT_VERSION := "season-reset-v1"
var reset_snapshot: Dictionary = {}
var reset_revision: int = 0
func request_snapshot() -> Dictionary:
	return _post("season_reset_snapshot",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("season_reset_snapshot")})
func acknowledge(reset_id: String) -> Dictionary:
	if reset_id.is_empty(): return {"ok":false,"error_code":"MISSING_RESET_ID"}
	return _post("season_reset_ack",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("season_reset_ack"),"reset_id":reset_id,"expected_revision":reset_revision})
func accept_snapshot_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1));
	if revision < reset_revision: return false
	var reset=envelope.get("reset",{})
	if typeof(reset) != TYPE_DICTIONARY: return false
	reset_snapshot={"reset_id":str(reset.get("reset_id","")),"season_id":str(reset.get("season_id","")),"previous_league":str(reset.get("previous_league","")),"next_league":str(reset.get("next_league","")),"previous_rating":maxi(int(reset.get("previous_rating",0)),0),"next_rating":maxi(int(reset.get("next_rating",0)),0),"settled_unix":maxi(int(reset.get("settled_unix",0)),0),"reward_claim_ids":Array(reset.get("reward_claim_ids",[])).duplicate()}
	reset_revision=revision; season_reset_changed.emit(); return true
func accept_ack_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)): return false
	reset_revision=maxi(int(envelope.get("revision",reset_revision)),reset_revision); season_reset_acknowledged.emit(); return true
func claimable_reward_ids() -> Array[String]:
	var ids: Array[String]=[]
	for item in reset_snapshot.get("reward_claim_ids",[]):
		var claim_id:=str(item)
		if not claim_id.is_empty(): ids.append(claim_id)
	return ids
func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated(): return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready(): return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
