extends Node

signal spin_result_received(result: Dictionary)
signal combat_result_received(result: Dictionary)
signal remote_gameplay_rejected(operation: String, error_code: String)

const CONTRACT_VERSION := "remote-gameplay-v1"
var pending_spin_request_id: String = ""
var pending_combat_requests: Dictionary = {}

func request_spin() -> Dictionary:
	if not _online_ready():
		return {"ok":false,"error_code":"ONLINE_NOT_READY"}
	if not pending_spin_request_id.is_empty():
		return {"ok":false,"error_code":"SPIN_ALREADY_PENDING"}
	if PlayerData.spins <= 0:
		return {"ok":false,"error_code":"INSUFFICIENT_SPINS","message":"Keine Spins verfügbar"}

	var request_id := OnlineAuthorityService.new_request_id("realm_spin_remote")
	var payload := {
		"contract_version":CONTRACT_VERSION,
		"request_id":request_id,
		"expected_revision":OnlineAuthorityService.server_revision,
		"client_build":BuildInfo.SOURCE_VERSION,
		"spins_before":PlayerData.spins,
		"spin_config_version":WheelSystem.CONFIG_VERSION,
		"presentation":"three_reel_machine"
	}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("remote_spin","/v1/game/spin"))
	var started := OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
	if bool(started.get("ok",false)):
		pending_spin_request_id = request_id
	return started

func request_monster_defeat(source: String, defeated_level: int, encounter_id: String, boss: bool) -> Dictionary:
	if not _online_ready():
		return {"ok":false,"error_code":"ONLINE_NOT_READY"}
	var request_id := OnlineAuthorityService.new_request_id("combat_defeat_remote")
	var payload := {
		"contract_version":CONTRACT_VERSION,
		"request_id":request_id,
		"expected_revision":OnlineAuthorityService.server_revision,
		"client_build":BuildInfo.SOURCE_VERSION,
		"source":source,
		"monster_level":defeated_level,
		"encounter_id":encounter_id,
		"boss":boss,
		"client_observed_hp":PlayerData.current_monster_hp
	}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("remote_combat_defeat","/v1/game/combat/defeat"))
	var started := OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())
	if bool(started.get("ok",false)):
		pending_combat_requests[request_id] = {
			"source":source,
			"defeated_level":defeated_level,
			"encounter_id":encounter_id,
			"boss":boss
		}
	return started

func accept_spin_envelope(envelope: Dictionary) -> bool:
	var request_id := str(envelope.get("request_id",""))
	if request_id.is_empty() or request_id != pending_spin_request_id:
		return false
	if not _validate_valuable_envelope(envelope):
		_reject("realm_spin",str(envelope.get("error_code","INVALID_SPIN_ENVELOPE")))
		return false
	var result = envelope.get("result",{})
	var economy = envelope.get("economy",{})
	if typeof(result) != TYPE_DICTIONARY or typeof(economy) != TYPE_DICTIONARY:
		return false
	var stops = result.get("reel_stops",[])
	if typeof(stops) != TYPE_ARRAY or stops.size() != 3:
		return false
	if not _apply_economy_snapshot(economy):
		return false

	var confirmed: Dictionary = result.duplicate(true)
	confirmed["ok"] = true
	confirmed["authority"] = "server"
	confirmed["authority_request_id"] = request_id
	confirmed["authority_revision"] = int(envelope.get("revision",0))
	confirmed["server_unix"] = int(envelope.get("server_unix",0))
	confirmed["presentation"] = "three_reel_machine"
	OnlineAuthorityService.server_revision = int(envelope.get("revision",0))
	OnlineAuthorityService.last_server_unix = int(envelope.get("server_unix",0))
	ServerClockService.sync_server_time(OnlineAuthorityService.last_server_unix)
	pending_spin_request_id = ""
	SpinPresentationState.set_pending_result(confirmed,WheelSystem.CONFIG_VERSION)
	SaveGame.save_game()
	spin_result_received.emit(confirmed)
	return true

