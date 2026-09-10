extends Node

signal region_progress_changed

const DATA_PATH := "res://data/regions.json"
var regions: Array = []

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not f:
		push_error("Region config missing")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		regions = parsed.get("regions",[])

func region_by_id(id: String) -> Dictionary:
	for region in regions:
		if str(region.get("id","")) == id:
			return region
	return {}

func is_unlocked(id: String) -> bool:
	var region := region_by_id(id)
	if region.is_empty():
		return false
	return PlayerData.player_level >= int(region.get("unlock_level",999999))

func unlocked_regions() -> Array:
	var out: Array = []
	for region in regions:
		if is_unlocked(str(region.get("id",""))):
			out.append(region)
	return out

func next_region() -> Dictionary:
	for region in regions:
		if not is_unlocked(str(region.get("id",""))):
			return region
	return {}

func progress_to_next_region() -> Dictionary:
	var next := next_region()
	if next.is_empty():
		return {"complete":true,"progress":1.0}
	var target := maxi(int(next.get("unlock_level",1)),1)
	var previous_unlock := 1
	for region in regions:
		var unlock := int(region.get("unlock_level",1))
		if unlock < target:
			previous_unlock = maxi(previous_unlock,unlock)
	var span := maxi(target - previous_unlock,1)
	var current := clampi(PlayerData.player_level - previous_unlock,0,span)
	return {
		"complete":false,
		"region_id":str(next.get("id","")),
		"name":str(next.get("name","")),
		"unlock_level":target,
		"levels_remaining":maxi(target - PlayerData.player_level,0),
		"progress":clampf(float(current) / float(span),0.0,1.0)
	}
