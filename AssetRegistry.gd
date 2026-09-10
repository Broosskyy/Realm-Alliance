extends Node

const MANIFEST_PATH := "res://data/asset_manifest.json"
var manifest: Dictionary = {}

func _ready() -> void:
	_load_manifest()

func _load_manifest() -> void:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if not file:
		push_error("Asset manifest missing: " + MANIFEST_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		manifest = parsed.get("assets", {})

func path_for(asset_id: String) -> String:
	var entry: Dictionary = manifest.get(asset_id, {})
	return str(entry.get("path", ""))

func texture_for(asset_id: String) -> Texture2D:
	var path := path_for(asset_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path)


# V1.56 production-art bridge. Existing placeholder behavior remains unchanged.
func production_texture_for(role_id: String, allow_medium := false) -> Texture2D:
	if has_node("/root/SemanticAssetRegistry"):
		return SemanticAssetRegistry.texture_for_role(role_id, allow_medium)
	if has_node("/root/ProductionAssetRegistry"):
		return ProductionAssetRegistry.bound_texture(role_id, allow_medium)
	return null

func production_binding_info(role_id: String) -> Dictionary:
	if has_node("/root/SemanticAssetRegistry"):
		return SemanticAssetRegistry.binding_info(role_id)
	if has_node("/root/ProductionAssetRegistry"):
		return ProductionAssetRegistry.binding_info(role_id)
	return {}
