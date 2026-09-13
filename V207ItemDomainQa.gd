extends Node
## V2.07 — item domain runtime QA (Phase 1 + Phase 2 equip/combat).

const REPORT_PATH := "res://docs/v207_domain_qa/domain_qa_report.json"

var _report: Dictionary = {}
var _event_counts: Dictionary = {}

func run() -> Dictionary:
	_event_counts.clear()
	if not GameplayEventService.event_emitted.is_connected(_on_qa_event):
		GameplayEventService.event_emitted.connect(_on_qa_event)
	_report = {
		"milestone": "V2.07",
		"status": "BLOCKED",
		"tests": [],
		"state_evidence": {},
		"regressions": {},
		"catalog": {},
		"issues": []
	}
	_run_catalog_tests()
	_run_grant_tests()
	_run_idempotency_tests()
	_run_reward_pipeline_tests()
	_run_loot_table_tests()
	_run_boss_chest_integration_tests()
	_run_save_reload_test()
	_run_equip_flow_tests()
	_finalize()
	return _report.duplicate(true)

func _on_qa_event(event_name: String, amount: int, _context: Dictionary) -> void:
	_event_counts[event_name] = int(_event_counts.get(event_name, 0)) + amount

func _run_catalog_tests() -> void:
	var ok := ItemInventoryService.catalog_count() >= 4
	ok = ok and ItemInventoryService.validation_errors.is_empty()
	ok = ok and LootTableService.validation_errors.is_empty()
	_report["catalog"] = {
		"item_count": ItemInventoryService.catalog_count(),
		"item_ids": ItemInventoryService.catalog_item_ids(),
		"validation_errors": ItemInventoryService.validation_errors.duplicate()
	}
	_record_test("catalog_load", ok, {"catalog": _report["catalog"]})

func _run_grant_tests() -> void:
	ItemInventoryService.reset_runtime()
	var txn := "qa_grant_%d" % ServerClockService.now_unix()
	var result := ItemInventoryService.grant_from_transaction(
		txn,
		"qa_test",
		[{"item_id": "wpn_gruenhain_blade", "quantity": 1}],
		{"qa": true}
	)
	var ok := bool(result.get("ok", false))
	var inst_id := ""
	if not result.get("granted_items", []).is_empty():
		inst_id = str(result.granted_items[0].get("instance_id", ""))
	ok = ok and not inst_id.is_empty() and ItemInventoryService.instances.has(inst_id)
	_report["state_evidence"]["grant"] = {
		"transaction_id": txn,
		"source": "qa_test",
		"item_id": "wpn_gruenhain_blade",
		"instance_id": inst_id,
		"inventory_count": ItemInventoryService.snapshot_instance_count()
	}
	_record_test("item_grant_instance", ok, _report["state_evidence"]["grant"])

func _run_idempotency_tests() -> void:
	ItemInventoryService.reset_runtime()
	var txn := "qa_idempotent_%d" % ServerClockService.now_unix()
	var first := ItemInventoryService.grant_from_transaction(
		txn,
		"qa_idempotent",
		[{"item_id": "acc_silver_ring", "quantity": 1}]
	)
	var count_after_first := ItemInventoryService.snapshot_instance_count()
	var second := ItemInventoryService.grant_from_transaction(
		txn,
		"qa_idempotent",
		[{"item_id": "acc_silver_ring", "quantity": 1}]
	)
	var ok := bool(first.get("ok", false)) and bool(second.get("ok", false))
	ok = ok and bool(second.get("duplicate", false))
	ok = ok and ItemInventoryService.snapshot_instance_count() == count_after_first
	_report["state_evidence"]["idempotency"] = {
		"transaction_id": txn,
		"first_inventory_count": count_after_first,
		"second_duplicate": bool(second.get("duplicate", false)),
		"inventory_count_after_duplicate": ItemInventoryService.snapshot_instance_count()
	}
	_record_test("duplicate_transaction_blocked", ok, _report["state_evidence"]["idempotency"])

