extends Node

const REGISTRY_PATH := "res://data/production_asset_registry.json"
const BINDINGS_PATH := "res://data/runtime_art_bindings_v200.json"
var registry: Dictionary = {}
var bindings: Dictionary = {}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	registry = _read_json(REGISTRY_PATH)
	bindings = _read_json(BINDINGS_PATH).get("bindings", {})

func _read_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("ProductionAssetRegistry missing: " + path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func texture_for(asset_id: String) -> Texture2D:
	if asset_id.begins_with("atlas:"):
		return atlas_texture_for(asset_id.trim_prefix("atlas:"))
	var entry: Dictionary = registry.get("textures", {}).get(asset_id, {})
	if entry.is_empty():
		entry = registry.get("assets", {}).get(asset_id, {})
	var path := str(entry.get("path", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path)

func atlas_texture_for(region_id: String) -> Texture2D:
	var parts := region_id.split("/", false, 1)
	if parts.size() != 2:
		return null
	var atlas_entry: Dictionary = registry.get("atlases", {}).get(parts[0], {})
	var region_entry: Dictionary = atlas_entry.get("regions", {}).get(parts[1], {})
	var path := str(atlas_entry.get("path", ""))
	var r: Array = region_entry.get("region", [])
	if path.is_empty() or r.size() != 4 or not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path)
	if tex == null:
		return null
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
	return at

func bound_texture(role_id: String, allow_medium := false) -> Texture2D:
	var b: Dictionary = bindings.get(role_id, {})
	var confidence := str(b.get("confidence", "hold"))
	if confidence == "hold" or (confidence == "medium" and not allow_medium):
		return null
	return texture_for(str(b.get("asset", "")))

func binding_info(role_id: String) -> Dictionary:
	return bindings.get(role_id, {}).duplicate(true)

func validate_registry() -> Dictionary:
	var missing: Array[String] = []
	for id in registry.get("textures", {}).keys():
		var p := str(registry["textures"][id].get("path", ""))
		if p.is_empty() or not ResourceLoader.exists(p): missing.append(str(id))
	for id in registry.get("assets", {}).keys():
		var p := str(registry["assets"][id].get("path", ""))
		if p.is_empty() or not ResourceLoader.exists(p): missing.append(str(id))
	for atlas_id in registry.get("atlases", {}).keys():
		var p := str(registry["atlases"][atlas_id].get("path", ""))
		if p.is_empty() or not ResourceLoader.exists(p): missing.append("atlas:" + str(atlas_id))
	return {"ok": missing.is_empty(), "missing": missing}

func validate_bindings() -> Dictionary:
	var missing: Array[String] = []
	var checked := 0
	for role_id in bindings.keys():
		var b: Dictionary = bindings[role_id]
		var confidence := str(b.get("confidence", "hold"))
		if confidence == "hold":
			continue
		var asset_id := str(b.get("asset", ""))
		if asset_id.is_empty():
			missing.append(str(role_id) + " -> <empty>")
			continue
		checked += 1
		if texture_for(asset_id) == null:
			missing.append(str(role_id) + " -> " + asset_id)
	return {"ok": missing.is_empty(), "checked": checked, "missing": missing}
