extends Node

signal td_changed
signal td_completed(result: Dictionary)

const DATA_PATH := "res://data/tower_defense_v1_29.json"
var config: Dictionary = {}
var wave: int = 1
var energy: int = 4
var towers: int = 0
var enemy_hp: int = 4
var run_completed: bool = false
var run_sequence: int = 0
var pending_run_result: Dictionary = {}

func _ready()->void:
	_load_config()
	_reset_run(false)

func _load_config()->void:
	var f:=FileAccess.open(DATA_PATH,FileAccess.READ)
	if not f: return
	var parsed=JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY: config=parsed

func _wave_hp(index:int)->int:
	var values:Array=config.get("enemy_hp_per_wave",[4,6,8])
	var base:=int(values[clampi(index-1,0,values.size()-1)])
	return base + TowerDefenseProgressionSystem.enemy_hp_bonus()

func _reset_run(emit_change:=true)->void:
	wave=1
	energy=int(config.get("starting_energy",4))
	towers=0
	enemy_hp=_wave_hp(1)
	run_completed=false
	if emit_change: td_changed.emit()

func can_build()->bool:
	return not run_completed and energy>=int(config.get("tower_cost",2)) and towers<int(config.get("max_towers",2))

func build_tower()->Dictionary:
	if not can_build(): return {"ok":false,"message":"Turm aktuell nicht möglich"}
	energy-=int(config.get("tower_cost",2))
	towers+=1
	SaveGame.save_game()
	td_changed.emit()
	return {"ok":true,"towers":towers,"energy":energy}

func defend_tick()->Dictionary:
	if run_completed: return {"ok":false,"message":"Run abgeschlossen"}
	if towers<=0: return {"ok":false,"message":"Baue zuerst einen Turm"}
	var damage=towers*(int(config.get("tower_damage",2)) + TowerDefenseProgressionSystem.tower_damage_bonus())
	enemy_hp=maxi(enemy_hp-damage,0)
	if enemy_hp>0:
		SaveGame.save_game()
		td_changed.emit()
		return {"ok":true,"damage":damage,"wave_cleared":false}
	if wave<int(config.get("waves",3)):
		TowerDefenseProgressionSystem.register_wave_clear()
		wave+=1
		energy+=1
		enemy_hp=_wave_hp(wave)
		SaveGame.save_game()
		td_changed.emit()
		return {"ok":true,"damage":damage,"wave_cleared":true,"next_wave":wave}
	run_completed=true
	TowerDefenseProgressionSystem.register_wave_clear()
	var completed_stage:=TowerDefenseProgressionSystem.campaign_stage
	TowerDefenseProgressionSystem.register_run_completion()
	var reward:Dictionary=config.get("reward",{})
	var gold=maxi(int(reward.get("gold",0)),0)
	var spins=maxi(int(reward.get("spins",0)),0)
	if gold>0: PlayerData.add_gold(gold)
	if spins>0: PlayerData.add_spin(spins)
	run_sequence += 1
	var result={
		"ok":true,
		"completed":true,
		"run_id":"td_%d_%d_%d" % [int(Time.get_unix_time_from_system()),completed_stage,run_sequence],
		"config_version":"v1.49-td-v2-05",
		"result_contract_version":"td-run-result-v1",
		"stage":completed_stage,
		"gold":gold,
		"spins":spins,
		"mastery_xp":TowerDefenseProgressionSystem.mastery_xp,
		"presentation_pending":true
	}
	pending_run_result=result.duplicate(true)
	SaveGame.save_game()
	td_completed.emit(result)
	td_changed.emit()
	return result

func has_pending_run_result() -> bool:
	return not pending_run_result.is_empty()

func peek_pending_run_result() -> Dictionary:
	return pending_run_result.duplicate(true)

func acknowledge_pending_run_result() -> void:
	if pending_run_result.is_empty(): return
	pending_run_result={}
	SaveGame.save_game()

func restart_run()->void:
	_reset_run()
	SaveGame.save_game()

func export_save_data()->Dictionary:
	return {
		"wave":wave,
		"energy":energy,
		"towers":towers,
		"enemy_hp":enemy_hp,
		"run_completed":run_completed,
		"run_sequence":run_sequence,
		"pending_run_result":pending_run_result.duplicate(true)
	}

func apply_save_data(data:Dictionary)->void:
	wave=clampi(int(data.get("wave",1)),1,int(config.get("waves",3)))
	energy=maxi(int(data.get("energy",int(config.get("starting_energy",4)))),0)
	towers=clampi(int(data.get("towers",0)),0,int(config.get("max_towers",2)))
	enemy_hp=maxi(int(data.get("enemy_hp",_wave_hp(wave))),0)
	run_completed=bool(data.get("run_completed",false))
	run_sequence=maxi(int(data.get("run_sequence",0)),0)
	var pending=data.get("pending_run_result",{})
	pending_run_result=pending.duplicate(true) if typeof(pending)==TYPE_DICTIONARY else {}
	td_changed.emit()
