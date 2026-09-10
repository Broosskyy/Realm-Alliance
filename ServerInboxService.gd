extends Node

signal inbox_changed
signal inbox_action_result(result: Dictionary)

const CONTRACT_VERSION := "server-inbox-v1"

var entries: Array[Dictionary] = []
var inbox_revision: int = 0
var sync_cursor: String = ""

func request_inbox() -> Dictionary:
	return _post("server_inbox",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("server_inbox"),
		"after_revision":inbox_revision,
		"sync_cursor":sync_cursor
	})

func mark_read(message_id: String) -> Dictionary:
	if message_id.is_empty():
		return {"ok":false,"error_code":"MISSING_MESSAGE_ID"}
	return _post("server_inbox_read",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("server_inbox_read"),
		"message_id":message_id,
		"expected_revision":inbox_revision
	})

func acknowledge(message_id: String) -> Dictionary:
	if message_id.is_empty():
		return {"ok":false,"error_code":"MISSING_MESSAGE_ID"}
	return _post("server_inbox_ack",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("server_inbox_ack"),
		"message_id":message_id,
		"expected_revision":inbox_revision
	})

func accept_inbox_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < inbox_revision:
		return false
	var incoming = envelope.get("entries",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	var next: Array[Dictionary] = []
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var message_id := str(item.get("message_id",""))
		if message_id.is_empty():
			continue
		next.append({
			"message_id":message_id,
			"type":str(item.get("type","info")),
			"title":str(item.get("title","")).left(64),
			"body":str(item.get("body","")).left(320),
			"created_unix":maxi(int(item.get("created_unix",0)),0),
			"read":bool(item.get("read",false)),
			"acknowledged":bool(item.get("acknowledged",false)),
			"reward_claim_id":str(item.get("reward_claim_id","")),
			"deeplink":str(item.get("deeplink","")).left(256)
		})
	entries = next
	inbox_revision = revision
	sync_cursor = str(envelope.get("sync_cursor",sync_cursor))
	inbox_changed.emit()
	return true

func accept_action_envelope(envelope: Dictionary) -> bool:
	inbox_action_result.emit(envelope)
	if not bool(envelope.get("ok",false)):
		return false
	if envelope.has("entries"):
		return accept_inbox_envelope(envelope)
	inbox_revision = maxi(int(envelope.get("revision",inbox_revision)),inbox_revision)
	sync_cursor = str(envelope.get("sync_cursor",sync_cursor))
	return true

func unread_count() -> int:
	var total := 0
	for entry in entries:
		if not bool(entry.get("read",false)):
			total += 1
	return total

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
