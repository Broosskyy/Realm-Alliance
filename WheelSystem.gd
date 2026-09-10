extends Node

signal spin_resolved(segment_index: int, result: Dictionary)

const CONFIG_PATH := "res://data/spin_3reel_v2_0.json"
const CONFIG_VERSION := "v2.0-3reel-p0-06"
const RESULT_CONTRACT_VERSION := "spin-result-v1"

var segments: Array = []
var spin_transaction_active: bool = false
var spin_sequence: int = 0

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not file:
		push_error("3-reel SPIN config missing")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		segments = parsed.get("segments", [])

func total_weight() -> int:
	var total := 0
	for segment in segments:
		total += maxi(int(segment.get("weight",0)), 0)
	return total

func _weighted_index(rng: RandomNumberGenerator) -> int:
	var total := total_weight()
	if total <= 0:
		return 0
	var roll := rng.randi_range(1,total)
	var cursor := 0
	for i in range(segments.size()):
		cursor += maxi(int(segments[i].get("weight",0)),0)
		if roll <= cursor:
			return i
	return maxi(segments.size() - 1, 0)

func _segment_index_by_id(segment_id: String) -> int:
	for i in range(segments.size()):
		if str(segments[i].get("id","")) == segment_id:
			return i
	return 0

func _build_reel_stops(symbol_index: int) -> Array:
	# The complete visible center payline mirrors the booked reward family.
	return [symbol_index,symbol_index,symbol_index]

func _build_reel_outcomes(stops: Array, symbol_id: String) -> Array:
	var outcomes: Array = []
	for reel_index in range(3):
		var stop_index := int(stops[reel_index]) if reel_index < stops.size() else 0
		outcomes.append({
			"reel_index":reel_index,
			"stop_index":stop_index,
			"stop_id":"reel_%d_stop_%d_%s" % [reel_index + 1,stop_index,symbol_id],
			"symbol_id":symbol_id,
			"payline_row":1
		})
	return outcomes

func _next_spin_seed() -> int:
	spin_sequence += 1
	var now := ServerClockService.now_unix()
	var ticks := int(Time.get_ticks_usec())
	return absi(now * 1000003 + ticks + spin_sequence * 97)

func _result_id(seed: int) -> String:
	return "spin_%d_%d_%d" % [ServerClockService.now_unix(),spin_sequence,seed]

