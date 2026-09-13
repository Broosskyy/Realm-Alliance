extends Node

const Qa = preload("res://V207InventoryRuntimeQa.gd")

func _ready() -> void:
	await get_tree().process_frame
	var qa := Qa.new()
	get_tree().root.add_child(qa)
	var report: Dictionary = await qa.run()
	var passed := str(report.get("status", "")) == "PASS"
	await get_tree().create_timer(0.15).timeout
	if get_tree() != null:
		get_tree().quit(0 if passed else 1)
