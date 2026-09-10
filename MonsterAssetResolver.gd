extends RefCounted

const ROOT := "res://assets/monsters/greenvale/states"
const VALID_STATES := ["idle", "attack", "hit", "defeated"]

static func texture_for(monster_id: String, state: String = "idle") -> Texture2D:
	var s := state.to_lower()
	if s == "shield": s = "attack"
	if s not in VALID_STATES: s = "idle"
	var path := "%s/%s_%s.png" % [ROOT, monster_id, s]
	if not ResourceLoader.exists(path):
		path = "%s/%s_idle.png" % [ROOT, monster_id]
	if ResourceLoader.exists(path):
		return load(path)
	return null

static func state_paths(monster_id: String) -> Dictionary:
	var out := {}
	for state in VALID_STATES:
		var path := "%s/%s_%s.png" % [ROOT, monster_id, state]
		out[state] = path if ResourceLoader.exists(path) else ""
	return out

static func is_complete(monster_id: String) -> bool:
	for state in VALID_STATES:
		if not ResourceLoader.exists("%s/%s_%s.png" % [ROOT, monster_id, state]):
			return false
	return true
