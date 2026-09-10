extends Node

const MAX_LOCAL_EVENTS := 200
var events: Array[Dictionary] = []
var first_tap_sent := false

func log_event(event_name: String, payload: Dictionary = {}) -> void:
	if event_name == "first_tap":
		if first_tap_sent:
			return
		first_tap_sent = true

	var event := {
		"event":event_name,
		"time_unix":Time.get_unix_time_from_system(),
		"payload":payload
	}
	events.append(event)
	if events.size() > MAX_LOCAL_EVENTS:
		events.pop_front()
	print("[CORE_ANALYTICS] ", JSON.stringify(event))

func export_debug_events() -> Array[Dictionary]:
	return events.duplicate()
