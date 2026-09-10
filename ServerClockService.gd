extends Node

signal server_time_updated(server_unix: int)

var server_unix_at_sync: int = 0
var local_ticks_at_sync_msec: int = 0
var has_server_time: bool = false

func now_unix() -> int:
	if has_server_time:
		var elapsed := maxi(Time.get_ticks_msec() - local_ticks_at_sync_msec, 0)
		return server_unix_at_sync + int(elapsed / 1000)
	return int(Time.get_unix_time_from_system())

func sync_server_time(server_unix: int) -> void:
	if server_unix <= 0:
		return
	server_unix_at_sync = server_unix
	local_ticks_at_sync_msec = Time.get_ticks_msec()
	has_server_time = true
	server_time_updated.emit(server_unix)

func is_server_time_authoritative() -> bool:
	return has_server_time

func export_sync_state() -> Dictionary:
	return {"server_unix_at_sync":server_unix_at_sync,"has_server_time":has_server_time}

func apply_sync_state(data: Dictionary) -> void:
	server_unix_at_sync = maxi(int(data.get("server_unix_at_sync",0)),0)
	has_server_time = false
	local_ticks_at_sync_msec = Time.get_ticks_msec()
