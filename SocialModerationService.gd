extends Node
signal block_list_changed
signal moderation_action_result(result: Dictionary)
const CONTRACT_VERSION := "social-moderation-v1"
var blocked_player_ids: Array[String] = []
var moderation_revision: int = 0
func request_block_list() -> Dictionary:
	return _post("social_block_list",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("block_list")})
func block_player(player_id: String) -> Dictionary:
	if player_id.is_empty(): return {"ok":false,"error_code":"MISSING_PLAYER_ID"}
	return _post("social_block",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("block_player"),"player_id":player_id,"expected_revision":moderation_revision})
func unblock_player(player_id: String) -> Dictionary:
	if player_id.is_empty(): return {"ok":false,"error_code":"MISSING_PLAYER_ID"}
	return _post("social_unblock",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("unblock_player"),"player_id":player_id,"expected_revision":moderation_revision})
func report_player(player_id: String, reason_code: String, context: String = "") -> Dictionary:
	if player_id.is_empty() or reason_code.is_empty(): return {"ok":false,"error_code":"INVALID_REPORT"}
	return _post("social_report",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("report_player"),"player_id":player_id,"reason_code":reason_code.left(48),"context":context.left(240)})
func is_blocked(player_id: String) -> bool: return blocked_player_ids.has(player_id)
func accept_block_list_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1));
	if revision < moderation_revision: return false
	var incoming = envelope.get("blocked_player_ids",[])
	if typeof(incoming) != TYPE_ARRAY: return false
	blocked_player_ids.clear()
	for item in incoming:
		var player_id := str(item)
		if not player_id.is_empty() and not blocked_player_ids.has(player_id): blocked_player_ids.append(player_id)
	moderation_revision=revision; block_list_changed.emit(); return true
func accept_action_envelope(envelope: Dictionary) -> bool:
	moderation_action_result.emit(envelope)
	if not bool(envelope.get("ok",false)): return false
	if envelope.has("blocked_player_ids"): return accept_block_list_envelope(envelope)
	return true
func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated(): return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready(): return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
