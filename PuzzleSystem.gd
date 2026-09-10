extends Node

signal puzzle_changed
signal puzzle_completed(result: Dictionary)

const DATA_PATH := "res://data/puzzle_v1_28.json"
var config: Dictionary = {}
var board: Array[int] = []
var attempts: int = 3
var matches_completed: int = 0
var selected_index: int = -1
var session_seed: int = 12801
var attempts_day_utc: int = -1
var completion_sequence: int = 0
var pending_completion: Dictionary = {}

func _ready() -> void:
	_load_config()
	if board.is_empty():
		_generate_board()

func _load_config() -> void:
	var f:=FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f: return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:
		config=parsed
		attempts=maxi(attempts,0)

func _utc_day_key() -> int:
	return int(int(Time.get_unix_time_from_system()) / 86400)

func ensure_daily_attempts() -> bool:
	var today := _utc_day_key()
	if attempts_day_utc == today:
		return false
	attempts_day_utc = today
	attempts = maxi(int(config.get("daily_free_attempts",3)),0)
	selected_index = -1
	puzzle_changed.emit()
	return true

func _generate_board() -> void:
	board=[0,1,2,1,2,0,2,0,1]
	selected_index=-1

func symbol_name(value:int)->String:
	var symbols:Array=config.get("symbols",["leaf","crystal","coin"])
	return str(symbols[clampi(value,0,symbols.size()-1)])

func tap_cell(index:int)->Dictionary:
	var daily_reset := ensure_daily_attempts()
	if daily_reset:
		SaveGame.save_game()
	if attempts<=0:
		return {"ok":false,"message":"Keine Puzzle-Versuche"}
	if index<0 or index>=board.size():
		return {"ok":false,"message":"Ungültiges Feld"}
	if selected_index<0:
		selected_index=index
		puzzle_changed.emit()
		return {"ok":true,"selected":true}
	if selected_index==index:
		selected_index=-1
		puzzle_changed.emit()
		return {"ok":true,"selected":false}
	if not _adjacent(selected_index,index):
		selected_index=index
		puzzle_changed.emit()
		return {"ok":true,"selected":true}
	var a:=selected_index
	selected_index=-1
	var temp=board[a]
	board[a]=board[index]
	board[index]=temp
	if not _has_match():
		temp=board[a]
		board[a]=board[index]
		board[index]=temp
		puzzle_changed.emit()
		return {"ok":false,"message":"Kein 3er-Match"}
	attempts-=1
	matches_completed+=1
	PuzzleProgressionSystem.register_match()
	_resolve_board()
	var completed:=matches_completed>=PuzzleProgressionSystem.target_matches()
	var result={"ok":true,"match":true,"completed":completed,"matches":matches_completed}
	if completed:
		completion_sequence += 1
		var completed_stage:=PuzzleProgressionSystem.stage
		var reward:Dictionary=config.get("reward",{})
		var gold:=maxi(int(reward.get("gold",0)),0)
		var spins:=maxi(int(reward.get("spins",0)),0)
		if gold>0: PlayerData.add_gold(gold)
		if spins>0: PlayerData.add_spin(spins)
		PuzzleProgressionSystem.register_completion()
		matches_completed=0
		result["completion_id"]="puzzle_%d_%d_%d" % [int(Time.get_unix_time_from_system()),completed_stage,completion_sequence]
		result["config_version"]="v1.48-puzzle-v2-04"
		result["result_contract_version"]="puzzle-complete-v1"
		result["stage"]=completed_stage
		result["gold"]=gold
		result["spins"]=spins
		result["mastery_xp"]=PuzzleProgressionSystem.mastery_xp
		result["presentation_pending"]=true
		pending_completion=result.duplicate(true)
		SaveGame.save_game()
		puzzle_completed.emit(result)
	else:
		SaveGame.save_game()
	puzzle_changed.emit()
	return result

func has_pending_completion() -> bool:
	return not pending_completion.is_empty()

func peek_pending_completion() -> Dictionary:
	return pending_completion.duplicate(true)

func acknowledge_pending_completion() -> void:
	if pending_completion.is_empty(): return
	pending_completion={}
	SaveGame.save_game()

func _adjacent(a:int,b:int)->bool:
	var ar:=a/3
	var ac:=a%3
	var br:=b/3
	var bc:=b%3
	return abs(ar-br)+abs(ac-bc)==1

func _has_match()->bool:
	for r in range(3):
		var i=r*3
		if board[i]==board[i+1] and board[i]==board[i+2]: return true
	for c in range(3):
		if board[c]==board[c+3] and board[c]==board[c+6]: return true
	return false

func _resolve_board()->void:
	# Small deterministic refill keeps V1.28 reproducible and avoids hidden near-miss manipulation.
	session_seed+=1
	for i in range(board.size()):
		board[i]=(board[i]+i+session_seed)%3
	if _has_match():
		board=[0,1,2,1,2,0,2,0,1]

func export_save_data()->Dictionary:
	return {
		"board":board.duplicate(),
		"attempts":attempts,
		"matches_completed":matches_completed,
		"session_seed":session_seed,
		"attempts_day_utc":attempts_day_utc,
		"completion_sequence":completion_sequence,
		"pending_completion":pending_completion.duplicate(true)
	}

func apply_save_data(data:Dictionary)->void:
	var incoming:Array=data.get("board",[])
	if incoming.size()==9:
		board=incoming.duplicate()
	else:
		_generate_board()
	attempts=clampi(int(data.get("attempts",int(config.get("daily_free_attempts",3)))),0,99)
	attempts_day_utc=int(data.get("attempts_day_utc",-1))
	matches_completed=clampi(int(data.get("matches_completed",0)),0,maxi(PuzzleProgressionSystem.target_matches()-1,0))
	session_seed=int(data.get("session_seed",12801))
	completion_sequence=maxi(int(data.get("completion_sequence",0)),0)
	var pending=data.get("pending_completion",{})
	pending_completion=pending.duplicate(true) if typeof(pending)==TYPE_DICTIONARY else {}
	selected_index=-1
	puzzle_changed.emit()
