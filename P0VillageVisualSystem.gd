extends Node

const PRODUCTION_ROOT := "res://assets/village/greenvale/production"
const PRODUCTION_FILE := {
	"townhall":"townhall.png",
	"goldmine":"goldmine.png",
	"forge":"forge.png",
	"lucktemple":"lucktemple.png"
}
const CONFIDENCE := {
	"townhall":"high",
	"goldmine":"medium",
	"forge":"high",
	"lucktemple":"high"
}

func texture_for(building_id: String) -> Texture2D:
	return texture_for_level(building_id, P0VillageSystem.get_level(building_id))

func texture_for_level(building_id: String, _level: int) -> Texture2D:
	var file := str(PRODUCTION_FILE.get(building_id,""))
	if file.is_empty():
		return null
	var path := "%s/%s" % [PRODUCTION_ROOT,file]
	if ResourceLoader.exists(path):
		return load(path)
	return null

func visual_scale_for_level(level: int) -> float:
	match clampi(level,1,3):
		1: return 0.90
		2: return 1.00
		_: return 1.08

func visual_tint_for_level(level: int) -> Color:
	match clampi(level,1,3):
		1: return Color(0.90,0.92,0.94,1.0)
		2: return Color.WHITE
		_: return Color(1.0,0.97,0.80,1.0)

func mapping_confidence(building_id: String) -> String:
	return str(CONFIDENCE.get(building_id,"unknown"))
