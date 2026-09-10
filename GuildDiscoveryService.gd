extends Node
signal search_changed
signal applications_changed
signal invites_changed
signal discovery_action_result(result: Dictionary)
const CONTRACT_VERSION := "guild-discovery-v1"
var search_results: Array[Dictionary] = []
var applications: Array[Dictionary] = []
var invites: Array[Dictionary] = []
var discovery_revision: int = 0
func search(query: String = "") -> Dictionary:
	return _post("guild_search",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_search"),"query":query.strip_edges().left(48)})
func request_applications() -> Dictionary:
	return _post("guild_applications",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_applications")})
func apply_to_guild(guild_id: String, message: String = "") -> Dictionary:
	if guild_id.is_empty(): return {"ok":false,"error_code":"MISSING_GUILD_ID"}
	return _post("guild_apply",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_apply"),"guild_id":guild_id,"message":message.strip_edges().left(180),"expected_revision":discovery_revision})
func application_action(application_id: String, action: String) -> Dictionary:
	if application_id.is_empty() or action not in ["accept","decline","withdraw"]: return {"ok":false,"error_code":"INVALID_APPLICATION_ACTION"}
	return _post("guild_application_action",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_application_action"),"application_id":application_id,"action":action,"expected_revision":discovery_revision})
func request_invites() -> Dictionary:
	return _post("guild_invites",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_invites")})
func send_invite(player_id: String) -> Dictionary:
	if player_id.is_empty(): return {"ok":false,"error_code":"MISSING_PLAYER_ID"}
	return _post("guild_invite_send",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_invite_send"),"target_player_id":player_id,"guild_id":str(GuildService.guild.get("guild_id","")),"expected_revision":discovery_revision})
func invite_action(invite_id: String, action: String) -> Dictionary:
	if invite_id.is_empty() or action not in ["accept","decline","revoke"]: return {"ok":false,"error_code":"INVALID_INVITE_ACTION"}
	return _post("guild_invite_action",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_invite_action"),"invite_id":invite_id,"action":action,"expected_revision":discovery_revision})
func accept_search_envelope(envelope: Dictionary) -> bool:
	var incoming = envelope.get("guilds",[])
	if typeof(incoming) != TYPE_ARRAY: return false
	search_results.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY: continue
		search_results.append({"guild_id":str(item.get("guild_id","")),"name":str(item.get("name","")).left(32),"level":maxi(int(item.get("level",1)),1),"members":maxi(int(item.get("members",0)),0),"capacity":maxi(int(item.get("capacity",0)),0),"join_policy":str(item.get("join_policy","application")),"season_score":maxi(int(item.get("season_score",0)),0)})
	search_changed.emit(); return true
func accept_applications_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1));
	if revision < discovery_revision: return false
	var incoming = envelope.get("applications",[])
	if typeof(incoming) != TYPE_ARRAY: return false
	applications.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY: continue
		applications.append({"application_id":str(item.get("application_id","")),"guild_id":str(item.get("guild_id","")),"player_id":str(item.get("player_id","")),"display_name":str(item.get("display_name","Spieler")).left(24),"state":str(item.get("state","pending")),"created_unix":maxi(int(item.get("created_unix",0)),0)})
	discovery_revision=revision; applications_changed.emit(); return true
func accept_invites_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1));
	if revision < discovery_revision: return false
	var incoming = envelope.get("invites",[])
	if typeof(incoming) != TYPE_ARRAY: return false
	invites.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY: continue
		invites.append({"invite_id":str(item.get("invite_id","")),"guild_id":str(item.get("guild_id","")),"guild_name":str(item.get("guild_name","")).left(32),"player_id":str(item.get("player_id","")),"state":str(item.get("state","pending")),"created_unix":maxi(int(item.get("created_unix",0)),0)})
	discovery_revision=revision; invites_changed.emit(); return true
func accept_action_envelope(envelope: Dictionary) -> bool:
	discovery_action_result.emit(envelope)
	if not bool(envelope.get("ok",false)): return false
	if envelope.has("applications"): return accept_applications_envelope(envelope)
	if envelope.has("invites"): return accept_invites_envelope(envelope)
	return true
func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated(): return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready(): return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
