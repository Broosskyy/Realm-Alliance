extends Node

signal party_changed
signal party_action_result(result: Dictionary)

const CONTRACT_VERSION := "party-lobby-v1"

var party: Dictionary = {}
var party_revision: int = 0

func has_party() -> bool:
	return not str(party.get("party_id","")).is_empty()

func request_snapshot() -> Dictionary:
	return _post("party_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_snapshot"),
		"party_id":str(party.get("party_id",""))
	})

func create(activity_type: String) -> Dictionary:
	if activity_type not in ["guild_boss","coop_event","journey_coop"]:
		return {"ok":false,"error_code":"INVALID_PARTY_ACTIVITY"}
	return _post("party_create",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_create"),
		"activity_type":activity_type
	})

func invite(player_id: String) -> Dictionary:
	if not has_party() or player_id.is_empty():
		return {"ok":false,"error_code":"INVALID_PARTY_INVITE"}
	return _post("party_invite",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_invite"),
		"party_id":str(party.get("party_id","")),
		"target_player_id":player_id,
		"expected_revision":party_revision
	})

func join(invite_token: String) -> Dictionary:
	if invite_token.is_empty():
		return {"ok":false,"error_code":"MISSING_INVITE_TOKEN"}
	return _post("party_join",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_join"),
		"invite_token":invite_token
	})

func leave() -> Dictionary:
	if not has_party():
		return {"ok":false,"error_code":"NO_PARTY"}
	return _post("party_leave",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_leave"),
		"party_id":str(party.get("party_id","")),
		"expected_revision":party_revision
	})

func set_ready(ready: bool) -> Dictionary:
	if not has_party():
		return {"ok":false,"error_code":"NO_PARTY"}
	return _post("party_ready",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("party_ready"),
		"party_id":str(party.get("party_id","")),
		"ready":ready,
		"expected_revision":party_revision
	})

func accept_party_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",true)):
		party_action_result.emit(envelope)
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < party_revision:
		return false
	var incoming = envelope.get("party",{})
	if typeof(incoming) != TYPE_DICTIONARY:
		return false
	party = _sanitize_party(incoming)
	party_revision = revision
	party_changed.emit()
	party_action_result.emit(envelope)
	return true

func accept_leave_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		party_action_result.emit(envelope)
		return false
	party = {}
	party_revision = maxi(int(envelope.get("revision",party_revision)),party_revision)
	party_changed.emit()
	party_action_result.emit(envelope)
	return true

func _sanitize_party(incoming: Dictionary) -> Dictionary:
	var members: Array[Dictionary] = []
	for item in incoming.get("members",[]):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var player_id := str(item.get("player_id",""))
		if player_id.is_empty():
			continue
		members.append({
			"player_id":player_id,
			"display_name":str(item.get("display_name","Spieler")).left(24),
			"ready":bool(item.get("ready",false)),
			"leader":bool(item.get("leader",false))
		})
	return {
		"party_id":str(incoming.get("party_id","")),
		"activity_type":str(incoming.get("activity_type","")),
		"state":str(incoming.get("state","forming")),
		"members":members,
		"max_members":clampi(int(incoming.get("max_members",4)),1,8),
		"invite_token":str(incoming.get("invite_token",""))
	}

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
