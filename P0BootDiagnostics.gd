extends Node

signal boot_checked(report: Dictionary)

var last_report: Dictionary = {}
var scene_boot_completed: bool = false

func complete_scene_boot(main_scene: Control) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	if main_scene == null:
		errors.append("Main scene is null")
	else:
		if not main_scene.is_inside_tree():
			errors.append("Main scene not inside SceneTree")

	var configured_main := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if configured_main != "res://MainGame.tscn":
		errors.append("Main scene setting drift: %s" % configured_main)

	var width := int(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	var height := int(ProjectSettings.get_setting("display/window/size/viewport_height", 0))
	if width != 1080 or height != 1920:
		errors.append("Reference viewport drift: %dx%d" % [width,height])

	var stretch_mode := str(ProjectSettings.get_setting("display/window/stretch/mode", ""))
	if stretch_mode != "canvas_items":
		errors.append("Stretch mode drift: %s" % stretch_mode)

	var contract_errors := CoreAcceptanceService.validate_runtime_contract()
	for error in contract_errors:
		errors.append("Core contract: %s" % error)

	if BuildInfo.SOURCE_VERSION != "V1.22":
		errors.append("BuildInfo source version drift")
	if BuildInfo.MASTER_CONCEPT != "V1.6":
		errors.append("Master concept drift")

	if P0TestHarness.enabled and not OS.is_debug_build():
		errors.append("Test harness enabled in non-debug build")
	if HeroSystem.is_processing():
		errors.append("P1 isolation: HeroSystem processing during P0")
	if LaneAttackSystem.is_processing():
		errors.append("P1 isolation: LaneAttackSystem processing during P0")
	if TowerDefenseSystem.is_processing():
		errors.append("P1 isolation: TowerDefenseSystem processing during P0")
	if not P0TestHarness.enabled and OS.is_debug_build():
		warnings.append("Debug build without active P0 test harness")
	if SaveGame.load_source == "none":
		warnings.append("Save lifecycle has no completed load source")
	if SaveGame.seconds_away_on_last_load < 0:
		errors.append("Save lifecycle produced negative away time")

	last_report = {
		"ok":errors.is_empty(),
		"source_version":BuildInfo.SOURCE_VERSION,
		"master_concept":BuildInfo.MASTER_CONCEPT,
		"debug_build":OS.is_debug_build(),
		"scene_boot_completed":true,
		"main_scene":configured_main,
		"reference_viewport":[width,height],
		"errors":errors,
		"save_load_source":SaveGame.load_source,
		"save_recovered":SaveGame.recovered_from_backup,
		"save_sequence":SaveGame.save_sequence,
		"warnings":warnings
	}
	scene_boot_completed = true

	if errors.is_empty():
		CoreAnalytics.log_event("p0_boot_pass", {
			"debug_build":OS.is_debug_build(),
			"save_load_source":SaveGame.load_source,
		"save_recovered":SaveGame.recovered_from_backup,
		"save_sequence":SaveGame.save_sequence,
		"warnings":warnings.size()
		})
	else:
		for error in errors:
			push_error("[P0_BOOT] " + error)
		CoreAnalytics.log_event("p0_boot_fail", {"errors":errors})

	boot_checked.emit(last_report)
	return last_report.duplicate(true)

func snapshot() -> Dictionary:
	return last_report.duplicate(true)