func _run_reward_pipeline_tests() -> void:
	ItemInventoryService.reset_runtime()
	var gold_before := PlayerData.gold
	var currency_txn := RewardPipeline.grant("qa_currency", {
		"gold": 50,
		"transaction_id": "qa_currency_only_%d" % ServerClockService.now_unix()
	})
	var currency_ok := bool(currency_txn.get("ok", false)) and PlayerData.gold == gold_before + 50
	_report["regressions"]["currency_only"] = currency_ok

	var mixed_txn_id := "qa_mixed_%d" % ServerClockService.now_unix()
	var mixed := RewardPipeline.grant("qa_mixed", {
		"gold": 25,
		"items": [{"item_id": "wpn_battle_axe", "quantity": 1}],
		"transaction_id": mixed_txn_id
	})
	var mixed_ok: bool = bool(mixed.get("ok", false))
	mixed_ok = mixed_ok and (mixed.get("granted_items", []) as Array).size() == 1
	mixed_ok = mixed_ok and ItemInventoryService.snapshot_instance_count() == 1
	_report["state_evidence"]["mixed_reward"] = {
		"transaction_id": mixed_txn_id,
		"gold_delta": PlayerData.gold - gold_before,
		"granted_items": mixed.get("granted_items", []),
		"inventory_count": ItemInventoryService.snapshot_instance_count()
	}
	_record_test("reward_pipeline_currency_regression", currency_ok, {"gold_after": PlayerData.gold})
	_record_test("reward_pipeline_currency_plus_item", mixed_ok, _report["state_evidence"]["mixed_reward"])

	var invalid := RewardPipeline.grant("qa_invalid", {
		"gold": 10,
		"items": [{"item_id": "does_not_exist", "quantity": 1}],
		"transaction_id": "qa_invalid_%d" % ServerClockService.now_unix()
	})
	_record_test("invalid_item_blocked", not bool(invalid.get("ok", false)), {"error_code": invalid.get("error_code", "")})

func _run_loot_table_tests() -> void:
	LootTableService.set_qa_forced_roll("boss", "acc_guardian_pendant", 1)
	var rolled: Array = LootTableService.roll("boss")
	var ok := rolled.size() == 1 and str(rolled[0].get("item_id", "")) == "acc_guardian_pendant"
	LootTableService.clear_qa_forced_roll()
	_record_test("loot_table_qa_forced_roll", ok, {"rolled": rolled})

func _run_boss_chest_integration_tests() -> void:
	ItemInventoryService.reset_runtime()
	LootTableService.set_qa_forced_roll("boss", "wpn_gruenhain_blade", 1)
	var boss_level := P0MonsterVisualSystem.boss_every_kills()
	var boss_txn := RewardPipeline.grant_monster_defeat(boss_level, true)
	var boss_ok: bool = bool(boss_txn.get("ok", false)) and (boss_txn.get("granted_items", []) as Array).size() >= 1
	LootTableService.clear_qa_forced_roll()

	ItemInventoryService.reset_runtime()
	LootTableService.set_qa_forced_roll("chest_boss", "acc_guardian_pendant", 1)
	var chest := ChestRewardSystem.acquire_chest("boss", "qa_chest")
	var open := ChestRewardSystem.open_chest(str(chest.get("chest_id", "")))
	var chest_ok: bool = bool(open.get("ok", false)) and ItemInventoryService.snapshot_instance_count() >= 1
	var duplicate := ChestRewardSystem.open_chest(str(chest.get("chest_id", "")))
	var dup_ok := not bool(duplicate.get("ok", false))
	LootTableService.clear_qa_forced_roll()

	_report["state_evidence"]["boss_chest"] = {
		"boss_granted_items": boss_txn.get("granted_items", []),
		"chest_open_ok": chest_ok,
		"chest_duplicate_blocked": dup_ok,
		"inventory_count": ItemInventoryService.snapshot_instance_count()
	}
	_record_test("boss_reward_item_grant", boss_ok, {"txn": boss_txn.get("transaction_id", "")})
	_record_test("chest_reward_item_grant", chest_ok, _report["state_evidence"]["boss_chest"])
	_record_test("chest_duplicate_open_blocked", dup_ok, {})

