extends Node

signal journey_progression_changed
signal mastery_level_up(level: int)

const CONFIG_PATH := "res://data/dice_journey_greenvale_v1_26.json"
const CONFIG_VERSION := "v1.47-journey-progression-03"

var config: Dictionary = {}
var mastery_xp: int = 0
var mastery_level: int = 1
var relic_shards: int = 0
var claimed_mastery_levels: Array[int] = []
var caches_opened: int = 0

func _ready() -> void:
	_load_config()
	_recalculate_level(false)

func _load_config() -> void:
	var f := FileAccess.open(CONFIG_PATH,FileAccess.READ)
	if not f:
		push_error("Journey progression config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed)==TYPE_DICTIONARY:
		config = parsed

func mastery_config() -> Dictionary:
	return config.get("journey_mastery",{})

func max_level() -> int:
	return maxi(int(mastery_config().get("max_level",5)),1)

func thresholds() -> Array:
	return mastery_config().get("level_thresholds",[0,5,12,22,35])

func xp_for_level(level: int) -> int:
	var t := thresholds()
	var idx := clampi(level-1,0,maxi(t.size()-1,0))
	return int(t[idx]) if not t.is_empty() else 0

func xp_for_next_level() -> int:
	if mastery_level >= max_level():
		return xp_for_level(max_level())
	return xp_for_level(mastery_level+1)

func progress_ratio() -> float:
	if mastery_level >= max_level():
		return 1.0
	var current_floor := xp_for_level(mastery_level)
	var target := xp_for_next_level()
	if target <= current_floor:
		return 1.0
	return clamp(float(mastery_xp-current_floor)/float(target-current_floor),0.0,1.0)

func register_roll(result: Dictionary) -> void:
	if not bool(result.get("ok",false)):
		return
	var xp := maxi(int(mastery_config().get("roll_xp",1)),0)
	mastery_xp += xp
	if bool(result.get("crossed_lap",false)):
		mastery_xp += maxi(int(mastery_config().get("lap_xp",3)),0)
		relic_shards += maxi(int(mastery_config().get("lap_relic_shards",1)),0)
	_recalculate_level(true)
	journey_progression_changed.emit()

func register_portal_open() -> void:
	mastery_xp += maxi(int(mastery_config().get("portal_xp",2)),0)
	_recalculate_level(true)
	journey_progression_changed.emit()

func _recalculate_level(emit_signal: bool) -> void:
	var old := mastery_level
	var new_level := 1
	for level in range(1,max_level()+1):
		if mastery_xp >= xp_for_level(level):
			new_level = level
	mastery_level = new_level
	if emit_signal and mastery_level > old:
		mastery_level_up.emit(mastery_level)

func claimable_mastery_level() -> int:
	var rewards: Dictionary = mastery_config().get("level_rewards",{})
	for level in range(2,mastery_level+1):
		if claimed_mastery_levels.has(level):
			continue
		if not Dictionary(rewards.get(str(level),{})).is_empty():
			return level
	return 0

func current_reward() -> Dictionary:
	var level := claimable_mastery_level()
	if level <= 0:
		return {}
	var rewards: Dictionary = mastery_config().get("level_rewards",{})
	return Dictionary(rewards.get(str(level),{}))

func can_claim_mastery_reward() -> bool:
	return claimable_mastery_level() > 0

func claim_mastery_reward() -> Dictionary:
	var claim_level := claimable_mastery_level()
	if claim_level <= 0:
		return {"ok":false,"message":"Noch keine Reise-Belohnung bereit"}
	var reward := current_reward().duplicate(true)
	var authority_intent := OnlineAuthorityService.build_intent("journey_mastery_reward_claim", {"mastery_level":claim_level})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		reward,
		{"claimed_mastery_level":claim_level,"dice":int(reward.get("dice",0))}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Reise-Belohnung konnte nicht bestätigt werden"))}
	if int(reward.get("dice",0)) > 0:
		DiceJourneySystem.grant_dice(int(reward.get("dice",0)))
	claimed_mastery_levels.append(claim_level)
	SaveGame.save_game()
	journey_progression_changed.emit()
	return {"ok":true,"level":claim_level,"reward":reward,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func cache_cost() -> int:
	return maxi(int(mastery_config().get("cache_cost_shards",3)),1)

func can_open_cache() -> bool:
	return relic_shards >= cache_cost()

func open_cache() -> Dictionary:
	if not can_open_cache():
		return {"ok":false,"message":"Nicht genug Relikt-Splitter"}
	var cost := cache_cost()
	var next_shards := relic_shards - cost
	var next_opened := caches_opened + 1
	var reward: Dictionary = mastery_config().get("cache_reward",{})
	var gold := maxi(int(reward.get("gold",0)),0)
	var spins := maxi(int(reward.get("spins",0)),0)
	var authority_intent := OnlineAuthorityService.build_intent("journey_cache_open", {
		"relic_shards_before":relic_shards,
		"cost_shards":cost,
		"cache_opened_before":caches_opened
	})
	var economy_result := EconomyAuthorityService.commit_reward_local(
		authority_intent,
		{"gold":gold,"spins":spins},
		{"relic_shards":next_shards,"caches_opened":next_opened}
	)
	if not bool(economy_result.get("ok",false)):
		return {"ok":false,"message":str(economy_result.get("message","Cache konnte nicht bestätigt werden"))}
	relic_shards = next_shards
	caches_opened = next_opened
	SaveGame.save_game()
	journey_progression_changed.emit()
	return {"ok":true,"gold":gold,"spins":spins,"opened":caches_opened,"authority_request_id":str(authority_intent.get("request_id","")),"authority_revision":int(economy_result.get("revision",0))}

func node_profile(node: int) -> Dictionary:
	for row in config.get("node_profiles",[]):
		if int(row.get("node",0))==node:
			return row
	return {"node":node,"type":"path","label":"PFAD"}

func current_node_text() -> String:
	var node := DiceJourneySystem.position + 1
	var profile := node_profile(node)
	return "FELD %d · %s · %s" % [node,str(profile.get("label","PFAD")),str(profile.get("type","path")).to_upper()]

func mastery_text() -> String:
	if mastery_level >= max_level():
		return "REISE-FORTSCHRITT · STUFE %d MAX · %d PUNKTE" % [mastery_level,mastery_xp]
	return "REISE-FORTSCHRITT · STUFE %d · %d / %d" % [mastery_level,mastery_xp,xp_for_next_level()]

func cache_text() -> String:
	return "RELIKT-SPLITTER · %d / %d · CACHES %d" % [relic_shards,cache_cost(),caches_opened]

func export_save_data() -> Dictionary:
	return {
		"mastery_xp":mastery_xp,
		"mastery_level":mastery_level,
		"relic_shards":relic_shards,
		"claimed_mastery_levels":claimed_mastery_levels.duplicate(),
		"caches_opened":caches_opened
	}

func apply_save_data(data: Dictionary) -> void:
	mastery_xp=maxi(int(data.get("mastery_xp",0)),0)
	relic_shards=maxi(int(data.get("relic_shards",0)),0)
	claimed_mastery_levels.clear()
	for item in data.get("claimed_mastery_levels",[]):
		var level:=int(item)
		if level>=2 and not claimed_mastery_levels.has(level):
			claimed_mastery_levels.append(level)
	caches_opened=maxi(int(data.get("caches_opened",0)),0)
	_recalculate_level(false)
	journey_progression_changed.emit()
