extends Node

signal chat_changed(channel_id: String)
signal chat_action_result(result: Dictionary)

const CONTRACT_VERSION := "social-chat-v1"
const MAX_MESSAGE_LENGTH := 280

var channels: Dictionary = {}
var channel_revisions: Dictionary = {}

func request_channel(channel_type: String, channel_id: String) -> Dictionary:
	if channel_type not in ["guild","party","direct"] or channel_id.is_empty():
		return {"ok":false,"error_code":"INVALID_CHAT_CHANNEL"}
	return _post("chat_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("chat_snapshot"),
		"channel_type":channel_type,
		"channel_id":channel_id,
		"after_revision":maxi(int(channel_revisions.get(channel_id,0)),0)
	})

func send_message(channel_type: String, channel_id: String, text: String) -> Dictionary:
	var clean := _sanitize_text(text)
	if channel_type not in ["guild","party","direct"] or channel_id.is_empty() or clean.is_empty():
		return {"ok":false,"error_code":"INVALID_CHAT_MESSAGE"}
	if channel_type == "guild" and not GuildService.has_guild():
		return {"ok":false,"error_code":"GUILD_REQUIRED"}
	if channel_type == "party" and not PartyLobbyService.has_party():
		return {"ok":false,"error_code":"PARTY_REQUIRED"}
	return _post("chat_send",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("chat_send"),
		"channel_type":channel_type,
		"channel_id":channel_id,
		"text":clean,
		"expected_revision":maxi(int(channel_revisions.get(channel_id,0)),0)
	})

func delete_message(channel_id: String, message_id: String) -> Dictionary:
	if channel_id.is_empty() or message_id.is_empty():
		return {"ok":false,"error_code":"INVALID_CHAT_DELETE"}
	return _post("chat_delete",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("chat_delete"),
		"channel_id":channel_id,
		"message_id":message_id,
		"expected_revision":maxi(int(channel_revisions.get(channel_id,0)),0)
	})

func accept_snapshot_envelope(envelope: Dictionary) -> bool:
	var channel_id := str(envelope.get("channel_id",""))
	var revision := int(envelope.get("revision",-1))
	if channel_id.is_empty() or revision < int(channel_revisions.get(channel_id,0)):
		return false
	var incoming = envelope.get("messages",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	var rows: Array[Dictionary] = []
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var sender_id := str(item.get("sender_id",""))
		if not sender_id.is_empty() and SocialModerationService.is_blocked(sender_id):
			continue
		var message_id := str(item.get("message_id",""))
		if message_id.is_empty():
			continue
		rows.append({
			"message_id":message_id,
			"sender_id":sender_id,
			"sender_name":str(item.get("sender_name","Spieler")).left(24),
			"text":_sanitize_text(str(item.get("text",""))),
			"created_unix":maxi(int(item.get("created_unix",0)),0),
			"edited":bool(item.get("edited",false))
		})
	channels[channel_id] = rows
	channel_revisions[channel_id] = revision
	chat_changed.emit(channel_id)
	return true

func accept_action_envelope(envelope: Dictionary) -> bool:
	chat_action_result.emit(envelope)
	if not bool(envelope.get("ok",false)):
		return false
	if envelope.has("messages"):
		return accept_snapshot_envelope(envelope)
	return true

func messages(channel_id: String) -> Array:
	return Array(channels.get(channel_id,[])).duplicate(true)

func _sanitize_text(value: String) -> String:
	var text := value.strip_edges().replace("\u0000","")
	return text.left(MAX_MESSAGE_LENGTH)

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
