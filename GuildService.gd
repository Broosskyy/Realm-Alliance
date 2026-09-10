extends Node

signal guild_changed
signal guild_action_completed(result: Dictionary)

const CONTRACT_VERSION := "guild-service-v1"
var guild: Dictionary = {}
var last_server_revision: int = 0

func has_guild() -> bool:
	return not str(guild.get("guild_id","")).is_empty()

func request_snapshot() -> Dictionary:
	return _post("guild_snapshot",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_snapshot")})

func create_guild(name: String) -> Dictionary:
	var clean := name.strip_edges()
	if clean.length() < 3 or clean.length() > 24:
		return {"ok":false,"error_code":"INVALID_GUILD_NAME"}
	return _post("guild_create",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_create"),
		"name":clean
	})

func join_guild(guild_id: String) -> Dictionary:
	if guild_id.is_empty():
		return {"ok":false,"error_code":"MISSING_GUILD_ID"}
	return _post("guild_join",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_join"),
		"guild_id":guild_id
	})

func leave_guild() -> Dictionary:
	if not has_guild():
		return {"ok":false,"error_code":"NO_GUILD"}
	return _post("guild_leave",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_leave"),
		"guild_id":str(guild.get("guild_id",""))
	})

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func accept_guild_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",true)):
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < last_server_revision:
		return false
	var incoming = envelope.get("guild",{})
	if typeof(incoming) != TYPE_DICTIONARY:
		return false
	guild = _sanitize_guild(incoming)
	last_server_revision = revision
	guild_changed.emit()
	guild_action_completed.emit(envelope)
	return true

func _sanitize_guild(incoming: Dictionary) -> Dictionary:
	var members: Array[Dictionary] = []
	for item in incoming.get("members",[]):
		if typeof(item) == TYPE_DICTIONARY:
			members.append({
				"player_id":str(item.get("player_id","")),
				"display_name":str(item.get("display_name","Spieler")).left(24),
				"role":str(item.get("role","member")),
				"level":maxi(int(item.get("level",1)),1),
				"contribution":maxi(int(item.get("contribution",0)),0)
			})
	return {
		"guild_id":str(incoming.get("guild_id","")),
		"name":str(incoming.get("name","")).left(24),
		"level":maxi(int(incoming.get("level",1)),1),
		"xp":maxi(int(incoming.get("xp",0)),0),
		"member_count":members.size(),
		"members":members,
		"season_score":maxi(int(incoming.get("season_score",0)),0)
	}

func snapshot() -> Dictionary:
	return {"guild":guild.duplicate(true),"revision":last_server_revision}
