extends Node

signal friends_changed
signal social_request_completed(result: Dictionary)

const CONTRACT_VERSION := "social-service-v1"
var friends: Array[Dictionary] = []
var incoming_requests: Array[Dictionary] = []
var outgoing_requests: Array[Dictionary] = []
var last_server_revision: int = 0

func request_friends() -> Dictionary:
	return _post_route("friends_list",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("friends_list")
	})

func send_friend_request(target_player_id: String) -> Dictionary:
	if target_player_id.is_empty():
		return {"ok":false,"error_code":"MISSING_TARGET_PLAYER"}
	return _post_route("friend_request",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("friend_request"),
		"target_player_id":target_player_id
	})

func accept_friend_request(request_id_value: String) -> Dictionary:
	if request_id_value.is_empty():
		return {"ok":false,"error_code":"MISSING_FRIEND_REQUEST_ID"}
	return _post_route("friend_accept",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("friend_accept"),
		"friend_request_id":request_id_value
	})

func _post_route(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func accept_friends_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < last_server_revision:
		return false
	var incoming = envelope.get("friends",[])
	var requests_in = envelope.get("incoming_requests",[])
	var requests_out = envelope.get("outgoing_requests",[])
	if typeof(incoming) != TYPE_ARRAY or typeof(requests_in) != TYPE_ARRAY or typeof(requests_out) != TYPE_ARRAY:
		return false
	friends.clear()
	for item in incoming:
		if typeof(item) == TYPE_DICTIONARY:
			friends.append(_sanitize_person(item))
	incoming_requests.clear()
	for item in requests_in:
		if typeof(item) == TYPE_DICTIONARY:
			incoming_requests.append(_sanitize_request(item))
	outgoing_requests.clear()
	for item in requests_out:
		if typeof(item) == TYPE_DICTIONARY:
			outgoing_requests.append(_sanitize_request(item))
	last_server_revision = revision
	friends_changed.emit()
	return true

func accept_social_mutation_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",true)):
		return false
	social_request_completed.emit(envelope)
	if envelope.has("friends"):
		return accept_friends_envelope(envelope)
	return true

func _sanitize_person(item: Dictionary) -> Dictionary:
	return {
		"player_id":str(item.get("player_id","")),
		"display_name":str(item.get("display_name","Spieler")).left(24),
		"level":maxi(int(item.get("level",1)),1),
		"online":bool(item.get("online",false)),
		"last_seen_unix":maxi(int(item.get("last_seen_unix",0)),0)
	}

func _sanitize_request(item: Dictionary) -> Dictionary:
	return {
		"request_id":str(item.get("request_id","")),
		"player_id":str(item.get("player_id","")),
		"display_name":str(item.get("display_name","Spieler")).left(24),
		"created_unix":maxi(int(item.get("created_unix",0)),0)
	}

func snapshot() -> Dictionary:
	return {
		"friends":friends.duplicate(true),
		"incoming_requests":incoming_requests.duplicate(true),
		"outgoing_requests":outgoing_requests.duplicate(true),
		"revision":last_server_revision
	}
