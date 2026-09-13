extends Node
## V2.08 — world/encounter visual runtime QA with watchdog + step timings.

const CombatDamageResolver = preload("res://CombatDamageResolver.gd")

const SHOT_DIR := "res://docs/v208_visual_runtime_qa"
const REPORT_PATH := "res://docs/v208_visual_runtime_qa/world_runtime_qa_report.json"

const MAX_RUNTIME_MS := 600000
const PROFILES := [
	Vector2i(1080, 1920),
	Vector2i(1080, 2340),
	Vector2i(1080, 2400),
	Vector2i(1440, 3200)
]

const MODIFIER_TO_RUNTIME := {
	"tap_damage": ["tap_preview", "tap_real"],
	"hero_damage": ["hero_effective", "hero_real"]
}

var _report: Dictionary = {}
var _main: Control
var _hero_id: String = ""
var _visual_issues: Array[String] = []
var _start_ms: int = 0
var _current_step: String = "init"
var _failed_step: String = ""

func _log(msg: String) -> void:
	print("[V208WorldQa] ", msg)

func run() -> Dictionary:
	_start_ms = Time.get_ticks_msec()
	_report = {
		"milestone": "V2.08",
		"status": "BLOCKED",
		"duration_ms": 0,
		"step_timings": [],
		"assertions": [],
		"regression": {},
		"screenshots": [],
		"viewport_matrix": [],
		"state_evidence": {},
		"visual_issues": [],
		"issues": [],
		"process_exit": {},
		"qa_performance": {"start_ms": _start_ms, "max_runtime_ms": MAX_RUNTIME_MS}
	}
	_visual_issues.clear()
	SettingsService.reduced_motion = true
	_suspend_hero_auto()

	var boot_ok := await _run_step("boot", _step_boot)
	if not boot_ok:
		_fail_watchdog("boot_timeout")
		return _finalize_report()

	await _run_step("main_ready", _step_main_ready)
	await _run_step("encounter_1", _step_encounter_one)
	await _run_step("encounter_progression", _step_encounter_progression)
	await _run_step("elite_encounter", _step_elite_encounter)
	await _run_step("boss_flow", _step_boss_flow)
	await _run_step("inventory_regression", _step_inventory_regression)
	await _run_step("save_reload", _step_save_reload)
	await _run_step("viewport_matrix", _step_viewport_matrix)
	await _run_step("visual_inspection", _step_visual_inspection)

	_report["visual_issues"] = _visual_issues.duplicate()
	return _finalize_report()

func _run_step(step_name: String, step_fn: Callable) -> bool:
	if _watchdog_exceeded():
		_fail_watchdog(step_name)
		return false
	_current_step = step_name
	var started := Time.get_ticks_msec()
	var ok := true
	var error := ""
	if step_fn.is_valid():
		var result = await step_fn.call()
		if typeof(result) == TYPE_BOOL:
			ok = result
		elif typeof(result) == TYPE_DICTIONARY:
			ok = bool(result.get("ok", true))
			error = str(result.get("error", ""))
	if not ok and not error.is_empty():
		_report["issues"].append("%s:%s" % [step_name, error])
	elif not ok:
		_report["issues"].append(step_name)
	_failed_step = step_name if not ok else ""
	var timing := {
		"step": step_name,
		"start_ms": started - _start_ms,
		"duration_ms": Time.get_ticks_msec() - started,
		"result": "PASS" if ok else "FAIL"
	}
	_report["step_timings"].append(timing)
	_flush_report(false)
	_log("%s %s (%dms)" % [step_name, timing.result, timing.duration_ms])
	return ok

func _watchdog_exceeded() -> bool:
	return Time.get_ticks_msec() - _start_ms > MAX_RUNTIME_MS

