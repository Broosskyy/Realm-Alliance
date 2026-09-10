extends Node

signal auth_state_changed(state: String)
signal session_descriptor_changed

const CONTRACT_VERSION := "auth-session-v1"
const SIGNED_OUT := "signed_out"
const GUEST_LOCAL := "guest_local"
const AUTHENTICATING := "authenticating"
const AUTHENTICATED := "authenticated"
const REFRESH_REQUIRED := "refresh_required"

var state: String = GUEST_LOCAL
var server_player_id: String = ""
var session_id: String = ""
var access_token: String = ""
var refresh_token: String = ""
var token_expires_unix: int = 0
var provider: String = "local"
var last_auth_unix: int = 0

func is_authenticated() -> bool:
	return state == AUTHENTICATED and not access_token.is_empty()

func auth_header() -> PackedStringArray:
	if not is_authenticated():
		return PackedStringArray()
	return PackedStringArray(["Authorization: Bearer %s" % access_token])

func begin_guest_session() -> Dictionary:
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("session_guest","/v1/session/guest"))
	if not OnlineTransportService.is_ready():
		state = GUEST_LOCAL
		auth_state_changed.emit(state)
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED","local_guest_active":true}
	state = AUTHENTICATING
	auth_state_changed.emit(state)
	var payload := {
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guest_session"),
		"client_build":BuildInfo.SOURCE_VERSION,
		"display_name":AccountState.display_name
	}
	return OnlineTransportService.post_json(route,payload)

func accept_session_envelope(envelope: Dictionary) -> Dictionary:
	var player_id := str(envelope.get("player_id",""))
	var incoming_session_id := str(envelope.get("session_id",""))
	var incoming_access := str(envelope.get("access_token",""))
	var expires := int(envelope.get("expires_unix",0))
	if player_id.is_empty() or incoming_session_id.is_empty() or incoming_access.is_empty() or expires <= ServerClockService.now_unix():
		return {"ok":false,"error_code":"INVALID_SESSION_ENVELOPE"}

	server_player_id = player_id
	session_id = incoming_session_id
	access_token = incoming_access
	refresh_token = str(envelope.get("refresh_token",""))
	token_expires_unix = expires
	provider = str(envelope.get("provider","guest"))
	last_auth_unix = ServerClockService.now_unix()
	state = AUTHENTICATED
	AccountState.mark_online_account(server_player_id,provider)
	OnlineSessionState.set_state(OnlineSessionState.CONNECTING)
	auth_state_changed.emit(state)
	session_descriptor_changed.emit()
	return {"ok":true,"player_id":server_player_id,"expires_unix":token_expires_unix}

func clear_runtime_tokens() -> void:
	access_token = ""
	refresh_token = ""
	token_expires_unix = 0
	session_id = ""
	state = GUEST_LOCAL if AccountState.is_guest() else SIGNED_OUT
	auth_state_changed.emit(state)

func session_descriptor() -> Dictionary:
	# Deliberately excludes access/refresh tokens. Secrets are runtime-only.
	return {
		"contract_version":CONTRACT_VERSION,
		"state":state,
		"server_player_id":server_player_id,
		"provider":provider,
		"last_auth_unix":last_auth_unix
	}

func apply_session_descriptor(data: Dictionary) -> void:
	server_player_id = str(data.get("server_player_id",""))
	provider = str(data.get("provider","local"))
	last_auth_unix = maxi(int(data.get("last_auth_unix",0)),0)
	access_token = ""
	refresh_token = ""
	token_expires_unix = 0
	session_id = ""
	state = REFRESH_REQUIRED if not server_player_id.is_empty() else GUEST_LOCAL
	auth_state_changed.emit(state)


func require_refresh() -> void:
	access_token = ""
	token_expires_unix = 0
	state = REFRESH_REQUIRED if not server_player_id.is_empty() else SIGNED_OUT
	OnlineSessionState.set_state(OnlineSessionState.CONNECTING)
	auth_state_changed.emit(state)

func begin_refresh_session() -> Dictionary:
	if server_player_id.is_empty() or refresh_token.is_empty():
		return {"ok":false,"error_code":"REFRESH_TOKEN_UNAVAILABLE"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	state = AUTHENTICATING
	auth_state_changed.emit(state)
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("session_refresh","/v1/session/refresh"))
	return OnlineTransportService.post_json(route,{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("session_refresh"),
		"player_id":server_player_id,
		"refresh_token":refresh_token,
		"client_build":BuildInfo.SOURCE_VERSION
	})
