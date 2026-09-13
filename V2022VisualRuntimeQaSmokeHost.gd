extends Node

func _ready() -> void:
	await get_tree().process_frame
	await VisualRuntimeQa.run_smoke()
	var report := VisualRuntimeQa.get_report()
	var passed := str(report.get("status", "")) == "PASS"
	await get_tree().create_timer(0.25).timeout
	get_tree().quit(0 if passed else 1)