func _run_save_reload_test() -> void:
	ItemInventoryService.reset_runtime()
	var txn := "qa_save_%d" % ServerClockService.now_unix()
	var grant := ItemInventoryService.grant_from_transaction(
		txn,
		"qa_save",
		[{"item_id": "acc_guardian_pendant", "quantity": 1}]
	)
	var inst_id := ""
	if not grant.get("granted_items", []).is_empty():
		inst_id = str(grant.granted_items[0].get("instance_id", ""))
	var before_count := ItemInventoryService.snapshot_instance_count()
	var exported := ItemInventoryService.export_save_data()
	ItemInventoryService.reset_runtime()
	ItemInventoryService.apply_save_data(exported)
	var after_count := ItemInventoryService.snapshot_instance_count()
	var ok := before_count == after_count and after_count == 1
	ok = ok and ItemInventoryService.instances.has(inst_id)
	_report["state_evidence"]["save"] = {
		"instances_before": before_count,
		"instances_after_reload": after_count,
		"instance_id": inst_id,
		"preserved": ItemInventoryService.instances.has(inst_id)
	}
	_record_test("serialization_roundtrip", ok, _report["state_evidence"]["save"])

	SaveGame.save_game()
	var saved_instances := ItemInventoryService.snapshot_instance_count()
	SaveGame.load_game()
	var loaded_ok := ItemInventoryService.snapshot_instance_count() == saved_instances
	_record_test("save_game_reload", loaded_ok, {
		"saved_instances": saved_instances,
		"loaded_instances": ItemInventoryService.snapshot_instance_count()
	})

func _grant_item(item_id: String, source: String = "qa_equip") -> String:
	var txn := "qa_%s_%d" % [item_id, ServerClockService.now_unix()]
	var result := ItemInventoryService.grant_from_transaction(txn, source, [{"item_id": item_id, "quantity": 1}])
	if not bool(result.get("ok", false)) or (result.get("granted_items", []) as Array).is_empty():
		return ""
	return str(result.granted_items[0].get("instance_id", ""))