func _fail_watchdog(step: String) -> void:
	_failed_step = step
	_report["issues"].append("watchdog_timeout:%s" % step)
	_report["status"] = "FAIL"
	_report["state_evidence"]["watchdog"] = {
		"step": step,
		"elapsed_ms": Time.get_ticks_msec() - _start_ms,
		"max_runtime_ms": MAX_RUNTIME_MS
	}
	await _capture("watchdog_failure_%s" % step, "failure")
	_flush_report(true)

func _step_boot() -> bool:
	P0BootDiagnostics.qa_direct_main_load = true
	get_tree().change_scene_to_file("res://MainGame.tscn")
	var loaded := await _wait_until(func(): return _find_main() != null, 300, "main_load")
	_main = _find_main()
	return loaded and _main != null

func _suspend_hero_auto() -> void:
	HeroSystem.set_process(false)

func _reset_encounter(level: int) -> void:
	PlayerData.monster_level = level
	PlayerData.monster_max_hp = GameConfig.effective_monster_hp(level)
	PlayerData.current_monster_hp = PlayerData.monster_max_hp
	PlayerData.monster_changed.emit()
	if _main and _main.has_method("qa_prepare_combat_ready"):
		_main.qa_prepare_combat_ready()
	_update_monster_visual_main()

func _step_main_ready() -> bool:
	if _main == null:
		return false
	await _apply_viewport(PROFILES[0])
	RegionProgressionSystem.reset_runtime()
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	BossChallengeSystem.reset_runtime()
	P0MonsterVisualSystem.reload_for_region("greenvale")
	PlayerData.player_level = maxi(PlayerData.player_level, 10)
	HeroSystem.sync_progression_unlocks()
	HeroSystem.deploy_hero("knight")
	_hero_id = HeroSystem.get_deployed_hero_id()
	_reset_encounter(1)

	var region_ok := RegionProgressionSystem.combat_region_id() == "greenvale"
	var bg_path := RegionProgressionSystem.background_asset_path()
	var bg_ok := ResourceLoader.exists(bg_path)
	_record_assertion("gruenhain_region", region_ok and bg_ok, {
		"region_id": RegionProgressionSystem.combat_region_id(),
		"background_asset": bg_path,
		"background_exists": bg_ok
	})
	await _capture("01_gruenhain_main", "main")
	return region_ok and bg_ok and not _hero_id.is_empty()

func _step_encounter_one() -> bool:
	_reset_encounter(1)
	var id1 := P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level)
	var path1 := _idle_texture_path(PlayerData.monster_level)
	_record_assertion("monster_a_id", id1 == "M001", {"monster_id": id1, "asset_path": path1})
	await _set_monster_state("idle")
	await _capture("02_monster_a_idle", "monster")

	# Real TAP hit without kill
	var saved_hp := PlayerData.current_monster_hp
	if saved_hp <= PlayerData.tap_damage:
		PlayerData.current_monster_hp = maxi(PlayerData.tap_damage * 3, 30)
	await _main._on_monster_pressed()
	await _wait_frames(12)
	await _capture("03_monster_a_hit", "monster")

	# Hero attack
	var hero_hit := HeroSystem.force_attack_tick()
	_record_assertion("hero_attack", int(hero_hit.get("damage", 0)) > 0, hero_hit)
	await _wait_frames(8)

	# Real defeat via TAP
	PlayerData.current_monster_hp = 1
	_main.monster_state_locked = false
	_main.core_input_locked = false
	await _main._on_monster_pressed()
	var reward_visible := await _wait_until(
		func(): return _main.monster_reward_overlay.visible,
		240,
		"reward_overlay"
	)
	if not reward_visible:
		return false
	await _set_monster_state("defeat", 1)
	await _capture("04_monster_a_defeated", "monster")
	await _capture("05_reward", "reward")

	var before_id := id1
	var before_path := path1
	_main.monster_reward_continue.emit_signal("pressed")
	await _wait_until(
		func(): return not _main.monster_reward_overlay.visible,
		120,
		"reward_dismiss"
	)
	await _wait_frames(8)

	var after_id := P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level)
	var after_path := _idle_texture_path(PlayerData.monster_level)
	var diversity_ok := after_id != before_id and after_path != before_path and after_id.begins_with("M")
	_record_assertion("monster_rotation", diversity_ok, {
		"before_id": before_id,
		"after_id": after_id,
		"before_path": before_path,
		"after_path": after_path
	})
	await _capture("06_monster_b", "monster")
	_report["state_evidence"]["monster_diversity"] = {
		"monster_a": {"id": before_id, "path": before_path},
		"monster_b": {"id": after_id, "path": after_path}
	}
	return id1 == "M001" and diversity_ok

