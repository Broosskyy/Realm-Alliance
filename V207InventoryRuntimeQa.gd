extends Node
## V2.07 — item-aware inventory visual + combat acceptance QA.

const CombatDamageResolver = preload("res://CombatDamageResolver.gd")

const SHOT_DIR := "res://docs/v207_visual_runtime_qa"
const REPORT_PATH := "res://docs/v207_visual_runtime_qa/inventory_qa_report.json"

const PROFILES := [
	Vector2i(1080, 2340),
	Vector2i(1080, 1920),
	Vector2i(1080, 2400),
	Vector2i(1440, 3200)
]

const RUNTIME_STAT_KEYS := ["tap_preview", "tap_real", "hero_effective", "hero_real", "crit_chance_pct"]

const MODIFIER_TO_RUNTIME := {
	"tap_damage": ["tap_preview", "tap_real"],
	"hero_damage": ["hero_effective", "hero_real"],
	"crit_chance": ["crit_chance_pct"],
	"crit_damage": ["tap_preview", "tap_real"]
}

var _report: Dictionary = {}
var _main: Control
var _hero_id: String = ""
var _visual_issues: Array[String] = []

func _log(msg: String) -> void:
	print("[V207InventoryQa] ", msg)

func run() -> Dictionary:
	_report = {
		"milestone": "V2.07",
		"status": "BLOCKED",
		"previous_false_positive": "hero_damage_did_not_rise",
		"root_cause": "QA expected hero damage rise for weapon item whose catalog modifiers only affect tap_damage",
		"fix": "QA reads item catalog modifiers and validates the declared stat semantics with negative leak checks",
		"screenshots": [],
		"viewport_matrix": [],
		"state_evidence": {},
		"assertions": [],
		"visual_issues": [],
		"issues": []
	}
	_visual_issues.clear()
	_log("booting MainGame")
	await _boot_main()
	if _main == null:
		_report["issues"].append("main_not_loaded")
		_finalize()
		return _report
	_log("apply primary viewport")
	await _apply_viewport(PROFILES[0])
	_log("acceptance flow")
	await _run_acceptance_flow()
	_log("viewport matrix")
	await _run_viewport_matrix()
	_report["visual_issues"] = _visual_issues.duplicate()
	if not _visual_issues.is_empty():
		for issue in _visual_issues:
			if issue not in _report["issues"]:
				_report["issues"].append(issue)
	_finalize()
	return _report

func _boot_main() -> void:
	P0BootDiagnostics.qa_direct_main_load = true
	get_tree().change_scene_to_file("res://MainGame.tscn")
	for _i in range(180):
		await get_tree().process_frame
		_main = get_tree().root.find_child("MainGame", true, false) as Control
		if _main != null:
			break
	await get_tree().create_timer(0.35).timeout

func _prepare_hero() -> void:
	PlayerData.player_level = maxi(PlayerData.player_level, 10)
	HeroSystem.sync_progression_unlocks()
	HeroSystem.deploy_hero("knight")
	_hero_id = HeroSystem.get_deployed_hero_id()
	if _hero_id.is_empty():
		_record_assertion("hero_setup", false, {"message": "no deployed hero"})

