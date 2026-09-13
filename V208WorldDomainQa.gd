extends Node
## V2.08 — world/region/encounter domain QA (headless).

const REPORT_PATH := "res://docs/v208_domain_qa/world_domain_qa_report.json"

var _report: Dictionary = {}

func run() -> Dictionary:
	_report = {
		"milestone": "V2.08",
		"status": "BLOCKED",
		"tests": [],
		"state_evidence": {},
		"issues": []
	}
	_run_region_catalog_tests()
	_run_encounter_rotation_tests()
	_run_monster_asset_tests()
	_run_classification_tests()
	_run_loot_region_tests()
	_run_region_progress_tests()
	_run_save_reload_tests()
	_run_v207_migration_smoke()
	_finalize()
	return _report.duplicate(true)

func _record_test(name: String, ok: bool, evidence: Dictionary = {}) -> void:
	_report["tests"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _run_region_catalog_tests() -> void:
	var greenvale := RegionProgressionSystem.region_def("greenvale")
	var ok := not greenvale.is_empty()
	ok = ok and str(greenvale.get("encounter_catalog", "")).ends_with("encounters_greenvale_p0_v1_4.json")
	ok = ok and RegionProgressionSystem.is_playable("greenvale")
	ok = ok and not RegionProgressionSystem.is_playable("frostmark")
	ok = ok and RegionProgressionSystem.combat_region_id() == "greenvale"
	ok = ok and not str(RegionProgressionSystem.background_asset_path()).is_empty()
	_record_test("region_catalog_greenvale", ok, {
		"region_id": "greenvale",
		"encounter_catalog": greenvale.get("encounter_catalog", ""),
		"background": RegionProgressionSystem.background_asset_path()
	})

func _run_encounter_rotation_tests() -> void:
	P0MonsterVisualSystem.reload_for_region("greenvale")
	var ids: Array = []
	for level in range(1, 6):
		ids.append(P0MonsterVisualSystem.production_asset_id(level))
	var unique_count := {}
	for id in ids:
		unique_count[id] = true
	var ok := ids.size() >= 5 and unique_count.size() >= 4
	ok = ok and P0MonsterVisualSystem.production_asset_id(1) == "M001"
	ok = ok and P0MonsterVisualSystem.production_asset_id(2) == "M002"
	var boss_id := P0MonsterVisualSystem.production_asset_id(10)
	ok = ok and boss_id.begins_with("B")
	_report["state_evidence"]["encounter_rotation"] = {
		"levels_1_5": ids,
		"unique_monsters": unique_count.keys(),
		"boss_level_10": boss_id
	}
	_record_test("encounter_rotation_different_ids", ok, _report["state_evidence"]["encounter_rotation"])

func _run_monster_asset_tests() -> void:
	var states := ["idle", "attack", "hit", "defeat"]
	var sample_ids := ["M001", "M002", "M010", "B001"]
	var missing: Array = []
	for mid in sample_ids:
		for state in states:
			var path := "%s/%s_%s.png" % [
				RegionProgressionSystem.monster_asset_root("greenvale"),
				mid,
				state
			]
			if not ResourceLoader.exists(path):
				missing.append(path)
	var ok := missing.is_empty()
	_record_test("monster_production_assets", ok, {"missing": missing, "sample_ids": sample_ids})

func _run_classification_tests() -> void:
	P0MonsterVisualSystem.reload_for_region("greenvale")
	var ok := P0MonsterVisualSystem.monster_classification(1) == "normal"
	ok = ok and P0MonsterVisualSystem.is_elite_or_special(10) == false
	# M010 is elite in enriched catalog — find its level in rotation
	var elite_level := -1
	for level in range(1, 20):
		if P0MonsterVisualSystem.production_asset_id(level) == "M010":
			elite_level = level
			break
	if elite_level > 0:
		ok = ok and P0MonsterVisualSystem.monster_classification(elite_level) == "elite"
	_record_test("monster_classification", ok, {"elite_level_for_M010": elite_level})

func _run_loot_region_tests() -> void:
	var boss_source := RegionProgressionSystem.loot_source_for("boss", "greenvale")
	var elite_source := RegionProgressionSystem.loot_source_for("elite", "greenvale")
	var ok := boss_source == "greenvale_boss"
	ok = ok and elite_source == "greenvale_elite"
	ok = ok and LootTableService.validation_errors.is_empty()
	_record_test("region_loot_sources", ok, {
		"boss_source": boss_source,
		"elite_source": elite_source
	})

func _run_region_progress_tests() -> void:
	RegionProgressionSystem.reset_runtime()
	RegionProgressionSystem.record_encounter_cleared("greenvale", 1, false)
	var entry := RegionProgressionSystem.progress_entry("greenvale")
	var ok := int(entry.get("encounters_cleared", 0)) == 1
	ok = ok and int(entry.get("highest_stage", 0)) == 1
	RegionProgressionSystem.record_encounter_cleared("greenvale", 10, true)
	entry = RegionProgressionSystem.progress_entry("greenvale")
	ok = ok and int(entry.get("bosses_defeated", 0)) == 1
	_record_test("region_progress_tracking", ok, entry)

func _run_save_reload_tests() -> void:
	RegionProgressionSystem.reset_runtime()
	RegionProgressionSystem.current_region_id = "greenvale"
	RegionProgressionSystem.record_encounter_cleared("greenvale", 3, false)
	var before := RegionProgressionSystem.export_save_data()
	RegionProgressionSystem.reset_runtime()
	RegionProgressionSystem.import_save_data(before)
	var ok := RegionProgressionSystem.current_region_id == "greenvale"
	ok = ok and int(RegionProgressionSystem.progress_entry("greenvale").get("encounters_cleared", 0)) == 1
	ok = ok and SaveGame.SAVE_VERSION >= 41
	_record_test("region_save_reload", ok, {"before": before, "after": RegionProgressionSystem.export_save_data()})

func _run_v207_migration_smoke() -> void:
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	var ok := ItemInventoryService.catalog_count() >= 4
	ok = ok and LootTableService.sources.has("greenvale_boss")
	_record_test("v207_foundation_intact", ok, {
		"item_catalog": ItemInventoryService.catalog_count(),
		"loot_sources": LootTableService.sources.keys()
	})

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
	var dir := REPORT_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_report, "\t"))
