extends Node
signal push_registration_changed
signal push_preferences_changed
const CONTRACT_VERSION := "push-notification-v1"
var registration_id: String = ""
var preferences: Dictionary = {}
var push_revision: int = 0
var notification_sync_cursor: String = ""
func register_device(platform: String, device_token: String) -> Dictionary:
	if platform not in ["android","ios"] or device_token.is_empty(): return {"ok":false,"error_code":"INVALID_DEVICE_REGISTRATION"}
	return _post("push_register",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("push_register"),"platform":platform,"device_token":device_token,"client_build":BuildInfo.SOURCE_VERSION})
func unregister_device() -> Dictionary:
	if registration_id.is_empty(): return {"ok":false,"error_code":"NO_PUSH_REGISTRATION"}
	return _post("push_unregister",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("push_unregister"),"registration_id":registration_id,"expected_revision":push_revision})
func update_preferences(next_preferences: Dictionary) -> Dictionary:
	return _post("push_preferences",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("push_preferences"),"expected_revision":push_revision,"preferences":next_preferences.duplicate(true)})
func accept_registration_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)): return false
	var revision := int(envelope.get("revision",-1));
	if revision < push_revision: return false
	registration_id=str(envelope.get("registration_id","")); push_revision=revision
	if envelope.has("preferences"): preferences=Dictionary(envelope.get("preferences",{})).duplicate(true)
	push_registration_changed.emit(); return true
func accept_preferences_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1));
	if revision < push_revision: return false
	var incoming=envelope.get("preferences",{})
	if typeof(incoming) != TYPE_DICTIONARY: return false
	preferences=Dictionary(incoming).duplicate(true); push_revision=revision; push_preferences_changed.emit(); return true
func accept_unregistration_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)): return false
	registration_id=""; push_revision=maxi(int(envelope.get("revision",push_revision)),push_revision); push_registration_changed.emit(); return true
func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated(): return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready(): return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())


func request_cross_device_sync() -> Dictionary:
	return _post("notification_sync",{
		"contract_version":"notification-sync-v1",
		"request_id":OnlineAuthorityService.new_request_id("notification_sync"),
		"after_revision":push_revision,
		"sync_cursor":notification_sync_cursor
	})

func accept_sync_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < push_revision:
		return false
	var incoming = envelope.get("preferences",{})
	if typeof(incoming) == TYPE_DICTIONARY:
		preferences = Dictionary(incoming).duplicate(true)
	push_revision = revision
	notification_sync_cursor = str(envelope.get("sync_cursor",notification_sync_cursor))
	push_preferences_changed.emit()
	return true