func _run_acceptance_flow() -> void:
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	_prepare_hero()
	if _hero_id.is_empty():
		return

	var baseline := _stat_snapshot()
	_report["state_evidence"]["hero_baseline"] = {
		"hero_id": _hero_id,
		"level": HeroSystem.get_level(_hero_id),
		"stats": baseline
	}

	await _open_inventory()
	await _shot("01_inventory_empty", "inventory")

	var weapon_item_id := "wpn_gruenhain_blade"
	var accessory_item_id := "acc_silver_ring"
	var replace_item_id := "wpn_battle_axe"

	var grant := ItemInventoryService.grant_from_transaction(
		"qa_v207_accept_%d" % ServerClockService.now_unix(),
		"qa_accept",
		[
			{"item_id": weapon_item_id, "quantity": 1},
			{"item_id": accessory_item_id, "quantity": 1},
			{"item_id": replace_item_id, "quantity": 1}
		]
	)
	var weapon_inst := _instance_for_item(grant, weapon_item_id)
	var accessory_inst := _instance_for_item(grant, accessory_item_id)
	var replace_inst := _instance_for_item(grant, replace_item_id)
	_report["state_evidence"]["loot_grant"] = grant

	await _open_inventory()
	await _select_inventory_instance(weapon_inst)
	await _shot("02_weapon_detail", "inventory_detail")
	_record_item_equip_assertion(weapon_item_id, weapon_inst, baseline, "weapon_equip")

	var after_weapon := _stat_snapshot()
	await _open_heroes()
	await _shot("03_weapon_equipped", "hero_equipment")
	if _main.has_method("_switch_view") and _main.view_tap != null:
		_main.call("_switch_view", _main.view_tap)
		await get_tree().process_frame
	await _shot("04_tap_combat_after_weapon", "combat")

	await _select_inventory_instance(accessory_inst)
	await _shot("05_accessory_detail", "inventory_detail")
	var before_accessory := _stat_snapshot()
	_record_item_equip_assertion(accessory_item_id, accessory_inst, before_accessory, "accessory_equip")
	var after_accessory := _stat_snapshot()
	await _open_heroes()
	await _shot("06_accessory_equipped", "hero_equipment")
	if _main.has_method("_switch_view") and _main.view_tap != null:
		_main.call("_switch_view", _main.view_tap)
		await get_tree().process_frame
	await _shot("07_hero_combat_after_accessory", "combat")
	await _open_heroes()
	await _shot("08_both_slots_equipped", "hero_equipment")

	var before_replace := _stat_snapshot()
	var replace_result := ItemInventoryService.equip(replace_inst, _hero_id)
	var after_replace := _stat_snapshot()
	_record_replace_assertion(weapon_item_id, replace_item_id, weapon_inst, replace_inst, replace_result, before_replace, after_replace)
	await _open_inventory()
	await _select_inventory_instance(replace_inst)
	await _shot("09_item_replacement", "inventory")

	var before_unequip := _stat_snapshot()
	var unequip_result := ItemInventoryService.unequip(replace_inst)
	var after_unequip_weapon := _stat_snapshot()
	_record_unequip_assertion(replace_item_id, replace_inst, unequip_result, before_unequip, after_unequip_weapon, after_accessory)

	await _run_save_reload_test(accessory_inst, replace_inst, after_accessory)
	await _run_boss_chest_loot_shots()

func _run_boss_chest_loot_shots() -> void:
	LootTableService.set_qa_forced_roll("boss", "acc_guardian_pendant", 1)
	var boss_level := P0MonsterVisualSystem.boss_every_kills()
	var boss_txn := RewardPipeline.grant_monster_defeat(boss_level, true)
	LootTableService.clear_qa_forced_roll()
	_report["state_evidence"]["boss_loot"] = boss_txn
	RewardService.present({
		"title": "BOSS BESIEGT",
		"gold": int(boss_txn.get("reward", {}).get("gold", 0)),
		"granted_items": boss_txn.get("granted_items", [])
	})
	await get_tree().create_timer(0.2).timeout
	await _shot("10_boss_loot", "reward")
	_dismiss_reward_modals()

	var chest := ChestRewardSystem.acquire_chest("boss", "qa_v207_chest")
	LootTableService.set_qa_forced_roll("chest_boss", "wpn_gruenhain_blade", 1)
	var open := ChestRewardSystem.open_chest(str(chest.get("chest_id", "")))
	LootTableService.clear_qa_forced_roll()
	_report["state_evidence"]["chest_loot"] = open
	if bool(open.get("ok", false)):
		var reward_txn: Dictionary = open.get("reward_transaction", {})
		RewardService.present({
			"title": "Truhe geöffnet",
			"gold": int(open.get("reward", {}).get("gold", 0)),
			"granted_items": reward_txn.get("granted_items", [])
		})
		await get_tree().create_timer(0.2).timeout
		await _shot("11_chest_item_reward", "reward")
	_dismiss_reward_modals()

