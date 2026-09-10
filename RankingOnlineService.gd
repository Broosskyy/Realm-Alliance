extends Node

signal ranking_snapshot_changed(board: String)
signal ranking_claim_result(result: Dictionary)

const CONTRACT_VERSION := "ranking-service-v1"
var snapshots: Dictionary = {}

func request_board(board: String) -> Dictionary:
	if board not in ["daily","weekly","event"]:
		return {"ok":false,"error_code":"INVALID_BOARD"}
	return _post("ranking_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("ranking_snapshot"),
		"board":board
	})

func claim_reward(board: String) -> Dictionary:
	if board not in ["daily","weekly","event"]:
		return {"ok":false,"error_code":"INVALID_BOARD"}
	return _post("ranking_claim",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("ranking_claim"),
		"board":board
	})

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func accept_ranking_envelope(envelope: Dictionary) -> bool:
	var board := str(envelope.get("board",""))
	if board not in ["daily","weekly","event"]:
		return false
	var revision := int(envelope.get("revision",-1))
	var existing: Dictionary = snapshots.get(board,{})
	if revision < int(existing.get("revision",-1)):
		return false
	var rows: Array[Dictionary] = []
	for item in envelope.get("top",[]):
		if typeof(item) == TYPE_DICTIONARY:
			rows.append({
				"rank":maxi(int(item.get("rank",0)),0),
				"player_id":str(item.get("player_id","")),
				"display_name":str(item.get("display_name","Spieler")).left(24),
				"score":maxi(int(item.get("score",0)),0)
			})
	var sanitized := {
		"board":board,
		"revision":revision,
		"rank":maxi(int(envelope.get("rank",0)),0),
		"score":maxi(int(envelope.get("score",0)),0),
		"signed_reward_claimable":bool(envelope.get("signed_reward_claimable",false)),
		"reward_claim_id":str(envelope.get("reward_claim_id","")),
		"top":rows
	}
	snapshots[board] = sanitized
	LiveOpsRankingSystem.apply_server_ranking_snapshot(board,sanitized)
	ranking_snapshot_changed.emit(board)
	return true

func accept_claim_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var board := str(envelope.get("board",""))
	if board not in ["daily","weekly","event"]:
		return false
	ranking_claim_result.emit(envelope)
	return true

func snapshot(board: String) -> Dictionary:
	return Dictionary(snapshots.get(board,{})).duplicate(true)
