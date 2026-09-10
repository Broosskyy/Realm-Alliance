extends Node

signal activity_changed
signal notifications_changed

const ACTIVITY_CONTRACT_VERSION := "activity-feed-v1"
const NOTIFICATION_CONTRACT_VERSION := "notification-center-v1"

var activities: Array[Dictionary] = []
var notifications: Array[Dictionary] = []
var activity_revision: int = 0
var notification_revision: int = 0

func request_activity() -> Dictionary:
	return _post("activity_feed",{
		"contract_version":ACTIVITY_CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("activity_feed")
	})

func request_notifications() -> Dictionary:
	return _post("notifications_snapshot",{
		"contract_version":NOTIFICATION_CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("notifications")
	})

func mark_notification_read(notification_id: String) -> Dictionary:
	if notification_id.is_empty():
		return {"ok":false,"error_code":"MISSING_NOTIFICATION_ID"}
	return _post("notification_mark_read",{
		"contract_version":NOTIFICATION_CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("notification_read"),
		"notification_id":notification_id,
		"expected_revision":notification_revision
	})

func unread_count() -> int:
	var count := 0
	for item in notifications:
		if not bool(item.get("read",false)):
			count += 1
	return count

func accept_activity_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < activity_revision:
		return false
	var incoming = envelope.get("activities",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	activities.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		activities.append({
			"activity_id":str(item.get("activity_id","")),
			"type":str(item.get("type","generic")),
			"title":str(item.get("title","")).left(80),
			"body":str(item.get("body","")).left(220),
			"created_unix":maxi(int(item.get("created_unix",0)),0),
			"actor_id":str(item.get("actor_id",""))
		})
	activity_revision = revision
	activity_changed.emit()
	return true

func accept_notifications_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < notification_revision:
		return false
	var incoming = envelope.get("notifications",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	notifications.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		notifications.append({
			"notification_id":str(item.get("notification_id","")),
			"type":str(item.get("type","generic")),
			"title":str(item.get("title","")).left(80),
			"body":str(item.get("body","")).left(220),
			"created_unix":maxi(int(item.get("created_unix",0)),0),
			"read":bool(item.get("read",false)),
			"claim_id":str(item.get("claim_id",""))
		})
	notification_revision = revision
	notifications_changed.emit()
	return true

func accept_mark_read_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	if envelope.has("notifications"):
		return accept_notifications_envelope(envelope)
	return true

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