func _step_encounter_progression() -> bool:
	_reset_encounter(9)
	var snap := EncounterProgressService.encounter_progress_snapshot(PlayerData.monster_level)
	var ok := int(snap.get("until_boss", 99)) == 1 and not bool(snap.get("is_boss", false))
	_record_assertion("boss_ready_progress", ok, snap)
	await _capture("08_encounter_progress", "progress")
	return ok

func _step_elite_encounter() -> bool:
	_reset_encounter(11)
	var elite_id := P0MonsterVisualSystem.production_asset_id(11)
	var cls := P0MonsterVisualSystem.monster_classification(11)
	var ok := elite_id == "M010" and cls == "elite"
	_record_assertion("elite_encounter", ok, {
		"monster_id": elite_id,
		"classification": cls,
		"progress_label": EncounterProgressService.progress_label(11)
	})
	await _set_monster_state("idle")
	await _capture("07_tough_elite", "monster")
	return ok

func _step_boss_flow() -> bool:
	RegionProgressionSystem.record_encounter_cleared("greenvale", 9, false)
	_reset_encounter(10)
	var boss_id := P0MonsterVisualSystem.production_asset_id(10)
	if not boss_id.begins_with("B"):
		return false
	await _capture("12_boss_ready", "boss")

	if _main.has_method("_show_boss_intro"):
		await _main._show_boss_intro()
	await _capture("13_boss_intro", "boss")
	var boss_active := BossChallengeSystem.active
	if not boss_active:
		BossChallengeSystem.start_challenge(PlayerData.monster_level)
		boss_active = BossChallengeSystem.active
	_record_assertion("boss_challenge_active", boss_active, BossChallengeSystem.snapshot())
	await _set_monster_state("idle")
	await _capture("14_boss_combat", "boss")

	await _main._on_monster_pressed()
	await _wait_frames(12)
	await _set_monster_state("hit")
	await _capture("15_boss_hit", "boss")

	PlayerData.current_monster_hp = 1
	_main.monster_state_locked = false
	_main.core_input_locked = false
	await _main._on_monster_pressed()
	await _wait_frames(20)
	var region_after_boss := RegionProgressionSystem.progress_entry("greenvale")
	var boss_defeat_ok := int(region_after_boss.get("bosses_defeated", 0)) >= 1
	_record_assertion("boss_victory", boss_defeat_ok, {
		"boss_id": boss_id,
		"boss_challenge": BossChallengeSystem.snapshot(),
		"region_progress": region_after_boss,
		"reward_overlay_visible": _main.monster_reward_overlay.visible,
		"boss_chest_visible": _main.boss_reward_chest_p0.visible
	})
	await _capture("16_boss_victory", "boss")
	await _capture("17_boss_loot", "boss")

	if _main.monster_reward_overlay.visible:
		_main.monster_reward_continue.emit_signal("pressed")
		await _wait_frames(12)
	elif _main.has_method("_continue_after_monster_reward"):
		_main.monster_reward_continue.emit_signal("pressed")

	var region_entry := region_after_boss
	_record_assertion("region_progress_after_boss", int(region_entry.get("bosses_defeated", 0)) >= 1, region_entry)
	await _capture("18_region_progress", "progress")
	_report["state_evidence"]["boss"] = {
		"boss_id": boss_id,
		"challenge": BossChallengeSystem.snapshot(),
		"region_progress": region_entry
	}
	return boss_defeat_ok and boss_active and int(region_entry.get("bosses_defeated", 0)) >= 1

