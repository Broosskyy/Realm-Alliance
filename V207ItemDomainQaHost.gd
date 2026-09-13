extends Node

const DomainQa = preload("res://V207ItemDomainQa.gd")

func _ready() -> void:
	await get_tree().process_frame
	var qa := DomainQa.new()
	add_child(qa)
	var report: Dictionary = qa.run()
	var passed := str(report.get("status", "")) == "PASS"
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0 if passed else 1)
