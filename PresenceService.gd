extends Node

signal presence_changed

const CONTRACT_VERSION := "presence-v1"

var own_presence: Dictionary = {}
var player_presence: Dictionary = {}
var presence_revision: int = 0

func request_snapshot() -> Dictionary:
	return _post("presence_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("presence_snapshot"),
		"after_revision":presence_revision
	})

func publish(status: String, activity: String = "") -> Dictionary:
	if status not in ["online","away","busy","offline"]:
		return {"ok":false,"error_code":"INVALID_PRESENCE"}
	return _post("presence_update",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("presence_update"),
		"expected_revision":presence_revision,
		"status":status,
		"activity":activity.left(48)
	})

func accept_snapshot_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < presence_revision:
		return false
	var incoming = envelope.get("players",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	var next: Dictionary = {}
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var player_id := str(item.get("player_id",""))
		if player_id.is_empty() or SocialModerationService.is_blocked(player_id):
			continue
		next[player_id] = _sanitize_presence(item)
	player_presence = next
	if envelope.has("self") and typeof(envelope.get("self",{})) == TYPE_DICTIONARY:
		own_presence = _sanitize_presence(envelope.get("self",{}))
	presence_revision = revision
	presence_changed.emit()
	return true

func accept_update_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < presence_revision:
		return false
	var item = envelope.get("presence",{})
	if typeof(item) != TYPE_DICTIONARY:
		return false
	own_presence = _sanitize_presence(item)
	presence_revision = revision
	presence_changed.emit()
	return true

func get_player(player_id: String) -> Dictionary:
	return Dictionary(player_presence.get(player_id,{})).duplicate(true)

func _sanitize_presence(item: Dictionary) -> Dictionary:
	var status := str(item.get("status","offline"))
	if status not in ["online","away","busy","offline"]:
		status = "offline"
	return {
		"player_id":str(item.get("player_id","")),
		"status":status,
		"activity":str(item.get("activity","")).left(48),
		"last_seen_unix":maxi(int(item.get("last_seen_unix",0)),0)
	}

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
