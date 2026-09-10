extends Node

signal request_started(request_id: String, route: String)
signal request_completed(request_id: String, response: Dictionary)
signal transport_state_changed(state: String)

const CONTRACT_VERSION := "realm-http-transport-v1"

var base_url: String = ""
var enabled: bool = false
var require_https: bool = true
var request_timeout_seconds: float = 20.0
var active_requests: Dictionary = {}
var request_descriptors: Dictionary = {}
var transport_state: String = "disabled"

func _ready() -> void:
	var cfg: Dictionary = OnlineAuthorityService.config.get("transport",{})
	enabled = bool(cfg.get("enabled",false))
	base_url = str(cfg.get("base_url","")).strip_edges().trim_suffix("/")
	require_https = bool(cfg.get("require_https",true))
	request_timeout_seconds = float(cfg.get("request_timeout_seconds",20))
	_refresh_state()

func configure_runtime(url: String, transport_enabled: bool = true) -> Dictionary:
	var clean := url.strip_edges().trim_suffix("/")
	if transport_enabled and clean.is_empty():
		return {"ok":false,"error_code":"MISSING_BASE_URL"}
	if transport_enabled and require_https and not clean.begins_with("https://"):
		return {"ok":false,"error_code":"HTTPS_REQUIRED"}
	base_url = clean
	enabled = transport_enabled
	_refresh_state()
	return {"ok":true,"state":transport_state}

func _refresh_state() -> void:
	transport_state = "ready" if enabled and not base_url.is_empty() else "disabled"
	transport_state_changed.emit(transport_state)

func is_ready() -> bool:
	return transport_state == "ready"

func post_json(route: String, payload: Dictionary, headers: PackedStringArray = PackedStringArray()) -> Dictionary:
	if not is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED","retryable":false}
	if not route.begins_with("/"):
		return {"ok":false,"error_code":"INVALID_ROUTE","retryable":false}

	var request_id := str(payload.get("request_id", OnlineAuthorityService.new_request_id("http")))
	var node := HTTPRequest.new()
	node.timeout = request_timeout_seconds
	add_child(node)
	active_requests[request_id] = node
	request_descriptors[request_id] = {
		"route":route,
		"payload":payload.duplicate(true),
		"headers":headers.duplicate()
	}
	NetworkResilienceService.register_request(request_id)
	node.request_completed.connect(_on_http_completed.bind(request_id,route,node))

	var final_headers := PackedStringArray(["Content-Type: application/json","Accept: application/json"])
	for header in headers:
		final_headers.append(header)
	var err := node.request(base_url + route, final_headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		active_requests.erase(request_id)
		node.queue_free()
		NetworkResilienceService.mark_failure(request_id,true)
		return {"ok":false,"error_code":"REQUEST_START_FAILED","engine_error":err,"retryable":true,"request_id":request_id}
	request_started.emit(request_id,route)
	return {"ok":true,"request_id":request_id,"pending":true}

func _on_http_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request_id: String, route: String, node: HTTPRequest) -> void:
	active_requests.erase(request_id)
	var response := {
		"ok":result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300,
		"request_id":request_id,
		"route":route,
		"transport_result":result,
		"http_status":response_code,
		"headers":headers,
		"retryable":response_code == 0 or response_code == 408 or response_code == 429 or response_code >= 500
	}
	if body.size() > 0:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_DICTIONARY:
			response["body"] = parsed
		else:
			response["error_code"] = "INVALID_JSON_RESPONSE"
			response["ok"] = false
			response["retryable"] = false
	if not bool(response.get("ok",false)) and not response.has("error_code"):
		response["error_code"] = "HTTP_REQUEST_FAILED"

	if bool(response.get("ok",false)):
		NetworkResilienceService.mark_success(request_id)
		request_descriptors.erase(request_id)
		request_completed.emit(request_id,response)
		node.queue_free()
		return

	NetworkResilienceService.mark_failure(request_id,bool(response.get("retryable",false)))
	var retry := NetworkResilienceService.mark_retry(request_id) if bool(response.get("retryable",false)) else {"retry":false}
	if bool(retry.get("retry",false)):
		var descriptor: Dictionary = request_descriptors.get(request_id,{})
		var delay := float(retry.get("delay_seconds",0.0))
		node.queue_free()
		await get_tree().create_timer(delay).timeout
		_retry_request(request_id,descriptor)
		return

	request_descriptors.erase(request_id)
	NetworkResilienceService.clear_request(request_id)
	request_completed.emit(request_id,response)
	node.queue_free()

func _retry_request(request_id: String, descriptor: Dictionary) -> void:
	if descriptor.is_empty() or not is_ready():
		request_completed.emit(request_id,{"ok":false,"request_id":request_id,"error_code":"RETRY_ABORTED","retryable":false})
		return
	var payload: Dictionary = descriptor.get("payload",{}).duplicate(true)
	payload["request_id"] = request_id
	var headers: PackedStringArray = descriptor.get("headers",PackedStringArray())
	var route := str(descriptor.get("route",""))
	post_json(route,payload,headers)

func cancel_all() -> void:
	for request_id in active_requests.keys():
		var node = active_requests.get(request_id)
		if is_instance_valid(node):
			node.cancel_request()
			node.queue_free()
	active_requests.clear()
	request_descriptors.clear()
