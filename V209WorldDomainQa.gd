extends Node
## V2.09 Phase 2 — Grünhain encounter domain QA (headless).

const EncounterCatalogValidator = preload("res://EncounterCatalogValidator.gd")
const REPORT_PATH := "res://docs/v209_domain_qa/world_domain_qa_report.json"

var _report: Dictionary = {}

func run() -> Dictionary:
	_report = {
		"milestone": "V2.09-Phase2",
		"status": "BLOCKED",
		"tests": [],
		"state_evidence": {},
		"issues": []
	}
	P0MonsterVisualSystem.reload_for_region("greenvale")
	_run_catalog_validator()
	_run_cycle_length()
	_run_curated_rotation()
	_run_active_production_assets()
	_run_m010_before_boss()
	_run_loot_semantics()
	_run_loot_simulation()
	_run_classification_runtime_values()
	_run_hero_pacing_simulation()
	_run_legacy_deprecation()
	_run_save_reload()
	_finalize()
	return _report.duplicate(true)

func _boss_every() -> int:
	return P0MonsterVisualSystem.boss_every_kills()

func _elite_level() -> int:
	for level in range(1, _boss_every()):
		if P0MonsterVisualSystem.production_asset_id(level) == "M010":
			return level
	return -1

func _sequence_ids() -> Array:
	var ids: Array = []
	for level in range(1, _boss_every() + 1):
		ids.append(P0MonsterVisualSystem.production_asset_id(level))
	return ids