func _step_inventory_regression() -> bool:
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	var grant := ItemInventoryService.grant_from_transaction(
		"qa_v208_weapon_%d" % ServerClockService.now_unix(),
		"qa_v208",
		[
			{"item_id": "wpn_gruenhain_blade", "quantity": 1},
			{"item_id": "acc_silver_ring", "quantity": 1}
		]
	)
	if not bool(grant.get("ok", false)):
		return false

	var weapon_inst := ""
	var accessory_inst := ""
	for inst in ItemInventoryService.get_owned_instances():
		var iid := str(inst.get("item_id", ""))
		if iid == "wpn_gruenhain_blade" and weapon_inst.is_empty():
			weapon_inst = str(inst.get("instance_id", ""))
		if iid == "acc_silver_ring" and accessory_inst.is_empty():
			accessory_inst = str(inst.get("instance_id", ""))

	var baseline := _stat_snapshot()
	ItemInventoryService.equip(weapon_inst, _hero_id)
	var after_weapon := _stat_snapshot()
	var weapon_ok := int(after_weapon.get("tap_real", 0)) > int(baseline.get("tap_real", 0))
	_record_assertion("v207_weapon_tap", weapon_ok, {"before": baseline, "after": after_weapon})

	ItemInventoryService.equip(accessory_inst, _hero_id)
	var after_accessory := _stat_snapshot()
	var accessory_ok := int(after_accessory.get("hero_real", 0)) > int(after_weapon.get("hero_real", 0))
	_record_assertion("v207_accessory_hero", accessory_ok, {"before": after_weapon, "after": after_accessory})

	await _open_inventory()
	await _capture("09_region_loot_inventory", "loot")
	await _capture("10_inventory_regression", "inventory")
	await _capture("11_equipment_regression", "inventory")

	_report["regression"] = {
		"weapon_tap": weapon_ok,
		"accessory_hero": accessory_ok,
		"tap_before": baseline.get("tap_real", 0),
		"tap_after_weapon": after_weapon.get("tap_real", 0),
		"hero_after_accessory": after_accessory.get("hero_real", 0)
	}
	_main.qa_prepare_combat_ready()
	return weapon_ok and accessory_ok

func _step_save_reload() -> bool:
	var export_before := {
		"region": RegionProgressionSystem.export_save_data(),
		"inventory": ItemInventoryService.export_save_data(),
		"stats": _stat_snapshot()
	}
	SaveGame.save_game()
	if not SaveGame.last_save_ok:
		return false
	RegionProgressionSystem.reset_runtime()
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	SaveGame.load_game()
	StatModifierService.rebuild_all()
	P0MonsterVisualSystem.reload_for_region(RegionProgressionSystem.combat_region_id())

	var export_after := {
		"region": RegionProgressionSystem.export_save_data(),
		"inventory": ItemInventoryService.export_save_data(),
		"stats": _stat_snapshot()
	}
	var ok := str(export_after.region.get("current_region_id", "")) == "greenvale"
	ok = ok and int(export_after.stats.get("tap_real", 0)) >= int(export_before.stats.get("tap_real", 0))
	ok = ok and int(export_after.stats.get("hero_real", 0)) >= int(export_before.stats.get("hero_real", 0))
	ok = ok and int(RegionProgressionSystem.progress_entry("greenvale").get("bosses_defeated", 0)) >= int(export_before.region.get("region_progress", {}).get("greenvale", {}).get("bosses_defeated", 0))
	_record_assertion("save_v41_reload", ok, {"before": export_before, "after": export_after})
	_report["state_evidence"]["save_reload"] = {"before": export_before, "after": export_after}
	_main.qa_prepare_combat_ready()
	await _capture("19_main_after_reload", "reload")
	await _open_inventory()
	await _capture("20_inventory_after_reload", "reload")
	return ok

