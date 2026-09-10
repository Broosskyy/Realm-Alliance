extends Node

signal liveops_changed
signal ranking_changed
signal halloween_changed

const DATA_PATH := "res://data/liveops_v1_44.json"
const CONFIG_VERSION := "v1.46-halloween-liveops-02"

var config: Dictionary = {}
var selected_board: String = "daily"
var halloween_points: int = 0
var halloween_reward_claimed: bool = false
var halloween_tokens: int = 0
var halloween_metrics: Dictionary = {"boss_defeat":0,"journey_lap":0,"puzzle_match":0,"spin":0,"td_wave":0,"lane_win":0}
var halloween_quest_claimed: Array[String] = []
var halloween_chests_opened: int = 0
var last_server_snapshot: Dictionary = {}

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f:
		push_error("LiveOps V1.44 config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:
		config = parsed

func select_board(board_type: String) -> void:
	if board_type not in ["daily","weekly","event"]:
		return
	selected_board = board_type
	ranking_changed.emit()

func board_config(board_type: String = "") -> Dictionary:
	var key := selected_board if board_type.is_empty() else board_type
	return config.get("leaderboards",{}).get(key,{})

func ranking_status_text() -> String:
	var board := board_config()
	var title := selected_board.to_upper()
	if last_server_snapshot.is_empty():
		return "%s · RANGLISTE\nOnline-Rangliste ist in dieser Testversion noch nicht aktiv.\nDein Boss-Fortschritt: %d" % [title,MetaProgressSystem.boss_defeats]
	return "%s · RANG %d · SCORE %d" % [
		title,
		int(last_server_snapshot.get("rank",0)),
		int(last_server_snapshot.get("score",0))
	]

func ranking_reward_preview() -> String:
	var rows: Array = board_config().get("reward_preview",[])
	var lines: Array[String] = []
	for row in rows:
		var r1 := int(row.get("rank_min",0))
		var r2 := int(row.get("rank_max",0))
		lines.append("RANG %d–%d · %d GOLD · %d SPINS" % [
			r1,r2,int(row.get("gold",0)),int(row.get("spins",0))
		])
	if lines.is_empty():
		return "Keine Belohnung konfiguriert"
	return "\n".join(lines)

func can_claim_ranking_reward() -> bool:
	# Never trust client-only leaderboard position/reward.
	return bool(last_server_snapshot.get("signed_reward_claimable",false))

func claim_ranking_reward() -> Dictionary:
	if not can_claim_ranking_reward():
		return {"ok":false,"message":"Ranglisten-Belohnung benötigt autoritative Server-Bestätigung"}
	return {"ok":false,"message":"Online-Belohnung ist in dieser Testversion noch nicht aktiv"}

func register_boss_defeat() -> void:
	register_event_action("boss_defeat",1)

func register_journey_lap() -> void:
	register_event_action("journey_lap",1)

func register_puzzle_match(amount: int = 1) -> void:
	register_event_action("puzzle_match",amount)

func register_spin() -> void:
	register_event_action("spin",1)

func register_td_wave() -> void:
	register_event_action("td_wave",1)

func register_lane_win() -> void:
	register_event_action("lane_win",1)

func register_event_action(metric: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	var event: Dictionary = config.get("halloween_2026", {})
	if event.is_empty():
		return
	if not halloween_metrics.has(metric):
		return
	halloween_metrics[metric] = maxi(int(halloween_metrics.get(metric,0)) + amount,0)
	if metric == "boss_defeat":
		halloween_points += amount
	var points := int(event.get("point_sources",{}).get(metric,0)) * amount
	if points > 0:
		halloween_tokens = mini(halloween_tokens + points,halloween_token_cap())
	halloween_changed.emit()
	liveops_changed.emit()

func halloween_target() -> int:
	return maxi(int(config.get("halloween_2026",{}).get("target",10)),1)

func halloween_progress_text() -> String:
	return "EVENT-FORTSCHRITT · %d / %d BOSSE" % [mini(halloween_points,halloween_target()),halloween_target()]

func halloween_state() -> String:
	var event: Dictionary = config.get("halloween_2026", {})
	if event.is_empty():
		return "missing"
	var now := ServerClockService.now_unix()
	var start := int(Time.get_unix_time_from_datetime_string(str(event.get("start_utc","2026-10-20T00:00:00Z"))))
	var end := int(Time.get_unix_time_from_datetime_string(str(event.get("end_utc","2026-11-03T23:59:59Z"))))
	if now < start:
		return "scheduled"
	if now > end:
		return "ended"
	return "active"

func halloween_status_text() -> String:
	match halloween_state():
		"scheduled": return "GEPLANT · 20.10.–03.11.2026"
		"active": return "JETZT AKTIV"
		"ended": return "EVENT BEENDET"
	return "EVENT NICHT GELADEN"

func can_claim_halloween_reward() -> bool:
	return halloween_state()=="active" and not halloween_reward_claimed and halloween_points >= halloween_target()

func claim_halloween_reward() -> Dictionary:
	if not can_claim_halloween_reward():
		return {"ok":false,"message":"Halloween-Belohnung noch nicht verfügbar"}
	var reward: Dictionary = config.get("halloween_2026",{}).get("reward",{})
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var authority_intent := OnlineAuthorityService.build_intent("liveops_event_reward_claim", {
		"event_id":"halloween_2026","points":halloween_points
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins},
		{"halloween_reward_claimed":true}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Event-Belohnung konnte nicht bestätigt werden"))}
	halloween_reward_claimed = true
	SaveGame.save_game()
	halloween_changed.emit()
	return {"ok":true,"gold":gold,"spins":spins,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func halloween_token_cap() -> int:
	return maxi(int(config.get("halloween_2026",{}).get("event_currency",{}).get("cap",9999)),1)

func halloween_quest_rows() -> Array:
	var rows: Array = []
	for quest in config.get("halloween_2026",{}).get("quests",[]):
		var q: Dictionary = quest
		var qid := str(q.get("id",""))
		var metric := str(q.get("metric",""))
		var value := int(halloween_metrics.get(metric,0))
		var target := maxi(int(q.get("target",1)),1)
		rows.append({
			"id":qid,
			"title":str(q.get("title",qid)),
			"value":mini(value,target),
			"target":target,
			"reward_tokens":int(q.get("reward_tokens",0)),
			"ready":value >= target and not halloween_quest_claimed.has(qid),
			"claimed":halloween_quest_claimed.has(qid)
		})
	return rows

func halloween_quests_text() -> String:
	var lines: Array[String] = []
	for row in halloween_quest_rows():
		var state := "✓" if bool(row.get("claimed",false)) else ("BEREIT" if bool(row.get("ready",false)) else "")
		lines.append("%s · %d/%d · +%d MARKEN %s" % [
			str(row.get("title","")),
			int(row.get("value",0)),
			int(row.get("target",1)),
			int(row.get("reward_tokens",0)),
			state
		])
	return "\n".join(lines)

func claim_ready_halloween_quests() -> Dictionary:
	if halloween_state() != "active":
		return {"ok":false,"message":"Halloween-Quests sind nur im aktiven Event einlösbar"}
	var granted := 0
	var claimed_now: Array[String] = []
	for row in halloween_quest_rows():
		if not bool(row.get("ready",false)):
			continue
		var qid := str(row.get("id",""))
		var amount := maxi(int(row.get("reward_tokens",0)),0)
		granted += amount
		claimed_now.append(qid)
	if claimed_now.is_empty():
		return {"ok":false,"message":"Noch keine Halloween-Quest bereit"}
	var next_tokens := mini(halloween_tokens + granted,halloween_token_cap())
	var authority_intent := OnlineAuthorityService.build_intent("liveops_quest_reward_claim", {
		"event_id":"halloween_2026","quest_ids":claimed_now,"tokens":granted
	})
	var authority_result := EconomyAuthorityService.commit_domain_state_local(
		authority_intent,
		{"halloween_tokens":next_tokens,"claimed_quests":claimed_now},
		{"tokens":granted,"quests":claimed_now}
	)
	if not bool(authority_result.get("ok",false)):
		return {"ok":false,"message":str(authority_result.get("message","Event-Quests konnten nicht bestätigt werden"))}
	for qid in claimed_now:
		if not halloween_quest_claimed.has(qid):
			halloween_quest_claimed.append(qid)
	halloween_tokens = next_tokens
	SaveGame.save_game()
	halloween_changed.emit()
	return {"ok":true,"tokens":granted,"quests":claimed_now,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(authority_result.get("revision",0))}
func halloween_chest_status_text() -> String:
	var chest: Dictionary = config.get("halloween_2026",{}).get("event_chest",{})
	return "EVENT-TRUHE · %d / %d KÜRBISMARKEN" % [halloween_tokens,int(chest.get("cost_tokens",50))]

func can_open_halloween_chest() -> bool:
	var cost := maxi(int(config.get("halloween_2026",{}).get("event_chest",{}).get("cost_tokens",50)),1)
	return halloween_state()=="active" and halloween_tokens >= cost

func open_halloween_chest() -> Dictionary:
	if not can_open_halloween_chest():
		return {"ok":false,"message":"Nicht genug Kürbismarken oder Event nicht aktiv"}
	var chest: Dictionary = config.get("halloween_2026",{}).get("event_chest",{})
	var cost := maxi(int(chest.get("cost_tokens",50)),1)
	var reward: Dictionary = chest.get("reward",{})
	var next_tokens := halloween_tokens - cost
	var next_opened := halloween_chests_opened + 1
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var authority_intent := OnlineAuthorityService.build_intent("liveops_event_chest_open", {
		"event_id":"halloween_2026","cost_tokens":cost,"tokens_before":halloween_tokens
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins},
		{"halloween_tokens":next_tokens,"halloween_chests_opened":next_opened}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Event-Truhe konnte nicht bestätigt werden"))}
	halloween_tokens = next_tokens
	halloween_chests_opened = next_opened
	SaveGame.save_game()
	halloween_changed.emit()
	return {"ok":true,"gold":gold,"spins":spins,"opened":halloween_chests_opened,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func export_save_data() -> Dictionary:
	return {
		"selected_board":selected_board,
		"halloween_points":halloween_points,
		"halloween_reward_claimed":halloween_reward_claimed,
		"halloween_tokens":halloween_tokens,
		"halloween_metrics":halloween_metrics.duplicate(true),
		"halloween_quest_claimed":halloween_quest_claimed.duplicate(),
		"halloween_chests_opened":halloween_chests_opened
	}

func apply_save_data(data: Dictionary) -> void:
	selected_board = str(data.get("selected_board","daily"))
	if selected_board not in ["daily","weekly","event"]:
		selected_board = "daily"
	halloween_points = maxi(int(data.get("halloween_points",0)),0)
	halloween_reward_claimed = bool(data.get("halloween_reward_claimed",false))
	halloween_tokens = clampi(int(data.get("halloween_tokens",0)),0,halloween_token_cap())
	var incoming_metrics = data.get("halloween_metrics",{})
	if typeof(incoming_metrics)==TYPE_DICTIONARY:
		for metric in halloween_metrics.keys():
			halloween_metrics[metric]=maxi(int(incoming_metrics.get(metric,0)),0)
	halloween_quest_claimed.clear()
	for item in data.get("halloween_quest_claimed",[]):
		var qid := str(item)
		if not qid.is_empty() and not halloween_quest_claimed.has(qid):
			halloween_quest_claimed.append(qid)
	halloween_chests_opened=maxi(int(data.get("halloween_chests_opened",0)),0)
	liveops_changed.emit()


func apply_server_ranking_snapshot(board: String, snapshot: Dictionary) -> void:
	if board not in ["daily","weekly","event"]:
		return
	if board == selected_board:
		last_server_snapshot = snapshot.duplicate(true)
	ranking_changed.emit()