func _record_test(name: String, ok: bool, evidence: Dictionary = {}) -> void:
	_report["tests"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _run_catalog_validator() -> void:
	var errors := EncounterCatalogValidator.validate_greenvale()
	var ok := errors.is_empty()
	_record_test("encounter_catalog_validator", ok, {"errors": errors, "error_count": errors.size()})

func _run_cycle_length() -> void:
	var count := _boss_every()
	var ok := count >= 14 and count <= 16
	_record_test("cycle_length_14_to_16", ok, {
		"encounter_count": count,
		"catalog_version": P0MonsterVisualSystem.data.get("version", "")
	})

func _run_curated_rotation() -> void:
	var ids := _sequence_ids()
	var rotation: Array = P0MonsterVisualSystem.data.get("rotation", [])
	var ok := ids.size() == _boss_every()
	ok = ok and rotation.size() == _boss_every() - 1
	for reserve_id in ["M006", "M013", "M008", "M011"]:
		ok = ok and reserve_id in rotation
	for blocked in ["M007", "M014", "B002", "B003"]:
		ok = ok and not (blocked in rotation)
	_report["state_evidence"]["curated_rotation"] = {"sequence": ids, "rotation_size": rotation.size()}
	_record_test("curated_encounter_sequence", ok, _report["state_evidence"]["curated_rotation"])

func _run_active_production_assets() -> void:
	var missing: Array = []
	var checked: Array = []
	for level in range(1, _boss_every() + 1):
		var monster_id := P0MonsterVisualSystem.production_asset_id(level)
		if monster_id in checked:
			continue
		checked.append(monster_id)
		var root := RegionProgressionSystem.monster_asset_root("greenvale")
		for state in ["idle", "attack", "hit", "defeat"]:
			var path := "%s/%s_%s.png" % [root, monster_id, state]
			if not ResourceLoader.exists(path):
				missing.append(path)
	var ok := missing.is_empty()
	_record_test("active_production_asset_refs", ok, {"checked_ids": checked, "missing": missing})

func _run_m010_before_boss() -> void:
	var elite_level := _elite_level()
	var boss_level := _boss_every()
	var gap := boss_level - elite_level
	var ok := elite_level == boss_level - 1 and gap == 1
	_record_test("m010_before_b001", ok, {
		"elite_level": elite_level,
		"boss_level": boss_level,
		"gap": gap
	})

func _run_loot_semantics() -> void:
	var tough_level := -1
	var elite_level := _elite_level()
	for level in range(1, _boss_every()):
		if P0MonsterVisualSystem.monster_classification(level) == "tough" and tough_level < 0:
			tough_level = level
	var tough_source := EncounterStatService.loot_source_id(tough_level) if tough_level > 0 else ""
	var elite_source := EncounterStatService.loot_source_id(elite_level) if elite_level > 0 else ""
	var boss_source := EncounterStatService.loot_source_id(_boss_every())
	var normal_source := EncounterStatService.loot_source_id(1)
	var ok := tough_source == "greenvale_tough"
	ok = ok and elite_source == "greenvale_elite"
	ok = ok and boss_source == "greenvale_boss"
	ok = ok and normal_source == "greenvale_normal"
	ok = ok and tough_source != elite_source
	ok = ok and LootTableService.sources.has("greenvale_tough")
	_record_test("loot_semantics_normal_tough_elite_boss", ok, {
		"normal_source": normal_source,
		"tough_source": tough_source,
		"elite_source": elite_source,
		"boss_source": boss_source
	})

func _run_loot_simulation() -> void:
	var runs := 10000
	var elite_level := _elite_level()
	var rng := RandomNumberGenerator.new()
	var no_item := 0
	var has_item := 0
	var three_plus := 0
	for run_idx in range(runs):
		rng.seed = run_idx + 91
		var items := 0
		for level in range(1, elite_level):
			var chance := EncounterStatService.loot_roll_chance(level)
			if chance <= 0.0:
				continue
			if rng.randf() <= chance:
				items += 1
		if items == 0:
			no_item += 1
		else:
			has_item += 1
		if items >= 3:
			three_plus += 1
	var pct_no := float(no_item) / float(runs)
	var pct_has := float(has_item) / float(runs)
	var pct_three := float(three_plus) / float(runs)
	var ok := pct_no <= 0.25 and pct_has >= 0.75 and pct_three <= 0.25
	_report["state_evidence"]["loot_simulation"] = {
		"runs": runs,
		"pct_no_item_before_elite": pct_no,
		"pct_has_item_before_elite": pct_has,
		"pct_three_plus_before_elite": pct_three
	}
	_record_test("loot_simulation_10k", ok, _report["state_evidence"]["loot_simulation"])

func _run_classification_runtime_values() -> void:
	var elite_level := _elite_level()
	var boss_level := _boss_every()
	var samples := [
		{"level": 1, "id": "M001", "cls": "normal"},
		{"level": 2, "id": "M012", "cls": "normal"},
		{"level": 4, "id": "M003", "cls": "tough"},
		{"level": 7, "id": "M006", "cls": "normal"},
		{"level": elite_level, "id": "M010", "cls": "elite"},
		{"level": boss_level, "id": "B001", "cls": "boss"}
	]
	var hp_values := {}
	var ok := true
	for sample in samples:
		var level := int(sample.level)
		var hp := EncounterStatService.effective_hp(level)
		hp_values[str(sample.id)] = hp
		ok = ok and P0MonsterVisualSystem.monster_classification(level) == str(sample.cls)
		ok = ok and hp > 0
	ok = ok and EncounterStatService.effective_hp(2) < EncounterStatService.effective_hp(4)
	ok = ok and EncounterStatService.effective_hp(4) < EncounterStatService.effective_hp(elite_level)
	ok = ok and EncounterStatService.effective_hp(elite_level) < EncounterStatService.effective_hp(boss_level)
	_report["state_evidence"]["classification_hp"] = hp_values
	_record_test("classification_changes_runtime_values", ok, hp_values)

func _run_hero_pacing_simulation() -> void:
	var pl := 1
	var pxp := 0
	var unlock_level := -1
	var trace: Array = []
	for level in range(1, _boss_every()):
		var xp := EncounterStatService.xp_reward(level)
		pxp += xp
		while pxp >= GameConfig.player_xp_required(pl):
			pxp -= GameConfig.player_xp_required(pl)
			pl += 1
			if pl >= GameConfig.HERO_UNLOCK_ACCOUNT_LEVEL and unlock_level < 0:
				unlock_level = level
		trace.append({
			"encounter_level": level,
			"monster_id": P0MonsterVisualSystem.production_asset_id(level),
			"xp_gain": xp,
			"player_level": pl,
			"player_xp": pxp
		})
	var ok := unlock_level == 6
	_report["state_evidence"]["hero_pacing"] = {
		"hero_unlock_encounter_level": unlock_level,
		"trace": trace
	}
	_record_test("hero_unlock_kill_6_m005", ok, _report["state_evidence"]["hero_pacing"])

func _run_legacy_deprecation() -> void:
	var legacy_file := FileAccess.open("res://data/monsters.json", FileAccess.READ)
	var ok := legacy_file != null
	var parsed: Dictionary = {}
	if ok:
		parsed = JSON.parse_string(legacy_file.get_as_text())
		ok = str(parsed.get("runtime_status", "")) == "DEPRECATED_NON_RUNTIME"
	_record_test("legacy_catalog_deprecated", ok, {
		"monsters_json_status": parsed.get("runtime_status", "")
	})

func _run_save_reload() -> void:
	RegionProgressionSystem.reset_runtime()
	RegionProgressionSystem.current_region_id = "greenvale"
	RegionProgressionSystem.record_encounter_cleared("greenvale", 8, false)
	var before := RegionProgressionSystem.export_save_data()
	RegionProgressionSystem.reset_runtime()
	RegionProgressionSystem.import_save_data(before)
	var ok := int(RegionProgressionSystem.progress_entry("greenvale").get("encounters_cleared", 0)) == 1
	ok = ok and SaveGame.SAVE_VERSION >= 41
	_record_test("region_save_reload", ok, {"encounters_cleared": RegionProgressionSystem.progress_entry("greenvale").get("encounters_cleared", 0)})

func _finalize() -> void:
	var passed := 0
	for test in _report["tests"]:
		if bool(test.get("ok", false)):
			passed += 1
	_report["tests_passed"] = passed
	_report["tests_total"] = _report["tests"].size()
	_report["status"] = "PASS" if _report["issues"].is_empty() else "FAIL"
	_write_report()

func _write_report() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT_PATH.get_base_dir()))
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))
