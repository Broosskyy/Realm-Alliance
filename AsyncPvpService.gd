extends Node

signal opponents_changed
signal battle_result_received(result: Dictionary)
signal history_changed
signal pvp_reward_result(result: Dictionary)

const CONTRACT_VERSION := "pvp-season-v2"
var opponents: Array[Dictionary] = []
var history: Array[Dictionary] = []
var league_snapshot: Dictionary = {}
var last_revision: int = 0
var matchmaking_ticket: String = ""
var defense_snapshot_id: String = ""
var season_revision: int = 0
var league_progress: Dictionary = {}

func request_matchmaking() -> Dictionary:
	if not LoadoutSnapshotService.has_published_snapshot():
		return {"ok":false,"error_code":"LOADOUT_SNAPSHOT_REQUIRED"}
	if not DefenseTeamService.has_server_snapshot():
		return {"ok":false,"error_code":"DEFENSE_TEAM_SNAPSHOT_REQUIRED"}
	return _post("pvp_matchmaking",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_matchmaking"),
		"loadout_snapshot_id":LoadoutSnapshotService.published_snapshot_id,
		"loadout_revision":LoadoutSnapshotService.published_revision,
		"defense_snapshot_id":DefenseTeamService.defense_snapshot_id,
		"defense_revision":DefenseTeamService.defense_revision
	})

func publish_defense_snapshot() -> Dictionary:
	return DefenseTeamService.publish()

func request_league_snapshot() -> Dictionary:
	return _post("pvp_league_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_league_snapshot")
	})

func request_season_progress() -> Dictionary:
	return _post("pvp_season_progress",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_season_progress")
	})

func request_season_snapshot() -> Dictionary:
	return _post("pvp_season_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_season_snapshot")
	})

func request_opponents() -> Dictionary:
	return _post("pvp_opponents",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_opponents")
	})

func attack(opponent_id: String, loadout_revision: int = 0) -> Dictionary:
	if opponent_id.is_empty():
		return {"ok":false,"error_code":"MISSING_OPPONENT"}
	if matchmaking_ticket.is_empty():
		return {"ok":false,"error_code":"MATCHMAKING_TICKET_REQUIRED"}
	if not LoadoutSnapshotService.has_published_snapshot():
		return {"ok":false,"error_code":"LOADOUT_SNAPSHOT_REQUIRED"}
	var opponent_snapshot_id := ""
	for opponent in opponents:
		if str(opponent.get("opponent_id","")) == opponent_id:
			opponent_snapshot_id = str(opponent.get("defense_snapshot_id",""))
			break
	if opponent_snapshot_id.is_empty():
		return {"ok":false,"error_code":"OPPONENT_DEFENSE_SNAPSHOT_REQUIRED"}
	return _post("pvp_attack",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_attack"),
		"opponent_id":opponent_id,
		"matchmaking_ticket":matchmaking_ticket,
		"attacker_loadout_snapshot_id":LoadoutSnapshotService.published_snapshot_id,
		"attacker_loadout_revision":maxi(loadout_revision,LoadoutSnapshotService.published_revision),
		"opponent_defense_snapshot_id":opponent_snapshot_id,
		"expected_revision":last_revision
	})

func request_history() -> Dictionary:
	return _post("pvp_history",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_history")
	})

func claim_season_reward() -> Dictionary:
	var claim_id := str(league_snapshot.get("reward_claim_id",""))
	if claim_id.is_empty() or not bool(league_snapshot.get("reward_claimable",false)):
		return {"ok":false,"error_code":"REWARD_NOT_CLAIMABLE"}
	return _post("pvp_claim",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("pvp_claim"),
		"reward_claim_id":claim_id
	})

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func accept_matchmaking_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var ticket := str(envelope.get("matchmaking_ticket",""))
	if ticket.is_empty():
		return false
	matchmaking_ticket = ticket
	if envelope.has("opponents"):
		return accept_opponents_envelope(envelope)
	return true

func accept_defense_snapshot_envelope(envelope: Dictionary) -> bool:
	var accepted := DefenseTeamService.accept_envelope(envelope)
	if accepted:
		defense_snapshot_id = DefenseTeamService.defense_snapshot_id
	return accepted