func _run_equip_flow_tests() -> void:
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	PlayerData.player_level = maxi(PlayerData.player_level, 10)
	HeroSystem.sync_progression_unlocks()
	if not HeroSystem.deploy_hero("knight"):
		HeroSystem.deploy_hero(HeroSystem.get_selected_hero_id())
	var hero_id := HeroSystem.get_deployed_hero_id()
	if hero_id.is_empty():
		_record_test("equip_flow_setup", false, {"message": "no unlocked hero for equip QA"})
		return
	_record_test("equip_flow_setup", true, {"hero_id": hero_id})
	var baseline_damage := HeroSystem.get_effective_attack_damage(hero_id)
	var baseline_tap: int = int(CombatDamageResolver.preview_tap(PlayerData.tap_damage).get("normal", PlayerData.tap_damage))

	var weapon_id := _grant_item("wpn_gruenhain_blade")
	var accessory_id := _grant_item("acc_silver_ring")
	var axe_id := _grant_item("wpn_battle_axe")

	var wrong_slot := ItemInventoryService.equip(accessory_id, hero_id, "weapon")
	_record_test("wrong_slot_rejected", not bool(wrong_slot.get("ok", false)), wrong_slot)

	var equip_weapon := ItemInventoryService.equip(weapon_id, hero_id)
	var after_weapon_damage := HeroSystem.get_effective_attack_damage(hero_id)
	var tap_after_weapon := int(CombatDamageResolver.preview_tap(PlayerData.tap_damage).get("normal", 0))
	var weapon_ok := bool(equip_weapon.get("ok", false)) and tap_after_weapon >= int(baseline_tap)
	_record_test("equip_item_weapon", weapon_ok, {
		"hero_id": hero_id,
		"instance_id": weapon_id,
		"hero_damage_before": baseline_damage,
		"hero_damage_after_weapon": after_weapon_damage,
		"tap_before": baseline_tap,
		"tap_after_weapon": tap_after_weapon
	})

	var equip_accessory := ItemInventoryService.equip(accessory_id, hero_id)
	var after_accessory_damage := HeroSystem.get_effective_attack_damage(hero_id)
	var accessory_ok := bool(equip_accessory.get("ok", false)) and after_accessory_damage > baseline_damage
	_record_test("modifier_added", accessory_ok, {
		"damage_before": baseline_damage,
		"damage_after_accessory": after_accessory_damage
	})
	_record_test("hero_damage_rises", after_accessory_damage > baseline_damage, {
		"baseline": baseline_damage,
		"after": after_accessory_damage
	})

	var replace := ItemInventoryService.equip(axe_id, hero_id)
	var replaced_id := str(replace.get("previous_instance_id", ""))
	var replace_ok := bool(replace.get("ok", false)) and replaced_id == weapon_id
	var old_inst := ItemInventoryService.get_instance(weapon_id)
	replace_ok = replace_ok and not bool(old_inst.get("equipped", true))
	_record_test("replace_equipped_item", replace_ok, replace)
	var tap_after_axe := int(CombatDamageResolver.preview_tap(PlayerData.tap_damage).get("normal", 0))

	var unequip := ItemInventoryService.unequip(axe_id)
	var after_unequip_damage := HeroSystem.get_effective_attack_damage(hero_id)
	var tap_after_unequip := int(CombatDamageResolver.preview_tap(PlayerData.tap_damage).get("normal", 0))
	var unequip_ok := bool(unequip.get("ok", false)) and tap_after_unequip < tap_after_axe
	_record_test("unequip_item", unequip_ok, unequip)
	_record_test("modifier_removed", tap_after_unequip < tap_after_axe, {
		"tap_with_axe": tap_after_axe,
		"tap_after_unequip": tap_after_unequip
	})
	_record_test("hero_damage_returns_after_unequip", after_unequip_damage == after_accessory_damage, {
		"after_accessory": after_accessory_damage,
		"after_unequip_weapon": after_unequip_damage
	})

	_record_test("tap_damage_with_equipment", tap_after_weapon >= int(baseline_tap), {
		"tap_before": baseline_tap,
		"tap_after_weapon": tap_after_weapon
	})

	var exported := ItemInventoryService.export_save_data()
	var equipped_before: Dictionary = exported.get("equipped_by_hero", {})
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	ItemInventoryService.apply_save_data(exported)
	StatModifierService.rebuild_all()
	var reload_damage := HeroSystem.get_effective_attack_damage(hero_id)
	var save_ok := ItemInventoryService.snapshot_instance_count() >= 2
	save_ok = save_ok and equipped_before == ItemInventoryService.export_save_data().get("equipped_by_hero", {})
	save_ok = save_ok and reload_damage == after_unequip_damage
	_report["state_evidence"]["equipment_save"] = {
		"equipped_before": equipped_before,
		"equipped_after_reload": ItemInventoryService.export_save_data().get("equipped_by_hero", {}),
		"modifier_state": StatModifierService.export_debug_state()
	}
	_record_test("save_reload_equipment", save_ok, _report["state_evidence"]["equipment_save"])
	_record_test("modifier_reconstruct_after_reload", reload_damage == after_unequip_damage, {
		"expected": after_unequip_damage,
		"actual": reload_damage
	})
	_record_test("item_equipped_event", int(_event_counts.get(GameplayEventService.EVENT_ITEM_EQUIPPED, 0)) >= 2, _event_counts)

	var dup_txn := "qa_dup_equip_%d" % ServerClockService.now_unix()
	var first := ItemInventoryService.grant_from_transaction(dup_txn, "qa_dup", [{"item_id": "acc_guardian_pendant", "quantity": 1}])
	var second := ItemInventoryService.grant_from_transaction(dup_txn, "qa_dup", [{"item_id": "acc_guardian_pendant", "quantity": 1}])
	_record_test("duplicate_reward_still_blocked", bool(first.get("ok", false)) and bool(second.get("duplicate", false)), {
		"transaction_id": dup_txn
	})

func _record_test(name: String, ok: bool, evidence: Dictionary) -> void:
	_report["tests"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _finalize() -> void:
	var all_ok := true
	for test in _report["tests"]:
		if not bool(test.get("ok", false)):
			all_ok = false
			break
	_report["status"] = "PASS" if all_ok else "FAIL"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/v207_domain_qa"))
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))
		file.close()
	print(JSON.stringify({
		"status": _report["status"],
		"tests_passed": _report["tests"].filter(func(t): return bool(t.get("ok", false))).size(),
		"tests_total": _report["tests"].size(),
		"issues": _report["issues"]
	}))
