@tool
extends EditorPlugin

const REPORT_PATH := "res://data/asset_pipeline_editor_report_v160.json"
const INDEX_PATH := "res://data/generated_asset_index_v160.json"
const TOOL_PATH := "res://tools/realm_asset_pipeline.py"
var _queued := false
var _writing_report := false

func _enter_tree() -> void:
	add_tool_menu_item("REALM: Assets neu scannen", Callable(self, "_manual_scan"))
	var fs := get_editor_interface().get_resource_filesystem()
	if fs != null and not fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.connect(_on_filesystem_changed)
	call_deferred("_run_scan")

func _exit_tree() -> void:
	remove_tool_menu_item("REALM: Assets neu scannen")
	var fs := get_editor_interface().get_resource_filesystem()
	if fs != null and fs.filesystem_changed.is_connected(_on_filesystem_changed):
		fs.filesystem_changed.disconnect(_on_filesystem_changed)

func _manual_scan() -> void:
	_try_full_index_refresh()
	_run_scan()

func _on_filesystem_changed() -> void:
	if _writing_report or _queued:
		return
	_queued = true
	call_deferred("_run_scan")

func _run_scan() -> void:
	_queued = false
	var index := _read_json(INDEX_PATH)
	var assets: Dictionary = index.get("assets", {})
	var placeholders: Array[String] = []
	var resolved_placeholder_aliases: Array[String] = []
	var missing: Array[String] = []
	var production := 0
	for path in assets.keys():
		var entry: Dictionary = assets[path]
		if bool(entry.get("placeholder", false)):
			if bool(entry.get("placeholder_resolved_by_alias", false)):
				resolved_placeholder_aliases.append(str(path))
			else:
				placeholders.append(str(path))
		else:
			production += 1
		if not FileAccess.file_exists(str(path)):
			missing.append(str(path))
	var disk_files: Array[String] = []
	_scan_dir("res://assets", disk_files)
	var unindexed: Array[String] = []
	for path in disk_files:
		if not assets.has(path):
			unindexed.append(path)
	var report := {
		"version": "1.60",
		"production_assets": production,
		"unresolved_placeholder_assets": placeholders.size(),
		"resolved_placeholder_aliases": resolved_placeholder_aliases.size(),
		"virtual_atlas_regions": index.get("virtual_assets", {}).size(),
		"exact_duplicate_groups": index.get("duplicate_groups", []).size(),
		"missing_indexed_files": missing,
		"new_unindexed_files": unindexed,
		"needs_full_reindex": not unindexed.is_empty(),
		"policy": "Do not auto-delete duplicates. High confidence may auto-bind; medium remains reviewable; placeholders never override production."
	}
	_write_json_if_changed(REPORT_PATH, report)
	print("REALM Asset Pipeline V1.60: ", report)

func _try_full_index_refresh() -> void:
	var tool := ProjectSettings.globalize_path(TOOL_PATH)
	if not FileAccess.file_exists(TOOL_PATH):
		return
	var output: Array = []
	var code := OS.execute("python3", PackedStringArray([tool]), output, true)
	if code != 0:
		code = OS.execute("python", PackedStringArray([tool]), output, true)
	if code != 0:
		push_warning("REALM full asset reindex needs Python. Use tools/run_asset_pipeline.bat or .sh. Quick editor report still works.")
	else:
		get_editor_interface().get_resource_filesystem().scan()

func _scan_dir(path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty(): break
		if name.begins_with("."): continue
		var full := path.path_join(name)
		if dir.current_is_dir():
			_scan_dir(full, out)
		elif name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "ogg", "wav", "mp3"]:
			out.append(full)
	dir.list_dir_end()

func _read_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return {}
	var parsed = JSON.parse_string(f.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _write_json_if_changed(path: String, value: Dictionary) -> void:
	var next_text := JSON.stringify(value, "  ")
	if FileAccess.file_exists(path):
		var current := FileAccess.open(path, FileAccess.READ)
		if current != null and current.get_as_text() == next_text:
			return
	_writing_report = true
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_writing_report = false
		push_error("REALM Asset Pipeline cannot write %s" % path)
		return
	f.store_string(next_text)
	_writing_report = false
