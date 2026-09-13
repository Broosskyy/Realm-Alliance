extends Node

const DomainQa = preload("res://V208WorldDomainQa.gd")

func _ready() -> void:
	await get_tree().process_frame
	var qa := DomainQa.new()
	add_child(qa)
	var report: Dictionary = qa.run()
	print(JSON.stringify({"status": report.get("status"), "tests_passed": report.get("tests_passed"), "tests_total": report.get("tests_total"), "issues": report.get("issues", [])}))
	var passed := str(report.get("status", "")) == "PASS"
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(0 if passed else 1)
