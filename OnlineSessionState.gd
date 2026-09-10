extends Node

signal state_changed(state: String)

const ONLINE := "online"
const CONNECTING := "connecting"
const SYNCING := "syncing"
const OFFLINE_LIMITED := "offline_limited"
const LOCAL_DEVELOPMENT := "local_development"

var state: String = LOCAL_DEVELOPMENT

func set_state(next_state: String) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(state)

func allows_sensitive_mutations() -> bool:
	return state in [ONLINE, LOCAL_DEVELOPMENT]

func player_facing_text() -> String:
	match state:
		ONLINE: return "ONLINE"
		CONNECTING: return "VERBINDE…"
		SYNCING: return "SYNCHRONISIERE…"
		OFFLINE_LIMITED: return "OFFLINE · EINGESCHRÄNKT"
	return "ENTWICKLUNGSMODUS"