func accept_season_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < season_revision:
		return false
	var league = envelope.get("league",{})
	if typeof(league) != TYPE_DICTIONARY:
		return false
	league_snapshot = _sanitize_league(league)
	season_revision = revision
	return true

func accept_opponents_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < last_revision:
		return false
	var incoming = envelope.get("opponents",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	opponents.clear()
	for item in incoming:
		if typeof(item) == TYPE_DICTIONARY:
			opponents.append(_sanitize_opponent(item))
	league_snapshot = _sanitize_league(envelope.get("league",{}))
	if envelope.has("matchmaking_ticket"):
		matchmaking_ticket = str(envelope.get("matchmaking_ticket",""))
	last_revision = revision
	opponents_changed.emit()
	return true

func accept_battle_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var revision := int(envelope.get("revision",-1))
	if revision < last_revision:
		return false
	var battle = envelope.get("battle",{})
	if typeof(battle) != TYPE_DICTIONARY:
		return false
	var result := {
		"battle_id":str(battle.get("battle_id","")),
		"opponent_id":str(battle.get("opponent_id","")),
		"result":str(battle.get("result","loss")),
		"rating_delta":int(battle.get("rating_delta",0)),
		"score":maxi(int(battle.get("score",0)),0),
		"reward":Dictionary(battle.get("reward",{})).duplicate(true),
		"revision":revision
	}
	if result.result not in ["win","loss","draw"]:
		return false
	last_revision = revision
	if envelope.has("league"):
		league_snapshot = _sanitize_league(envelope.get("league",{}))
	battle_result_received.emit(result)
	return true

func accept_history_envelope(envelope: Dictionary) -> bool:
	var incoming = envelope.get("history",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	history.clear()
	for item in incoming:
		if typeof(item) == TYPE_DICTIONARY:
			history.append({
				"battle_id":str(item.get("battle_id","")),
				"opponent_name":str(item.get("opponent_name","Spieler")).left(24),
				"result":str(item.get("result","loss")),
				"rating_delta":int(item.get("rating_delta",0)),
				"created_unix":maxi(int(item.get("created_unix",0)),0)
			})
	history_changed.emit()
	return true

func accept_claim_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	pvp_reward_result.emit(envelope)
	return true

func _sanitize_opponent(item: Dictionary) -> Dictionary:
	return {
		"opponent_id":str(item.get("opponent_id","")),
		"display_name":str(item.get("display_name","Spieler")).left(24),
		"level":maxi(int(item.get("level",1)),1),
		"rating":maxi(int(item.get("rating",0)),0),
		"power":maxi(int(item.get("power",0)),0),
		"defense_snapshot_id":str(item.get("defense_snapshot_id",""))
	}

func _sanitize_league(item) -> Dictionary:
	if typeof(item) != TYPE_DICTIONARY:
		return {}
	return {
		"league":str(item.get("league","")),
		"rating":maxi(int(item.get("rating",0)),0),
		"season_id":str(item.get("season_id","")),
		"season_ends_unix":maxi(int(item.get("season_ends_unix",0)),0),
		"reward_claimable":bool(item.get("reward_claimable",false)),
		"reward_claim_id":str(item.get("reward_claim_id",""))
	}


func accept_league_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < season_revision:
		return false
	var league = envelope.get("league",{})
	if typeof(league) != TYPE_DICTIONARY:
		return false
	league_snapshot = _sanitize_league(league)
	season_revision = revision
	return true

func accept_season_progress_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < season_revision:
		return false
	var progress = envelope.get("progress",{})
	if typeof(progress) != TYPE_DICTIONARY:
		return false
	league_progress = {
		"season_id":str(progress.get("season_id","")),
		"current_points":maxi(int(progress.get("current_points",0)),0),
		"next_league_points":maxi(int(progress.get("next_league_points",0)),0),
		"previous_league_points":maxi(int(progress.get("previous_league_points",0)),0),
		"promotion_ready":bool(progress.get("promotion_ready",false)),
		"demotion_risk":bool(progress.get("demotion_risk",false)),
		"wins":maxi(int(progress.get("wins",0)),0),
		"losses":maxi(int(progress.get("losses",0)),0),
		"draws":maxi(int(progress.get("draws",0)),0)
	}
	season_revision = revision
	return true