func _dismiss_reward_modals() -> void:
	if _main == null:
		return
	for name in ["RewardModalClose", "MonsterRewardContinue"]:
		var btn := _main.find_child(name, true, false) as Button
		if btn != null and btn.visible:
			btn.emit_signal("pressed")
	if _main.has_method("_reset_core_transient_state"):
		_main.call("_reset_core_transient_state")
	await get_tree().process_frame

func _run_save_reload_test(accessory_inst: String, _replace_inst: String, expected_stats: Dictionary) -> void:
	if accessory_inst.is_empty():
		_record_assertion("save_reload_setup", false, {"message": "missing accessory instance"})
		return
	ItemInventoryService.equip(accessory_inst, _hero_id)
	var weapon_inst := ""
	for inst in ItemInventoryService.get_owned_instances():
		if str(inst.get("item_id", "")) == "wpn_gruenhain_blade":
			weapon_inst = str(inst.get("instance_id", ""))
			break
	if not weapon_inst.is_empty():
		ItemInventoryService.equip(weapon_inst, _hero_id)

	var before_save := _stat_snapshot()
	var export_before: Dictionary = ItemInventoryService.export_save_data()
	SaveGame.save_game()
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	SaveGame.load_game()
	StatModifierService.rebuild_all()
	var export_after: Dictionary = ItemInventoryService.export_save_data()
	var after_reload := _stat_snapshot()

	var equipped_ok: bool = _equipped_mapping_matches(export_before, export_after, _hero_id)
	var instances_ok: bool = _equipped_instances_preserved(export_before, export_after, _hero_id)
	var tap_ok := int(after_reload.get("tap_real", 0)) >= int(before_save.get("tap_real", 0))
	var hero_ok := int(after_reload.get("hero_real", 0)) >= int(expected_stats.get("hero_real", 0))
	var no_double := int(after_reload.get("hero_real", 0)) <= int(before_save.get("hero_real", 0)) + 2

	_report["state_evidence"]["save_reload"] = {
		"instances_match": instances_ok,
		"equipped_match": equipped_ok,
		"tap_before": before_save.get("tap_real", 0),
		"tap_after_reload": after_reload.get("tap_real", 0),
		"hero_before": before_save.get("hero_real", 0),
		"hero_after_reload": after_reload.get("hero_real", 0),
		"modifier_state": StatModifierService.export_debug_state()
	}
	_record_assertion("save_reload_equipment", instances_ok and equipped_ok, _report["state_evidence"]["save_reload"])
	_record_assertion("save_reload_tap_preserved", tap_ok, {"before": before_save, "after": after_reload})
	_record_assertion("save_reload_hero_preserved", hero_ok, {"before": before_save, "after": after_reload})
	_record_assertion("save_reload_no_double_modifier", no_double, _report["state_evidence"]["save_reload"])

	await _open_inventory()
	await _shot("12_inventory_after_reload", "inventory")

func _run_viewport_matrix() -> void:
	for profile in PROFILES:
		await _apply_viewport(profile)
		await _open_inventory()
		var shot_name := "viewport_inventory_%dx%d" % [profile.x, profile.y]
		var analysis := await _shot(shot_name, "viewport_matrix")
		_report["viewport_matrix"].append({
			"profile": "%dx%d" % [profile.x, profile.y],
			"screenshot": shot_name,
			"analysis": analysis
		})
		await _open_heroes()
		shot_name = "viewport_heroes_%dx%d" % [profile.x, profile.y]
		analysis = await _shot(shot_name, "viewport_matrix")
		_report["viewport_matrix"].append({
			"profile": "%dx%d" % [profile.x, profile.y],
			"screenshot": shot_name,
			"analysis": analysis
		})
		if _main.has_method("_switch_view") and _main.view_tap != null:
			_main.call("_switch_view", _main.view_tap)
			await get_tree().process_frame
		shot_name = "viewport_main_%dx%d" % [profile.x, profile.y]
		analysis = await _shot(shot_name, "viewport_matrix")
		_report["viewport_matrix"].append({
			"profile": "%dx%d" % [profile.x, profile.y],
			"screenshot": shot_name,
			"analysis": analysis
		})
	await _apply_viewport(PROFILES[0])

