extends Node

const ROOTS := [
	"res://assets/production",
	"res://assets/monsters",
	"res://assets/village",
	"res://assets/world",
	"res://assets/ui",
	"res://assets/entry",
	"res://assets/battle",
	"res://assets/defense"
]

var last_report: Dictionary = {}

func _ready() -> void:
	last_report = scan_runtime_assets()

func scan_runtime_assets() -> Dictionary:
	var files: Array[String] = []
	for root in ROOTS:
		_scan_dir(root, files)
	var placeholders: Array[String] = []
	var resolved_aliases: Array[String] = []
	var unresolved: Array[String] = []
	for path in files:
		if "_placeholder" in path.to_lower():
			if has_node("/root/SemanticAssetRegistry") and SemanticAssetRegistry.is_resolved_placeholder(path):
				resolved_aliases.append(path)
			else:
				placeholders.append(path)
		if not ResourceLoader.exists(path):
			unresolved.append(path)
	return {
		"version": "1.60",
		"scanned": files.size(),
		"unresolved_placeholders": placeholders,
		"resolved_placeholder_aliases": resolved_aliases,
		"unresolved": unresolved,
		"registry_stats": SemanticAssetRegistry.pipeline_stats() if has_node("/root/SemanticAssetRegistry") else {}
	}

func _scan_dir(path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break
		if name.begins_with("."):
			continue
		var full := path.path_join(name)
		if dir.current_is_dir():
			_scan_dir(full, out)
		elif name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "ogg", "wav", "mp3"]:
			out.append(full)
	dir.list_dir_end()

func report() -> Dictionary:
	return last_report.duplicate(true)