func _step_viewport_matrix() -> bool:
	var scenarios := [
		{"level": 2, "label": "normal"},
		{"level": 11, "label": "elite"},
		{"level": 10, "label": "boss"}
	]
	for profile in PROFILES:
		await _apply_viewport(profile)
		for scenario in scenarios:
			PlayerData.monster_level = int(scenario.level)
			PlayerData.spawn_next_monster()
			_main.qa_prepare_combat_ready()
			_update_monster_visual_main()
			await _wait_frames(6)
			var shot := "viewport_%s_%dx%d" % [scenario.label, profile.x, profile.y]
			await _capture(shot, "viewport_matrix")
			_report["viewport_matrix"].append({
				"profile": "%dx%d" % [profile.x, profile.y],
				"scenario": scenario.label,
				"monster_id": P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level),
				"screenshot": shot
			})
	await _apply_viewport(PROFILES[0])
	return true

func _step_visual_inspection() -> bool:
	for entry in _report.get("screenshots", []):
		var analysis: Dictionary = entry.get("analysis", {})
		if not bool(analysis.get("ok", false)):
			_visual_issues.append("%s:empty_or_flat" % str(entry.get("screenshot", "")))
	_asset_mapping_check()
	_report["state_evidence"]["monster_states"] = _collect_state_evidence()
	return _visual_issues.is_empty()

func _asset_mapping_check() -> void:
	var expected := {
		"greenvale_bg": "res://assets/world/greenvale/BG001_gruenhain_home_v11.png",
		"M001_idle": "%s/M001_idle.png" % RegionProgressionSystem.monster_asset_root("greenvale"),
		"B001_idle": "%s/B001_idle.png" % RegionProgressionSystem.monster_asset_root("greenvale")
	}
	var runtime := {
		"greenvale_bg": RegionProgressionSystem.background_asset_path(),
		"M001_idle": _idle_texture_path(1),
		"B001_idle": _idle_texture_path(10)
	}
	var ok := true
	for key in expected.keys():
		if str(expected[key]) != str(runtime.get(key, "")):
			ok = false
			_visual_issues.append("asset_mapping:%s" % key)
	_record_assertion("asset_mapping_runtime", ok, {"expected": expected, "runtime": runtime})

func _collect_state_evidence() -> Dictionary:
	var out := {}
	for level in [1, 2, 11, 10]:
		var id := P0MonsterVisualSystem.production_asset_id(level)
		var states := {}
		for state in ["idle", "hit", "defeat"]:
			states[state] = _texture_path_for(id, state)
		out[id] = {
			"level": level,
			"classification": P0MonsterVisualSystem.monster_classification(level),
			"display_scale": P0MonsterVisualSystem.display_scale(level),
			"states": states
		}
	return out

func _stat_snapshot() -> Dictionary:
	CombatDamageResolver.force_next_crit = false
	var tap_hit := CombatDamageResolver.resolve_tap(PlayerData.tap_damage)
	var tap_preview := CombatDamageResolver.preview_tap(PlayerData.tap_damage)
	return {
		"tap_preview": int(tap_preview.get("normal", 0)),
		"tap_real": int(tap_hit.get("damage", 0)),
		"hero_effective": HeroSystem.get_effective_attack_damage(_hero_id),
		"hero_real": _hero_resolve_damage(_hero_id)
	}

func _hero_resolve_damage(hero_id: String) -> int:
	var hit := CombatDamageResolver.resolve_damage({
		"source_type": "hero",
		"source_id": hero_id,
		"base_damage": HeroSystem.get_effective_attack_damage(hero_id),
		"monster_level": PlayerData.monster_level
	})
	return int(hit.get("damage", 0))

func _open_inventory() -> void:
	if _main.has_method("_open_inventory_p0"):
		_main._open_inventory_p0()
	await _wait_frames(10)

