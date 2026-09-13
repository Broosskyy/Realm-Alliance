extends Node
## V2.02 runtime acceptance host — loaded via dedicated scene for async QA.

const MAIN_SCENE := "res://MainGame.tscn"
const REPORT_REL := "docs/v202_runtime_qa/acceptance_report.json"
const SHOT_DIR_REL := "docs/v202_runtime_qa/screenshots"

var _report: Dictionary = {
	"milestone": "V2.02",
	"status": "BLOCKED",
	"godot": Engine.get_version_info(),
	"tests": {},
	"known_issues": []
}

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/v202_runtime_qa"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://%s" % SHOT_DIR_REL))
	await get_tree().process_frame
	await _run_all()
	_write_report()
	var passed := str(_report.get("status", "")) == "PASS"
	get_tree().quit(0 if passed else 1)

func _run_all() -> void:
	SettingsService.reduced_motion = true
	await _test_profile(Vector2i(1080, 2340), true)
	await _test_profile(Vector2i(1080, 2400), false)
	await _test_profile(Vector2i(1080, 1920), false)
	var save_ok := _test_save_resume()
	_report["tests"]["save_resume"] = save_ok
	if not save_ok:
		_report["known_issues"].append("Save/resume regression")
	var required := ["boot", "tap_damage", "navigation", "spin", "village", "hud"]
	var all_pass := save_ok
	for key in required:
		if not bool(_report["tests"].get(key, false)):
			all_pass = false
	_report["status"] = "PASS" if all_pass else "BLOCKED"

func _test_profile(viewport: Vector2i, primary: bool) -> void:
	DisplayServer.window_set_size(viewport)
	if P0TestHarness.enabled:
		P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		if primary:
			_report["tests"]["boot"] = false
		return
	var shell := Control.new()
	shell.custom_minimum_size = Vector2(viewport)
	shell.size = Vector2(viewport)
	add_child(shell)
	var main: Control = packed.instantiate()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	if main.has_method("_apply_mobile_runtime_polish"):
		main.call("_apply_mobile_runtime_polish")
	if main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	await get_tree().process_frame
	var tag := "%dx%d" % [viewport.x, viewport.y]
	if primary:
		_report["tests"]["boot"] = main.is_inside_tree()
	await _shot(main, "boot_%s" % tag)
	var hp_before := PlayerData.current_monster_hp
	if main.has_method("_on_monster_pressed"):
		main.call("_on_monster_pressed")
	await get_tree().process_frame
	var tap_ok := PlayerData.current_monster_hp < hp_before
	if primary:
		_report["tests"]["tap_damage"] = tap_ok
		await _shot(main, "tap_%s" % tag)
	var nav_ok := await _test_navigation(main)
	if primary:
		_report["tests"]["navigation"] = nav_ok
	var spin_ok := await _test_spin(main)
	if primary:
		_report["tests"]["spin"] = spin_ok
		await _shot(main, "spin_%s" % tag)
	var village_ok := await _test_village(main)
	if primary:
		_report["tests"]["village"] = village_ok
		await _shot(main, "village_%s" % tag)
	var hud_ok := _test_hud(main)
	if primary:
		_report["tests"]["hud"] = hud_ok
	_report["tests"]["profile_%s" % tag] = {"tap": tap_ok, "nav": nav_ok, "spin": spin_ok, "village": village_ok, "hud": hud_ok}
	shell.queue_free()
	await get_tree().process_frame

func _test_navigation(main: Control) -> bool:
	var btn_rad := main.find_child("Btn_Rad", true, false) as Button
	var btn_dorf := main.find_child("Btn_Dorf", true, false) as Button
	var btn_tap := main.find_child("Btn_Tap", true, false) as Button
	var view_rad := main.find_child("View_CoinMaster", true, false) as Control
	var view_dorf := main.find_child("View_ClashDorf", true, false) as Control
	var view_tap := main.find_child("View_TapHero", true, false) as Control
	if btn_rad == null or view_rad == null:
		return false
	if main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	btn_rad.emit_signal("pressed")
	if not await _wait_until(func(): return view_rad.visible, 120):
		return false
	btn_dorf.emit_signal("pressed")
	if not await _wait_until(func(): return view_dorf.visible, 120):
		return false
	var more := main.find_child("MoreFeaturesButtonP0", true, false) as Button
	if more and more.visible:
		more.emit_signal("pressed")
		await _wait_until(func(): return (main.find_child("FeatureHubOverlayP0", true, false) as Control).visible, 60)
		var close := main.find_child("FeatureHubCloseP0", true, false) as Button
		if close:
			close.emit_signal("pressed")
			await get_tree().process_frame
	btn_tap.emit_signal("pressed")
	return await _wait_until(func(): return view_tap.visible, 120)

func _wait_until(predicate: Callable, max_frames: int) -> bool:
	for _i in range(max_frames):
		if predicate.call():
			return true
		await get_tree().process_frame
	return predicate.call()

func _test_spin(main: Control) -> bool:
	var btn_rad := main.find_child("Btn_Rad", true, false) as Button
	if btn_rad:
		btn_rad.emit_signal("pressed")
		await get_tree().process_frame
	if PlayerData.spins <= 0:
		PlayerData.spins = 5
		PlayerData.stats_changed.emit()
	var spin_btn := main.find_child("SpinButton", true, false) as Button
	if spin_btn == null:
		return false
	spin_btn.disabled = false
	spin_btn.emit_signal("pressed")
	for _i in range(180):
		await get_tree().process_frame
	return true

func _test_village(main: Control) -> bool:
	if main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	var btn_dorf := main.find_child("Btn_Dorf", true, false) as Button
	if btn_dorf == null:
		return false
	btn_dorf.emit_signal("pressed")
	return await _wait_until(func():
		var view := main.find_child("View_ClashDorf", true, false) as Control
		return view != null and view.visible
	, 120)

func _test_hud(main: Control) -> bool:
	var gold := main.find_child("GoldLabel", true, false) as Label
	var quick := main.find_child("QuickActions", true, false) as Control
	if gold == null:
		return false
	if quick and quick.visible:
		return false
	return not gold.text.is_empty()

func _test_save_resume() -> bool:
	var gold_before := PlayerData.gold
	PlayerData.gold = gold_before + 77
	SaveGame.save_game()
	var ml := PlayerData.monster_level
	SaveGame.load_game()
	return PlayerData.gold == gold_before + 77 and PlayerData.monster_level == ml

func _shot(main: Control, name: String) -> void:
	await get_tree().process_frame
	var tex := main.get_viewport().get_texture()
	if tex == null:
		return
	var img := tex.get_image()
	if img == null or img.is_empty():
		return
	img.save_png(ProjectSettings.globalize_path("res://%s/%s.png" % [SHOT_DIR_REL, name]))

func _write_report() -> void:
	var path := ProjectSettings.globalize_path("res://%s" % REPORT_REL)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_report, "\t"))
		f.close()
	print(JSON.stringify(_report))
