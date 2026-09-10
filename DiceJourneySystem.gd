extends Node

signal journey_changed
signal dice_rolled(result: Dictionary)
signal portal_opened(result: Dictionary)

const DATA_PATH := "res://data/dice_journey_greenvale_v1_26.json"
const CONFIG_VERSION := "v1.47-journey-progression-03"
const RESULT_CONTRACT_VERSION := "journey-result-v1"

var config: Dictionary = {}
var position: int = 0
var dice: int = 3
var portal_charges: int = 0
var laps_completed: int = 0
var transaction_active: bool = false
var roll_sequence: int = 0
var pending_result: Dictionary = {}

func _ready() -> void:
	_load_config()
	if dice < 0:
		dice = starting_dice()

func _load_config() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		push_error("V1.26 DICE/Journey config missing")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		dice = clampi(dice, 0, max_dice())

func board_nodes() -> int:
	return maxi(int(config.get("board_nodes",12)),1)

func starting_dice() -> int:
	return maxi(int(config.get("starting_dice",3)),0)

func max_dice() -> int:
	return maxi(int(config.get("max_dice",5)),1)

func grant_dice(amount: int) -> void:
	if amount <= 0:
		return
	dice = mini(dice + amount, max_dice())
	journey_changed.emit()

func has_pending_result() -> bool:
	return not pending_result.is_empty()

func peek_pending_result() -> Dictionary:
	return pending_result.duplicate(true)

func acknowledge_pending_result() -> void:
	if pending_result.is_empty():
		return
	pending_result = {}
	SaveGame.save_game()
	journey_changed.emit()

func _next_seed() -> int:
	roll_sequence += 1
	return absi(int(Time.get_unix_time_from_system()) * 1000033 + int(Time.get_ticks_usec()) + roll_sequence * 131)

func _roll_id(seed: int) -> String:
	return "journey_%d_%d_%d" % [int(Time.get_unix_time_from_system()),roll_sequence,seed]

func roll() -> Dictionary:
	if transaction_active:
		return {"ok":false,"message":"Wurf wird bereits verarbeitet"}
	if dice <= 0:
		return {"ok":false,"message":"Keine Würfel verfügbar"}
	transaction_active = true
	dice -= 1

	var roll_seed := _next_seed()
	var rng := RandomNumberGenerator.new()
	rng.seed = roll_seed
	var value := rng.randi_range(1,6)
	var old_position := position
	var absolute := position + value
	var crossed_lap := absolute >= board_nodes()
	position = absolute % board_nodes()
	if crossed_lap:
		laps_completed += 1
		portal_charges += maxi(int(config.get("lap_portal_charge",1)),0)

	var reward := _grant_node_reward(position + 1)
	var result := {
		"ok":true,
		"roll_id":_roll_id(roll_seed),
		"roll_seed":roll_seed,
		"config_version":CONFIG_VERSION,
		"result_contract_version":RESULT_CONTRACT_VERSION,
		"roll":value,
		"from_position":old_position,
		"to_position":position,
		"node":position + 1,
		"crossed_lap":crossed_lap,
		"portal_charges":portal_charges,
		"reward":reward,
		"presentation_pending":true
	}
	JourneyProgressionSystem.register_roll(result)
	pending_result = result.duplicate(true)
	SaveGame.save_game()
	dice_rolled.emit(result)
	journey_changed.emit()
	transaction_active = false
	return result

func _grant_node_reward(node: int) -> Dictionary:
	for entry in config.get("node_rewards",[]):
		if int(entry.get("node",0)) != node:
			continue
		var kind := str(entry.get("type",""))
		var amount := maxi(int(entry.get("amount",0)),0)
		match kind:
			"gold":
				PlayerData.add_gold(amount)
				return {"reward_id":"journey_node_%d_gold" % node,"type":"gold","amount":amount}
			"spin":
				PlayerData.add_spin(amount)
				return {"reward_id":"journey_node_%d_spin" % node,"type":"spin","amount":amount}
	return {"reward_id":"journey_node_%d_none" % node,"type":"none","amount":0}

func open_treasure_portal() -> Dictionary:
	if transaction_active:
		return {"ok":false,"message":"Aktion läuft bereits"}
	if portal_charges <= 0:
		return {"ok":false,"message":"Portal noch nicht geladen"}
	transaction_active = true
	portal_charges -= 1
	var reward: Dictionary = config.get("portal_reward",{})
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	if gold > 0:
		PlayerData.add_gold(gold)
	if spins > 0:
		PlayerData.add_spin(spins)
	var result := {
		"ok":true,
		"portal_result_id":"portal_%d_%d" % [int(Time.get_unix_time_from_system()),portal_charges],
		"config_version":CONFIG_VERSION,
		"gold":gold,
		"spins":spins,
		"portal_charges":portal_charges
	}
	JourneyProgressionSystem.register_portal_open()
	SaveGame.save_game()
	portal_opened.emit(result)
	journey_changed.emit()
	transaction_active = false
	return result

func export_save_data() -> Dictionary:
	return {
		"position":position,
		"dice":dice,
		"portal_charges":portal_charges,
		"laps_completed":laps_completed,
		"roll_sequence":roll_sequence,
		"pending_result":pending_result.duplicate(true)
	}

func apply_save_data(data: Dictionary) -> void:
	position = clampi(int(data.get("position",0)),0,board_nodes()-1)
	dice = clampi(int(data.get("dice",starting_dice())),0,max_dice())
	portal_charges = maxi(int(data.get("portal_charges",0)),0)
	laps_completed = maxi(int(data.get("laps_completed",0)),0)
	roll_sequence = maxi(int(data.get("roll_sequence",0)),0)
	var incoming = data.get("pending_result",{})
	pending_result = incoming.duplicate(true) if typeof(incoming)==TYPE_DICTIONARY else {}
	journey_changed.emit()