func _idle_texture_path(level: int) -> String:
	var id := P0MonsterVisualSystem.production_asset_id(level)
	return _texture_path_for(id, "idle")

func _texture_path_for(encounter_id: String, state: String) -> String:
	var root := RegionProgressionSystem.monster_asset_root("greenvale")
	return "%s/%s_%s.png" % [root, encounter_id, state]

func _set_monster_state(state: String, level: int = -1) -> void:
	var use_level := level if level > 0 else PlayerData.monster_level
	var tex := P0MonsterVisualSystem.texture_for(use_level, state)
	if tex and _main and _main.monster_button:
		_main.monster_button.texture_normal = tex
	await _wait_frames(4)

func _update_monster_visual_main() -> void:
	if _main.has_method("_update_monster_visual"):
		_main._update_monster_visual()
	if _main.has_method("_update_monster_progress"):
		_main._update_monster_progress()

func _find_main() -> Control:
	return get_tree().root.find_child("MainGame", true, false) as Control

func _wait_frames(count: int) -> void:
	for _i in range(count):
		if _watchdog_exceeded():
			return
		await get_tree().process_frame

func _wait_until(predicate: Callable, max_frames: int, label: String) -> bool:
	for _i in range(max_frames):
		if _watchdog_exceeded():
			_log("timeout watchdog during %s" % label)
			return false
		if predicate.call():
			return true
		await get_tree().process_frame
	_log("timeout %s after %d frames" % [label, max_frames])
	return false

func _apply_viewport(size: Vector2i) -> void:
	get_window().size = size
	await _wait_frames(4)

func _capture(name: String, category: String = "core") -> void:
	if _watchdog_exceeded():
		return
	var path := "%s/%s.png" % [SHOT_DIR, name]
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	if img == null:
		_visual_issues.append("%s:capture_failed" % name)
		return
	img.save_png(path)
	var analysis := _analyze_image(img, path)
	_report["screenshots"].append({
		"screenshot": name,
		"category": category,
		"analysis": analysis
	})
	if not bool(analysis.get("ok", true)):
		_visual_issues.append("%s:%s" % [name, analysis.get("issue", "visual_check_failed")])

func _analyze_image(img: Image, path: String) -> Dictionary:
	if img.get_width() <= 0 or img.get_height() <= 0:
		return {"ok": false, "issue": "empty_image", "file": path}
	var bright := 0
	var dark := 0
	for y in range(0, img.get_height(), 8):
		for x in range(0, img.get_width(), 8):
			var c := img.get_pixel(x, y)
			var l := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			if l > 0.75:
				bright += 1
			elif l < 0.08:
				dark += 1
	var samples := int((img.get_width() / 8.0) * (img.get_height() / 8.0))
	return {
		"ok": bright > 0 and dark > 0,
		"file": path,
		"width": img.get_width(),
		"height": img.get_height(),
		"bright_ratio": float(bright) / float(maxi(samples, 1)),
		"dark_ratio": float(dark) / float(maxi(samples, 1))
	}

func _record_assertion(name: String, ok: bool, evidence: Dictionary = {}) -> void:
	_report["assertions"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _flush_report(final: bool) -> void:
	_report["duration_ms"] = Time.get_ticks_msec() - _start_ms
	_report["current_step"] = _current_step
	_report["failed_step"] = _failed_step
	if final:
		_report["status"] = "PASS" if _report["issues"].is_empty() and _visual_issues.is_empty() else "FAIL"
	DirAccess.make_dir_recursive_absolute(SHOT_DIR)
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))

func _finalize_report() -> Dictionary:
	var passed := 0
	for assertion in _report.get("assertions", []):
		if bool(assertion.get("ok", false)):
			passed += 1
	_report["assertions_passed"] = passed
	_report["assertions_total"] = _report.get("assertions", []).size()
	_report["qa_performance"]["elapsed_ms"] = Time.get_ticks_msec() - _start_ms
	_flush_report(true)
	return _report.duplicate(true)
