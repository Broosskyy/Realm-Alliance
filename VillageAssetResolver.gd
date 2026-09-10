extends RefCounted

const ROOT := "res://assets/village/greenvale/production"
const MAP := {
	"townhall": {"file": "townhall.png", "confidence": "high"},
	"goldmine": {"file": "goldmine.png", "confidence": "medium"},
	"forge": {"file": "forge.png", "confidence": "high"},
	"lucktemple": {"file": "lucktemple.png", "confidence": "high"}
}

static func texture_for(building_id: String) -> Texture2D:
	var entry: Dictionary = MAP.get(building_id, {})
	var file := str(entry.get("file", ""))
	if file.is_empty(): return null
	var path := ROOT.path_join(file)
	return load(path) if ResourceLoader.exists(path) else null

static func confidence_for(building_id: String) -> String:
	return str(MAP.get(building_id, {}).get("confidence", "low"))

static func needs_review(building_id: String) -> bool:
	return confidence_for(building_id) != "high"
