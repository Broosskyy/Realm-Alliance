extends Node

signal connectivity_changed(state: String)
signal retry_scheduled(request_id: String, attempt: int, delay_seconds: float)

const CONTRACT_VERSION := "network-resilience-v1"
const HEALTHY := "healthy"
const DEGRADED := "degraded"
const DISCONNECTED := "disconnected"

var state: String = HEALTHY
var consecutive_failures: int = 0
var last_success_unix: int = 0
var last_failure_unix: int = 0
var request_attempts: Dictionary = {}

func max_retries() -> int:
	return maxi(int(OnlineAuthorityService.config.get("transport",{}).get("max_retries",2)),0)

func disconnect_threshold() -> int:
	return maxi(int(OnlineAuthorityService.config.get("transport",{}).get("disconnect_after_consecutive_failures",3)),1)

func retry_delay(attempt: int) -> float:
	var delays: Array = OnlineAuthorityService.config.get("transport",{}).get("retry_backoff_seconds",[1,3])
	if delays.is_empty():
		return float(maxi(attempt,1))
	var index := clampi(attempt-1,0,delays.size()-1)
	return maxf(float(delays[index]),0.0)

func register_request(request_id: String) -> void:
	if request_id.is_empty():
		return
	if not request_attempts.has(request_id):
		request_attempts[request_id] = 1

func mark_retry(request_id: String) -> Dictionary:
	var attempt := int(request_attempts.get(request_id,1)) + 1
	request_attempts[request_id] = attempt
	if attempt > max_retries() + 1:
		return {"ok":false,"retry":false,"attempt":attempt}
	var delay := retry_delay(attempt-1)
	retry_scheduled.emit(request_id,attempt,delay)
	return {"ok":true,"retry":true,"attempt":attempt,"delay_seconds":delay}

func mark_success(request_id: String = "") -> void:
	if not request_id.is_empty():
		request_attempts.erase(request_id)
	consecutive_failures = 0
	last_success_unix = ServerClockService.now_unix()
	if state != HEALTHY:
		state = HEALTHY
		connectivity_changed.emit(state)

func mark_failure(request_id: String = "", retryable: bool = true) -> void:
	consecutive_failures += 1
	last_failure_unix = ServerClockService.now_unix()
	if consecutive_failures >= disconnect_threshold():
		state = DISCONNECTED
		OnlineSessionState.set_state(OnlineSessionState.OFFLINE_LIMITED)
	elif retryable:
		state = DEGRADED
	if not request_id.is_empty() and not retryable:
		request_attempts.erase(request_id)
	connectivity_changed.emit(state)

func clear_request(request_id: String) -> void:
	request_attempts.erase(request_id)

func status_snapshot() -> Dictionary:
	return {
		"contract_version":CONTRACT_VERSION,
		"state":state,
		"consecutive_failures":consecutive_failures,
		"last_success_unix":last_success_unix,
		"last_failure_unix":last_failure_unix
	}
