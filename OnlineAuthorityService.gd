extends Node

signal authority_result(result: Dictionary)

const CONFIG_PATH := "res://data/online_authority_v186.json"
var config: Dictionary = {}
var mode: String = "local_development"
var server_revision: int = 0
var last_server_unix: int = 0
var last_request_id: String = ""
var pending_intents: Array = []
var resolved_request_ids: Array[String] = []

func _ready() -> void:
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not f:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		mode = str(config.get("mode","local_development"))

func new_request_id(operation: String) -> String:
	return "%s_%d_%d" % [operation, int(Time.get_ticks_usec()), randi()]

func build_intent(operation: String, payload: Dictionary = {}, request_id: String = "") -> Dictionary:
	var rid := request_id if not request_id.is_empty() else new_request_id(operation)
	return {
		"contract_version":str(config.get("request_contract_version","authority-intent-v1")),
		"request_id":rid,
		"operation":operation,
		"expected_revision":server_revision,
		"client_build":BuildInfo.SOURCE_VERSION,
		"created_unix":ServerClockService.now_unix(),
		"payload":payload.duplicate(true)
	}

func register_pending_intent(intent: Dictionary) -> bool:
	var rid := str(intent.get("request_id",""))
	if rid.is_empty() or resolved_request_ids.has(rid):
		return false
	for item in pending_intents:
		if str(item.get("request_id","")) == rid:
			return false
	pending_intents.append(intent.duplicate(true))
	var cap := maxi(int(config.get("max_pending_intents",64)),1)
	while pending_intents.size() > cap:
		pending_intents.pop_front()
	return true

func resolve_pending_intent(request_id: String) -> void:
	if request_id.is_empty():
		return
	for i in range(pending_intents.size() - 1, -1, -1):
		if str(pending_intents[i].get("request_id","")) == request_id:
			pending_intents.remove_at(i)
	if not resolved_request_ids.has(request_id):
		resolved_request_ids.append(request_id)
	while resolved_request_ids.size() > 128:
		resolved_request_ids.pop_front()

func has_resolved_request(request_id: String) -> bool:
	return resolved_request_ids.has(request_id)

func local_result(intent: Dictionary, changes: Dictionary = {}, presentation: Dictionary = {}) -> Dictionary:
	server_revision += 1
	last_server_unix = ServerClockService.now_unix()
	last_request_id = str(intent.get("request_id",""))
	var result := {
		"contract_version":str(config.get("result_contract_version","authority-result-v1")),
		"ok":true,
		"request_id":last_request_id,
		"operation":str(intent.get("operation","")),
		"revision":server_revision,
		"server_unix":last_server_unix,
		"changes":changes.duplicate(true),
		"presentation":presentation.duplicate(true),
		"authority":"local_development"
	}
	resolve_pending_intent(last_request_id)
	authority_result.emit(result)
	return result

func rejected_result(intent: Dictionary, code: String, message: String, retryable: bool = false) -> Dictionary:
	var result := {
		"contract_version":str(config.get("result_contract_version","authority-result-v1")),
		"ok":false,
		"request_id":str(intent.get("request_id","")),
		"operation":str(intent.get("operation","")),
		"revision":server_revision,
		"server_unix":ServerClockService.now_unix(),
		"error_code":code,
		"message":message,
		"retryable":retryable,
		"authority":mode
	}
	authority_result.emit(result)
	return result

func export_local_sync_state() -> Dictionary:
	return {
		"mode":mode,
		"server_revision":server_revision,
		"last_server_unix":last_server_unix,
		"last_request_id":last_request_id,
		"pending_intents":pending_intents.duplicate(true),
		"resolved_request_ids":resolved_request_ids.duplicate()
	}

func apply_local_sync_state(data: Dictionary) -> void:
	server_revision = maxi(int(data.get("server_revision",0)),0)
	last_server_unix = maxi(int(data.get("last_server_unix",0)),0)
	last_request_id = str(data.get("last_request_id",""))
	pending_intents.clear()
	for item in data.get("pending_intents",[]):
		if typeof(item) == TYPE_DICTIONARY:
			pending_intents.append(item.duplicate(true))
	resolved_request_ids.clear()
	for item in data.get("resolved_request_ids",[]):
		var rid := str(item)
		if not rid.is_empty() and not resolved_request_ids.has(rid):
			resolved_request_ids.append(rid)


func submit_remote_intent(intent: Dictionary) -> Dictionary:
	if mode != "online":
		return {"ok":false,"error_code":"NOT_IN_ONLINE_MODE"}
	if not AuthSessionService.is_authenticated():
		return rejected_result(intent,"AUTH_REQUIRED","Online-Sitzung erforderlich",true)
	if not OnlineTransportService.is_ready():
		return rejected_result(intent,"TRANSPORT_NOT_CONFIGURED","Online-Verbindung nicht konfiguriert",true)
	if not register_pending_intent(intent):
		return {"ok":false,"error_code":"DUPLICATE_OR_RESOLVED_REQUEST","request_id":str(intent.get("request_id",""))}
	var route := str(config.get("routes",{}).get("authority_intent","/v1/game/intent"))
	return OnlineTransportService.post_json(route,intent,AuthSessionService.auth_header())

func build_sync_transport_request() -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	var route := str(config.get("routes",{}).get("player_sync","/v1/player/sync"))
	var body := SyncReconciliationService.begin_sync_request()
	body["request_id"] = new_request_id("player_sync")
	return OnlineTransportService.post_json(route,body,AuthSessionService.auth_header())
