extends Node

signal battle_started
signal battle_updated(state: Dictionary)
signal battle_finished(won: bool, reward: Dictionary)

const DATA_PATH := "res://data/lane_battle_v1_30.json"

var config: Dictionary = {}
var active := false
var time_left := 45.0
var energy := 10.0
var enemy_hp := 100.0
var player_hp := 100.0
var lane_power := [0.0, 0.0]
var enemy_lane_power := [0.0, 0.0]
var lane_push := [0.0, 0.0]
var reward_committed := false
var battle_sequence := 0
var current_battle_id := ""
var current_stage := 1
var pending_battle_result: Dictionary = {}

func _ready() -> void:
	_load_config()
	set_process(false)

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("V1.30 Lane Battle config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func energy_max() -> float:
	return float(config.get("energy_max",10.0))

func unit_cost() -> float:
	return float(config.get("unit_cost",3.0))

func start_battle() -> void:
	active = true
	reward_committed = false
	battle_sequence += 1
	current_stage = LaneBattleProgressionSystem.campaign_stage
	current_battle_id = "lane_%d_%d_%d" % [int(Time.get_unix_time_from_system()),current_stage,battle_sequence]
	time_left = float(config.get("duration_seconds",45.0))
	energy = energy_max()
	enemy_hp = float(config.get("enemy_max_hp",100)) + LaneBattleProgressionSystem.enemy_hp_bonus()
	player_hp = float(config.get("player_max_hp",100))
	lane_power = [0.0, 0.0]
	enemy_lane_power = [
		float(config.get("enemy_pressure_left",0.55)) + LaneBattleProgressionSystem.pressure_bonus(),
		float(config.get("enemy_pressure_right",0.45)) + LaneBattleProgressionSystem.pressure_bonus()
	]
	lane_push = [0.0, 0.0]
	SaveGame.save_game()
	battle_started.emit()
	battle_updated.emit(get_state())
	set_process(true)

func _process(delta: float) -> void:
	if not active:
		return
	time_left = max(0.0, time_left - delta)
	energy = min(energy_max(), energy + float(config.get("energy_regen_per_sec",1.4)) * delta)

	var elapsed := float(config.get("duration_seconds",45.0)) - time_left
	enemy_lane_power[0] = float(config.get("enemy_pressure_left",0.55)) + elapsed * 0.012
	enemy_lane_power[1] = float(config.get("enemy_pressure_right",0.45)) + elapsed * 0.010

	for i in 2:
		if lane_power[i] > 0.0:
			enemy_hp -= lane_power[i] * delta * 0.65
		if enemy_lane_power[i] > 0.0:
			player_hp -= enemy_lane_power[i] * delta * 0.42
		if lane_power[i] > enemy_lane_power[i]:
			lane_push[i] = min(1.0, lane_push[i] + delta * 0.04)
		else:
			lane_push[i] = max(0.0, lane_push[i] - delta * 0.028)

	battle_updated.emit(get_state())

	if enemy_hp <= 0.0:
		_finish(true)
	elif player_hp <= 0.0 or time_left <= 0.0:
		_finish(enemy_hp < player_hp)

func deploy_unit(lane_index: int) -> bool:
	if not active or lane_index < 0 or lane_index > 1:
		return false
	if energy < unit_cost():
		return false
	energy -= unit_cost()
	lane_power[lane_index] += float(config.get("base_unit_power",3.2)) + LaneBattleProgressionSystem.unit_power_bonus()
	LaneBattleProgressionSystem.register_deployment()
	lane_push[lane_index] = min(1.0, lane_push[lane_index] + 0.22)
	SaveGame.save_game()
	battle_updated.emit(get_state())
	return true

# Legacy compatibility for older MainGame hooks.
func deploy_hero(lane_index: int) -> bool:
	return deploy_unit(lane_index)

func _finish(won: bool) -> void:
	if not active:
		return
	active = false
	set_process(false)
	var reward := {"gold":0,"xp":0}
	var completed_stage:=current_stage
	if won and not reward_committed:
		LaneBattleProgressionSystem.register_win()
		var reward_cfg: Dictionary = config.get("reward",{})
		var gold := maxi(int(reward_cfg.get("gold",325)),0)
		var xp := maxi(int(reward_cfg.get("xp",20)),0)
		PlayerData.add_gold(gold)
		PlayerData.add_xp(xp)
		reward = {"gold":gold,"xp":xp}
		reward_committed = true
	var result={
		"battle_id":current_battle_id,
		"config_version":"v1.50-lane-v2-06",
		"result_contract_version":"lane-battle-result-v1",
		"stage":completed_stage,
		"won":won,
		"gold":int(reward.get("gold",0)),
		"xp":int(reward.get("xp",0)),
		"mastery_xp":LaneBattleProgressionSystem.mastery_xp,
		"presentation_pending":true
	}
	pending_battle_result=result.duplicate(true)
	SaveGame.save_game()
	battle_finished.emit(won,result)

func has_pending_battle_result()->bool: return not pending_battle_result.is_empty()
func peek_pending_battle_result()->Dictionary: return pending_battle_result.duplicate(true)
func acknowledge_pending_battle_result()->void:
	if pending_battle_result.is_empty(): return
	pending_battle_result={}
	SaveGame.save_game()


func get_state() -> Dictionary:
	return {
		"active":active,
		"time_left":time_left,
		"energy":energy,
		"enemy_hp":max(0.0,enemy_hp),
		"player_hp":max(0.0,player_hp),
		"lane_power":lane_power.duplicate(),
		"enemy_lane_power":enemy_lane_power.duplicate(),
		"lane_push":lane_push.duplicate()
	}

func export_save_data() -> Dictionary:
	return {
		"active":active,
		"time_left":time_left,
		"energy":energy,
		"enemy_hp":enemy_hp,
		"player_hp":player_hp,
		"lane_power":lane_power.duplicate(),
		"enemy_lane_power":enemy_lane_power.duplicate(),
		"lane_push":lane_push.duplicate(),
		"reward_committed":reward_committed,
		"battle_sequence":battle_sequence,
		"current_battle_id":current_battle_id,
		"current_stage":current_stage,
		"pending_battle_result":pending_battle_result.duplicate(true)
	}

func apply_save_data(data: Dictionary) -> void:
	active = bool(data.get("active",false))
	time_left = clamp(float(data.get("time_left",float(config.get("duration_seconds",45.0)))),0.0,float(config.get("duration_seconds",45.0)))
	energy = clamp(float(data.get("energy",energy_max())),0.0,energy_max())
	enemy_hp = clamp(float(data.get("enemy_hp",float(config.get("enemy_max_hp",100)))),0.0,float(config.get("enemy_max_hp",100)))
	player_hp = clamp(float(data.get("player_hp",float(config.get("player_max_hp",100)))),0.0,float(config.get("player_max_hp",100)))
	var lp: Array = data.get("lane_power",[0.0,0.0])
	var ep: Array = data.get("enemy_lane_power",[0.55,0.45])
	var push: Array = data.get("lane_push",[0.0,0.0])
	lane_power = [float(lp[0]),float(lp[1])] if lp.size() >= 2 else [0.0,0.0]
	enemy_lane_power = [float(ep[0]),float(ep[1])] if ep.size() >= 2 else [0.55,0.45]
	lane_push = [clamp(float(push[0]),0.0,1.0),clamp(float(push[1]),0.0,1.0)] if push.size() >= 2 else [0.0,0.0]
	reward_committed = bool(data.get("reward_committed",false))
	battle_sequence=maxi(int(data.get("battle_sequence",0)),0)
	current_battle_id=str(data.get("current_battle_id",""))
	current_stage=clampi(int(data.get("current_stage",LaneBattleProgressionSystem.campaign_stage)),1,LaneBattleProgressionSystem.stage_count())
	var pending=data.get("pending_battle_result",{})
	pending_battle_result=pending.duplicate(true) if typeof(pending)==TYPE_DICTIONARY else {}
	set_process(active)
	battle_updated.emit(get_state())
