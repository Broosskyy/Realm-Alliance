extends Node

signal governance_changed
signal member_action_result(result: Dictionary)
signal role_update_result(result: Dictionary)

const CONTRACT_VERSION := "guild-governance-v1"

var self_role: String = "member"
var role_permissions: Dictionary = {}
var member_roles: Dictionary = {}
var governance_revision: int = 0

func request_snapshot() -> Dictionary:
	return _post("guild_governance_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_governance")
	})

func can(permission_id: String) -> bool:
	var permissions: Array = role_permissions.get(self_role,[])
	return permissions.has(permission_id)

func update_member_role(player_id: String, new_role: String) -> Dictionary:
	if player_id.is_empty() or new_role.is_empty():
		return {"ok":false,"error_code":"INVALID_ROLE_UPDATE"}
	return _post("guild_role_update",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_role_update"),
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"target_player_id":player_id,
		"new_role":new_role,
		"expected_revision":governance_revision
	})

func member_action(player_id: String, action: String) -> Dictionary:
	if action not in ["kick","promote","demote","transfer_leadership"]:
		return {"ok":false,"error_code":"INVALID_MEMBER_ACTION"}
	if player_id.is_empty():
		return {"ok":false,"error_code":"MISSING_TARGET_PLAYER"}
	return _post("guild_member_action",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_member_action"),
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"target_player_id":player_id,
		"action":action,
		"expected_revision":governance_revision
	})

func accept_snapshot(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < governance_revision:
		return false
	var roles = envelope.get("roles",{})
	var members = envelope.get("member_roles",{})
	if typeof(roles) != TYPE_DICTIONARY or typeof(members) != TYPE_DICTIONARY:
		return false
	role_permissions.clear()
	for role_id in roles.keys():
		var incoming = roles[role_id]
		if typeof(incoming) == TYPE_ARRAY:
			role_permissions[str(role_id)] = Array(incoming).duplicate()
	member_roles.clear()
	for player_id in members.keys():
		member_roles[str(player_id)] = str(members[player_id])
	self_role = str(envelope.get("self_role","member"))
	governance_revision = revision
	governance_changed.emit()
	return true

func accept_role_update(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		role_update_result.emit(envelope)
		return false
	var accepted := accept_snapshot(envelope) if envelope.has("roles") else true
	role_update_result.emit(envelope)
	return accepted

func accept_member_action(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		member_action_result.emit(envelope)
		return false
	var accepted := accept_snapshot(envelope) if envelope.has("roles") else true
	member_action_result.emit(envelope)
	return accepted

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