func _modifier_stats_from_def(item_id: String) -> Array[String]:
	var out: Array[String] = []
	var def := ItemInventoryService.get_item_definition(item_id)
	for entry in def.get("modifiers", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var stat := str(entry.get("stat", ""))
		if stat.is_empty():
			continue
		if stat not in out:
			out.append(stat)
	return out

func _affected_runtime_keys(modifier_stats: Array[String]) -> Array[String]:
	var keys: Array[String] = []
	for stat in modifier_stats:
		for key in MODIFIER_TO_RUNTIME.get(stat, []):
			if key not in keys:
				keys.append(key)
	return keys

func _stat_snapshot() -> Dictionary:
	CombatDamageResolver.force_next_crit = false
	var tap_hit := CombatDamageResolver.resolve_tap(PlayerData.tap_damage)
	var tap_preview := CombatDamageResolver.preview_tap(PlayerData.tap_damage)
	var hero_real := _hero_resolve_damage(_hero_id)
	return {
		"tap_preview": int(tap_preview.get("normal", 0)),
		"tap_real": int(tap_hit.get("damage", 0)),
		"hero_effective": HeroSystem.get_effective_attack_damage(_hero_id),
		"hero_real": hero_real,
		"crit_chance_pct": int(tap_preview.get("crit_chance_pct", 0))
	}

func _hero_resolve_damage(hero_id: String) -> int:
	var hit := CombatDamageResolver.resolve_damage({
		"source_type": "hero",
		"source_id": hero_id,
		"base_damage": HeroSystem.get_base_power(hero_id),
		"target_id": "qa_target"
	})
	return int(hit.get("damage", 0))

func _record_item_equip_assertion(item_id: String, instance_id: String, before: Dictionary, label: String) -> void:
	if instance_id.is_empty():
		_record_assertion("%s_missing_instance" % label, false, {"item_id": item_id})
		return
	var equip := ItemInventoryService.equip(instance_id, _hero_id)
	var after := _stat_snapshot()
	var modifier_stats := _modifier_stats_from_def(item_id)
	var affected := _affected_runtime_keys(modifier_stats)
	var evidence := {
		"item_id": item_id,
		"instance_id": instance_id,
		"modifier_stats": modifier_stats,
		"before": before,
		"after": after,
		"equip_result": equip
	}
	var ok := bool(equip.get("ok", false))
	for stat in modifier_stats:
		for key in MODIFIER_TO_RUNTIME.get(stat, []):
			var before_v := int(before.get(key, 0))
			var after_v := int(after.get(key, 0))
			var real_key: bool = key.ends_with("_real")
			if real_key and after_v < before_v:
				ok = false
				evidence["failed_stat"] = stat
				evidence["failed_key"] = key
			elif not real_key and after_v <= before_v:
				ok = false
				evidence["failed_stat"] = stat
				evidence["failed_key"] = key
	for key in RUNTIME_STAT_KEYS:
		if key in affected or key.ends_with("_real"):
			continue
		if before.get(key, 0) != after.get(key, 0):
			ok = false
			evidence["leak_key"] = key
	_report["state_evidence"][label] = evidence
	_record_assertion(label, ok, evidence)

func _record_replace_assertion(old_item_id: String, new_item_id: String, old_inst: String, new_inst: String, result: Dictionary, before: Dictionary, after: Dictionary) -> void:
	var old_state := ItemInventoryService.get_instance(old_inst)
	var new_state := ItemInventoryService.get_instance(new_inst)
	var ok := bool(result.get("ok", false))
	ok = ok and str(result.get("previous_instance_id", "")) == old_inst
	ok = ok and not bool(old_state.get("equipped", true))
	ok = ok and bool(new_state.get("equipped", false))
	ok = ok and str(new_state.get("equipped_to", "")) == _hero_id
	var old_stats := _modifier_stats_from_def(old_item_id)
	var new_stats := _modifier_stats_from_def(new_item_id)
	for stat in new_stats:
		for key in MODIFIER_TO_RUNTIME.get(stat, []):
			if int(after.get(key, 0)) < int(before.get(key, 0)) and stat == "tap_damage":
				ok = false
	var evidence := {
		"old_item_id": old_item_id,
		"new_item_id": new_item_id,
		"old_instance": old_inst,
		"new_instance": new_inst,
		"old_equipped": old_state.get("equipped", false),
		"new_equipped": new_state.get("equipped", false),
		"before": before,
		"after": after,
		"result": result
	}
	_report["state_evidence"]["replace"] = evidence
	_record_assertion("slot_replacement", ok, evidence)

func _record_unequip_assertion(item_id: String, instance_id: String, result: Dictionary, before: Dictionary, after: Dictionary, accessory_baseline: Dictionary) -> void:
	var inst := ItemInventoryService.get_instance(instance_id)
	var ok := bool(result.get("ok", false))
	ok = ok and not bool(inst.get("equipped", true))
	var modifier_stats := _modifier_stats_from_def(item_id)
	for stat in modifier_stats:
		for key in MODIFIER_TO_RUNTIME.get(stat, []):
			if int(after.get(key, 0)) >= int(before.get(key, 0)):
				ok = false
	# hero accessory should remain
	if int(after.get("hero_real", 0)) < int(accessory_baseline.get("hero_real", 0)):
		ok = false
	var evidence := {
		"item_id": item_id,
		"instance_id": instance_id,
		"before": before,
		"after": after,
		"accessory_baseline": accessory_baseline,
		"result": result
	}
	_report["state_evidence"]["unequip"] = evidence
	_record_assertion("unequip", ok, evidence)

func _record_assertion(name: String, ok: bool, evidence: Dictionary) -> void:
	_report["assertions"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _equipped_mapping_matches(export_before: Dictionary, export_after: Dictionary, hero_id: String) -> bool:
	var before_map: Dictionary = export_before.get("equipped_by_hero", {}).get(hero_id, {})
	var after_map: Dictionary = export_after.get("equipped_by_hero", {}).get(hero_id, {})
	return before_map == after_map

func _equipped_instances_preserved(export_before: Dictionary, export_after: Dictionary, hero_id: String) -> bool:
	var before_map: Dictionary = export_before.get("equipped_by_hero", {}).get(hero_id, {})
	var after_instances: Dictionary = export_after.get("instances", {})
	for slot in before_map.keys():
		var instance_id := str(before_map.get(slot, ""))
		if instance_id.is_empty() or not after_instances.has(instance_id):
			return false
		var inst: Dictionary = after_instances[instance_id]
		if not bool(inst.get("equipped", false)):
			return false
		if str(inst.get("equipped_to", "")) != hero_id:
			return false
		if str(inst.get("slot", "")) != str(slot):
			return false
	return true

func _instance_for_item(grant: Dictionary, item_id: String) -> String:
	for inst in grant.get("granted_items", []):
		if str(inst.get("item_id", "")) == item_id:
			return str(inst.get("instance_id", ""))
	return ""

func _ensure_core_unlocked() -> void:
	if _main == null:
		return
	if _main.has_method("_reset_core_transient_state"):
		_main.call("_reset_core_transient_state")
	_main.core_input_locked = false

func _open_inventory() -> void:
	_ensure_core_unlocked()
	if _main != null and _main.has_method("_open_inventory_p0"):
		_main.call("_open_inventory_p0")
		await get_tree().process_frame
		await get_tree().create_timer(0.08).timeout

func _open_heroes() -> void:
	_ensure_core_unlocked()
	if _main != null and _main.has_method("_open_heroes_slice"):
		_main.call("_open_heroes_slice")
		await get_tree().process_frame
		await get_tree().create_timer(0.08).timeout

func _select_inventory_instance(instance_id: String) -> void:
	if instance_id.is_empty() or _main == null:
		return
	if _main.inventory_ui != null:
		_main.inventory_ui.select_instance(instance_id)
		await get_tree().process_frame

func _apply_viewport(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(size)
	var root := get_tree().root
	if root is Window:
		(root as Window).size = size
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

func _shot(name: String, category: String) -> Dictionary:
	await get_tree().process_frame
	await get_tree().create_timer(0.06).timeout
	var path := "%s/%s.png" % [SHOT_DIR, name]
	var analysis := _capture_and_analyze(path, category)
	_report["screenshots"].append({
		"name": name,
		"category": category,
		"path": path,
		"analysis": analysis
	})
	if not bool(analysis.get("ok", false)):
		_visual_issues.append("%s: %s" % [name, str(analysis.get("reason", "analysis_fail"))])
	return analysis

func _capture_and_analyze(res_path: String, category: String) -> Dictionary:
	var vp := get_tree().root.get_viewport()
	if vp == null:
		return {"ok": false, "reason": "no_viewport"}
	var tex := vp.get_texture()
	if tex == null:
		return {"ok": false, "reason": "no_texture"}
	var img := tex.get_image()
	if img == null or img.is_empty():
		return {"ok": false, "reason": "empty_image"}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var saved := img.save_png(ProjectSettings.globalize_path(res_path)) == OK
	if not saved:
		return {"ok": false, "reason": "save_failed"}
	return _analyze_image(img, res_path, category)

func _analyze_image(img: Image, rel_path: String, category: String) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var dark := 0
	var bright := 0
	var samples := 0
	var step := maxi(1, w / 120)
	for y in range(0, h, step):
		for x in range(0, w, step):
			var c := img.get_pixel(x, y)
			samples += 1
			var lum := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			if lum < 0.06:
				dark += 1
			if lum > 0.18:
				bright += 1
	var dark_ratio := float(dark) / maxf(float(samples), 1.0)
	var bright_ratio := float(bright) / maxf(float(samples), 1.0)
	var min_h := 1600 if h >= 2000 else 900
	var ok := w >= 900 and h >= min_h and dark_ratio < 0.93 and bright_ratio > 0.03
	var result := {
		"ok": ok,
		"file": rel_path,
		"category": category,
		"width": w,
		"height": h,
		"dark_ratio": snapped(dark_ratio, 0.001),
		"bright_ratio": snapped(bright_ratio, 0.001)
	}
	if not ok:
		result["reason"] = "dark=%.2f bright=%.2f size=%dx%d" % [dark_ratio, bright_ratio, w, h]
	return result

func _finalize() -> void:
	var assertions_ok := true
	for entry in _report.get("assertions", []):
		if not bool(entry.get("ok", false)):
			assertions_ok = false
			break
	var shots_ok := true
	for shot in _report.get("screenshots", []):
		if not bool(shot.get("analysis", {}).get("ok", false)):
			shots_ok = false
	_report["status"] = "PASS" if _report["issues"].is_empty() and assertions_ok and shots_ok else "FAIL"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))
		file.close()
	print(JSON.stringify({
		"status": _report["status"],
		"issues": _report["issues"],
		"assertions": _report["assertions"].size(),
		"screenshots": _report["screenshots"].size()
	}))
