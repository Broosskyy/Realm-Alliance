extends Node

signal deeplink_resolved(result: Dictionary)

const CONTRACT_VERSION := "invite-deeplink-v1"
const ALLOWED_TARGETS := ["guild_invite","party_invite","friend_invite","event","ranking"]

var last_resolution: Dictionary = {}

func resolve(raw_link: String) -> Dictionary:
	var parsed := _parse_local(raw_link)
	if not bool(parsed.get("ok",false)):
		return parsed
	var token := str(parsed.get("token",""))
	var target := str(parsed.get("target",""))
	if token.is_empty() or target not in ALLOWED_TARGETS:
		return {"ok":false,"error_code":"DEEPLINK_NOT_ALLOWED"}
	return _post("deeplink_resolve",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("deeplink_resolve"),
		"target":target,
		"token":token
	})

func accept_resolve_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		deeplink_resolved.emit(envelope)
		return false
	var target := str(envelope.get("target",""))
	if target not in ALLOWED_TARGETS:
		return false
	last_resolution = {
		"target":target,
		"token_id":str(envelope.get("token_id","")),
		"expires_unix":maxi(int(envelope.get("expires_unix",0)),0),
		"payload":Dictionary(envelope.get("payload",{})).duplicate(true)
	}
	deeplink_resolved.emit(last_resolution)
	return true

func _parse_local(raw_link: String) -> Dictionary:
	var clean := raw_link.strip_edges()
	if clean.length() > 512:
		return {"ok":false,"error_code":"DEEPLINK_TOO_LONG"}
	var prefix := "realmalliance://"
	if not clean.begins_with(prefix):
		return {"ok":false,"error_code":"INVALID_DEEPLINK_SCHEME"}
	var body := clean.trim_prefix(prefix)
	var parts := body.split("/",false)
	if parts.size() < 2:
		return {"ok":false,"error_code":"INVALID_DEEPLINK_FORMAT"}
	return {"ok":true,"target":str(parts[0]),"token":str(parts[1]).left(256)}

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
