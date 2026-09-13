extends Node

const RuntimeQa = preload("res://V208WorldRuntimeQa.gd")
const EXIT_META_PATH := "res://docs/v208_visual_runtime_qa/process_exit.json"

var _quit_requested_ms: int = 0
var _start_ms: int = 0

func _ready() -> void:
	_start_ms = Time.get_ticks_msec()
	await get_tree().process_frame
	var qa := RuntimeQa.new()
	get_tree().root.add_child(qa)
	var report: Dictionary = await qa.run()
	var passed := str(report.get("status", "")) == "PASS"
	var exit_code := 0 if passed else 1
	_quit_requested_ms = Time.get_ticks_msec()
	var exit_meta := {
		"qa_result": report.get("status", "UNKNOWN"),
		"quit_requested": true,
		"quit_requested_ms": _quit_requested_ms,
		"process_start_ms": _start_ms,
		"elapsed_ms": _quit_requested_ms - _start_ms,
		"exit_code": exit_code,
		"issues": report.get("issues", []),
		"assertions_passed": report.get("assertions_passed", 0),
		"assertions_total": report.get("assertions_total", 0)
	}
	DirAccess.make_dir_recursive_absolute("res://docs/v208_visual_runtime_qa")
	var file := FileAccess.open(EXIT_META_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(exit_meta, "\t"))
	print(JSON.stringify(exit_meta))
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(exit_code)
