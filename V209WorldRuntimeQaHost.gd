extends Node

const RuntimeQa = preload("res://V209WorldRuntimeQa.gd")
const EXIT_META_PATH := "res://docs/v209_visual_runtime_qa/process_exit.json"

func _ready() -> void:
	var start_ms := Time.get_ticks_msec()
	await get_tree().process_frame
	var qa := RuntimeQa.new()
	get_tree().root.add_child(qa)
	var report: Dictionary = await qa.run()
	var passed := str(report.get("status", "")) == "PASS"
	var exit_code := 0 if passed else 1
	var exit_meta := {
		"qa_result": report.get("status", "UNKNOWN"),
		"elapsed_ms": Time.get_ticks_msec() - start_ms,
		"exit_code": exit_code,
		"issues": report.get("issues", []),
		"assertions_passed": report.get("assertions_passed", 0),
		"assertions_total": report.get("assertions_total", 0)
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/v209_visual_runtime_qa"))
	var file := FileAccess.open(EXIT_META_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(exit_meta, "\t"))
	print(JSON.stringify(exit_meta))
	get_tree().auto_accept_quit = true
	get_tree().quit(exit_code)