func accept_combat_envelope(envelope: Dictionary) -> bool:
	var request_id := str(envelope.get("request_id",""))
	if request_id.is_empty() or not pending_combat_requests.has(request_id):
		return false
	if not _validate_valuable_envelope(envelope):
		_reject("monster_defeat",str(envelope.get("error_code","INVALID_COMBAT_ENVELOPE")))
		return false
	var result = envelope.get("result",{})
	var economy = envelope.get("economy",{})
	var progression = envelope.get("progression",{})
	if typeof(result) != TYPE_DICTIONARY or typeof(economy) != TYPE_DICTIONARY or typeof(progression) != TYPE_DICTIONARY:
		return false
	if not _apply_economy_snapshot(economy):
		return false
	if not _apply_progression_snapshot(progression):
		return false

	var context: Dictionary = pending_combat_requests.get(request_id,{})
	var confirmed: Dictionary = result.duplicate(true)
	confirmed["ok"] = true
	confirmed["source"] = str(confirmed.get("source",context.get("source","unknown")))
	confirmed["defeated_level"] = int(confirmed.get("defeated_level",context.get("defeated_level",1)))
	confirmed["encounter_id"] = str(confirmed.get("encounter_id",context.get("encounter_id","")))
	confirmed["boss"] = bool(confirmed.get("boss",context.get("boss",false)))
	confirmed["authority"] = "server"
	confirmed["remote"] = true
	confirmed["authority_request_id"] = request_id
	confirmed["authority_revision_after"] = int(envelope.get("revision",0))
	OnlineAuthorityService.server_revision = int(envelope.get("revision",0))
	OnlineAuthorityService.last_server_unix = int(envelope.get("server_unix",0))
	ServerClockService.sync_server_time(OnlineAuthorityService.last_server_unix)
	pending_combat_requests.erase(request_id)
	SaveGame.save_game()
	combat_result_received.emit(confirmed)
	return true

func _validate_valuable_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",true)):
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < OnlineAuthorityService.server_revision:
		return false
	var server_unix := int(envelope.get("server_unix",0))
	return server_unix > 0

func _apply_economy_snapshot(economy: Dictionary) -> bool:
	for key in ["gold","gems","spins","shields"]:
		if not economy.has(key):
			return false
	PlayerData.gold = maxi(int(economy.get("gold",0)),0)
	PlayerData.gems = maxi(int(economy.get("gems",0)),0)
	PlayerData.spins = maxi(int(economy.get("spins",0)),0)
	PlayerData.shields = clampi(int(economy.get("shields",0)),0,GameConfig.MAX_SHIELDS)
	PlayerData.stats_changed.emit()
	return true

func _apply_progression_snapshot(progression: Dictionary) -> bool:
	if not progression.has("monster_level"):
		return false
	PlayerData.monster_level = maxi(int(progression.get("monster_level",1)),1)
	PlayerData.monster_max_hp = maxi(int(progression.get("monster_max_hp",GameConfig.effective_monster_hp(PlayerData.monster_level))),1)
	PlayerData.current_monster_hp = clampi(int(progression.get("current_monster_hp",PlayerData.monster_max_hp)),0,PlayerData.monster_max_hp)
	if progression.has("player_level"):
		PlayerData.player_level = maxi(int(progression.get("player_level",1)),1)
	if progression.has("player_xp"):
		PlayerData.player_xp = maxi(int(progression.get("player_xp",0)),0)
	PlayerData.monster_changed.emit()
	PlayerData.progression_changed.emit()
	return true

func _online_ready() -> bool:
	return OnlineAuthorityService.mode == "online" and AuthSessionService.is_authenticated() and OnlineTransportService.is_ready()

func _reject(operation: String, code: String) -> void:
	remote_gameplay_rejected.emit(operation,code)