func spin() -> Dictionary:
	if spin_transaction_active:
		return {"ok":false,"message":"Spin wird bereits verarbeitet"}
	if PlayerData.spins <= 0:
		return {"ok":false,"message":"Keine Spins verfügbar"}
	if segments.is_empty():
		return {"ok":false,"message":"Realm Spin nicht geladen"}
	if total_weight() <= 0:
		return {"ok":false,"message":"SPIN-Gewichte ungültig"}

	if OnlineAuthorityService.mode == "online":
		var remote_started := RemoteGameplayService.request_spin()
		if not bool(remote_started.get("ok",false)):
			return {
				"ok":false,
				"message":"SPIN konnte nicht online bestätigt werden",
				"error_code":str(remote_started.get("error_code","REMOTE_SPIN_FAILED"))
			}
		return {
			"ok":true,
			"pending":true,
			"authority":"server_pending",
			"authority_request_id":str(remote_started.get("request_id","")),
			"message":"SPIN wird bestätigt …"
		}

	spin_transaction_active = true
	var authority_intent := OnlineAuthorityService.build_intent("realm_spin", {
		"spins_before":PlayerData.spins,
		"config_version":CONFIG_VERSION,
		"result_contract_version":RESULT_CONTRACT_VERSION
	})
	var outcome_seed := _next_spin_seed()
	var outcome_rng := RandomNumberGenerator.new()
	outcome_rng.seed = outcome_seed

	# Authority order: choose weighted reward first, grant exactly once, then build visuals.
	var segment_index := _weighted_index(outcome_rng)
	var segment: Dictionary = segments[segment_index]
	var result := _resolve_reward(segment,outcome_rng)

	var legacy_segment_id := str(segment.get("id",""))
	var visual_symbol_id := str(result.get("visual_symbol_id",legacy_segment_id))
	var visual_index := _segment_index_by_id(visual_symbol_id)
	var stops := _build_reel_stops(visual_index)
	var visual_seed := absi(outcome_seed ^ 0x5A17C3)

	result["ok"] = true
	result["result_id"] = _result_id(outcome_seed)
	result["reward_id"] = str(result.get("reward_id",legacy_segment_id))
	result["reward_type"] = str(result.get("reward_type",result.get("type","none")))
	result["reward_value"] = int(result.get("reward_value",result.get("amount",0)))
	result["segment_index"] = segment_index
	result["segment_id"] = legacy_segment_id # legacy alias for saves/telemetry only
	result["weight"] = int(segment.get("weight",0))
	result["reel_stops"] = stops
	result["reel_stop_ids"] = [
		"reel_1_stop_%d_%s" % [int(stops[0]),visual_symbol_id],
		"reel_2_stop_%d_%s" % [int(stops[1]),visual_symbol_id],
		"reel_3_stop_%d_%s" % [int(stops[2]),visual_symbol_id]
	]
	result["outcomes"] = _build_reel_outcomes(stops,visual_symbol_id)
	result["visual_symbol_id"] = visual_symbol_id
	result["visual_symbol_index"] = visual_index
	result["outcome_seed"] = outcome_seed
	result["visual_seed"] = visual_seed
	result["payline_row"] = 1
	result["payline_reel"] = 1 # legacy compatibility
	result["payline_match"] = true
	result["presentation"] = "three_reel_machine"
	result["config_version"] = CONFIG_VERSION
	result["result_contract_version"] = RESULT_CONTRACT_VERSION
	result["authority_request_id"] = str(authority_intent.get("request_id",""))

	var economy_result := EconomyAuthorityService.commit_spin_local(authority_intent, result)
	if not bool(economy_result.get("ok",false)):
		spin_transaction_active = false
		return {
			"ok":false,
			"message":str(economy_result.get("message","Spin konnte nicht bestätigt werden")),
			"error_code":str(economy_result.get("error_code","AUTHORITY_REJECTED"))
		}
	result["authority_revision"] = int(economy_result.get("revision",0))
	result["authority"] = "local_development"

	SpinPresentationState.set_pending_result(result, CONFIG_VERSION)
	SaveGame.save_game()
	spin_resolved.emit(segment_index,result)
	spin_transaction_active = false
	return result

func _resolve_reward(segment: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var segment_id := str(segment.get("id",""))
	var reward_type := str(segment.get("reward_type",""))
	match reward_type:
		"gold":
			var amount := rng.randi_range(int(segment.get("amount_min",0)), int(segment.get("amount_max",0)))
			return {
				"type":"gold","amount":amount,"message":"+%d Gold" % amount,
				"reward_id":segment_id,"reward_type":"gold","reward_value":amount,
				"visual_symbol_id":segment_id
			}
		"shield":
			if PlayerData.shields >= GameConfig.MAX_SHIELDS:
				var fallback_amount := 150
				return {
					"type":"gold_fallback","amount":fallback_amount,"message":"Schilde voll · +150 Gold",
					"reward_id":"shield_full_gold_fallback","reward_type":"gold_fallback","reward_value":fallback_amount,
					"visual_symbol_id":"gold_medium"
				}
			return {
				"type":"shield","amount":1,"message":"+1 Schild",
				"reward_id":"shield","reward_type":"shield","reward_value":1,
				"visual_symbol_id":"shield"
			}
		"spins":
			var base_amount := int(segment.get("amount",2))
			var amount := maxi(base_amount, P0VillageSystem.luck_bonus_spin_amount())
			return {
				"type":"spins","amount":amount,
				"message":"+%d Spins · Glückstempel LV.%d" % [amount,P0VillageSystem.get_level("lucktemple")],
				"reward_id":segment_id,"reward_type":"spins","reward_value":amount,
				"visual_symbol_id":segment_id
			}
		"fallback_gold":
			var amount := int(segment.get("amount",180))
			return {
				"type":"gold_fallback","amount":amount,"message":"+%d Gold" % amount,
				"reward_id":segment_id,"reward_type":"gold_fallback","reward_value":amount,
				"visual_symbol_id":segment_id
			}
		"special_gold":
			var amount := int(segment.get("amount",600))
			return {
				"type":"special","amount":amount,"message":"JACKPOT · +%d Gold" % amount,
				"reward_id":segment_id,"reward_type":"special_gold","reward_value":amount,
				"visual_symbol_id":segment_id
			}
	return {
		"type":"none","amount":0,"message":"Belohnung",
		"reward_id":segment_id,"reward_type":"none","reward_value":0,
		"visual_symbol_id":segment_id
	}
