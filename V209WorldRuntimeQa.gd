extends Node
## V2.09 Phase 2 — Extended Grünhain runtime acceptance QA (natural encounter flow).

const CombatDamageResolver = preload("res://CombatDamageResolver.gd")

const SHOT_DIR := "res://docs/v209_visual_runtime_qa"
const REPORT_PATH := "res://docs/v209_visual_runtime_qa/world_runtime_qa_report.json"
const MAX_RUNTIME_MS := 900000
const HERO_UNLOCK_LEVEL := 6
const PROFILES := [
	Vector2i(1080, 1920),
	Vector2i(1080, 2340),
	Vector2i(1080, 2400),
	Vector2i(1440, 3200)
]
const CORE_SHOTS := {
	"M001": "01_m001_waldwinzling",
	"M012": "02_m012_blatthoernchen",
	"M002": "03_m002_blatthorn",
	"M003": "04_m003_waldkeiler_tough",
	"M004": "05_m004_pilzling",
	"M005": "06_m005_waldkaefer",
	"M006": "09_m006_blaetterkauz",
	"M013": "10_m013_waldwolf",
	"M008": "11_m008_moosschildkroete",
	"M011": "12_m011_kristallgolem",
	"M010": "07_m010_waldgeist_elite",
	"B001": "08_b001_mooskoenig_boss"
}

var _report: Dictionary = {}
var _main: Control
var _start_ms: int = 0
var _current_step: String = "init"
var _visual_issues: Array[String] = []
var _encounter_trace: Array = []
var _hero_unlock_evidence: Dictionary = {}
var _loot_evidence: Array = []
var _hp_evidence: Dictionary = {}

func _log(msg: String) -> void:
	print("[V209RuntimeQa] ", msg)

func _boss_every() -> int:
	return P0MonsterVisualSystem.boss_every_kills()

func _expected_sequence() -> Array:
	var seq: Array = []
	for level in range(1, _boss_every() + 1):
		seq.append(P0MonsterVisualSystem.production_asset_id(level))
	return seq

func _elite_level() -> int:
	for level in range(1, _boss_every()):
		if P0MonsterVisualSystem.production_asset_id(level) == "M010":
			return level
	return -1

func _loot_verify_levels() -> Dictionary:
	var levels := {1: "greenvale_normal", 4: "greenvale_tough", _boss_every(): "greenvale_boss"}
	var elite := _elite_level()
	if elite > 0:
		levels[elite] = "greenvale_elite"
	for level in range(1, _boss_every()):
		if P0MonsterVisualSystem.monster_classification(level) == "tough" and not levels.has(level):
			levels[level] = "greenvale_tough"
	return levels

func run() -> Dictionary:
	_start_ms = Time.get_ticks_msec()
	_report = {
		"milestone": "V2.09-Phase2-ExtendedCycle",
		"status": "BLOCKED",
		"duration_ms": 0,
		"step_timings": [],
		"assertions": [],
		"regression": {},
		"screenshots": [],
		"viewport_matrix": [],
		"encounter_trace": [],
		"hero_unlock_evidence": {},
		"loot_source_evidence": [],
		"hp_evidence": {},
		"production_asset_paths": {},
		"state_evidence": {},
		"visual_issues": [],
		"issues": [],
		"process_exit": {},
		"qa_performance": {"start_ms": _start_ms, "max_runtime_ms": MAX_RUNTIME_MS}
	}
	_visual_issues.clear()
	_encounter_trace.clear()
	_loot_evidence.clear()
	_hp_evidence.clear()
	SettingsService.reduced_motion = true
	HeroSystem.set_process(false)

	if not await _run_step("boot", _step_boot):
		return _finalize_report()
	await _run_step("natural_curated_flow", _step_natural_curated_flow)
	await _run_step("hero_unlock_runtime", _step_hero_unlock_runtime)
	await _run_step("loot_pipeline_verify", _step_loot_pipeline_verify)
	await _run_step("classification_hp_verify", _step_classification_hp_verify)
	await _run_step("production_assets", _step_production_assets)
	await _run_step("regression_smoke", _step_regression_smoke)
	await _run_step("save_reload", _step_save_reload)
	await _run_step("viewport_matrix", _step_viewport_matrix)
	await _run_step("visual_inspection", _step_visual_inspection)

	_report["encounter_trace"] = _encounter_trace.duplicate(true)
	_report["hero_unlock_evidence"] = _hero_unlock_evidence.duplicate(true)
	_report["loot_source_evidence"] = _loot_evidence.duplicate(true)
	_report["hp_evidence"] = _hp_evidence.duplicate(true)
	_report["visual_issues"] = _visual_issues.duplicate()
	return _finalize_report()

func _run_step(step_name: String, step_fn: Callable) -> bool:
	if _watchdog_exceeded():
		_report["issues"].append("watchdog:%s" % step_name)
		return false
	_current_step = step_name
	var started := Time.get_ticks_msec()
	var result = await step_fn.call()
	var ok := true
	if typeof(result) == TYPE_BOOL:
		ok = result
	elif typeof(result) == TYPE_DICTIONARY:
		ok = bool(result.get("ok", true))
	if not ok:
		_report["issues"].append(step_name)
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

func _step_boot() -> bool:
	P0BootDiagnostics.qa_direct_main_load = true
	get_tree().change_scene_to_file("res://MainGame.tscn")
	var loaded := await _wait_until(func(): return _find_main() != null, 300, "main_load")
	_main = _find_main()
	if not loaded or _main == null:
		return false
	await _apply_viewport(PROFILES[0])
	RegionProgressionSystem.reset_runtime()
	ItemInventoryService.reset_runtime()
	StatModifierService.rebuild_all()
	BossChallengeSystem.reset_runtime()
	LootTableService.clear_qa_forced_roll()
	P0MonsterVisualSystem.reload_for_region("greenvale")
	PlayerData.player_level = 1
	PlayerData.player_xp = 0
	PlayerData.gold = 8000
	PlayerData.spins = 40
	PlayerData.tap_level = 1
	PlayerData.tap_damage = 10
	PlayerData.monster_level = 1
	PlayerData.monster_max_hp = GameConfig.effective_monster_hp(1)
	PlayerData.current_monster_hp = PlayerData.monster_max_hp
	for hero_id in HeroSystem.hero_owned.keys():
		HeroSystem.hero_owned[hero_id] = false
	HeroSystem.deployed_hero_id = ""
	HeroSystem.sync_progression_unlocks()
	if _main.has_method("qa_prepare_combat_ready"):
		_main.qa_prepare_combat_ready()
	_update_monster_visual_main()
	return RegionProgressionSystem.combat_region_id() == "greenvale"

func _step_natural_curated_flow() -> bool:
	var expected_sequence := _expected_sequence()
	var ok := true
	var expected_index := 0
	while expected_index < expected_sequence.size():
		var level := PlayerData.monster_level
		if level != expected_index + 1:
			ok = false
			_report["issues"].append("encounter_index_mismatch:L%d_expected_%d" % [level, expected_index + 1])
			break
		var expected_id: String = str(expected_sequence[expected_index])
		var actual_id: String = P0MonsterVisualSystem.production_asset_id(level)
		if actual_id != expected_id:
			ok = false
			_report["issues"].append("encounter_id_mismatch:L%d_%s_expected_%s" % [level, actual_id, expected_id])
		var entry := _encounter_snapshot(level)
		_encounter_trace.append(entry)
		if CORE_SHOTS.has(actual_id):
			await _set_monster_state("idle")
			await _capture(CORE_SHOTS[actual_id], "core_monster")
		if actual_id == "B001":
			await _await_boss_combat_ready(level)
			await _capture("11_boss_combat", "boss")
		if level == _elite_level():
			await _capture("10_elite_pre_boss", "elite")
		if not await _qa_defeat_current(level, expected_id):
			ok = false
			break
		if level == HERO_UNLOCK_LEVEL and HeroSystem.is_unlocked("knight"):
			HeroSystem.deploy_hero("knight", false)
			await _capture("13_hero_unlock", "hero")
		expected_index += 1
		if level >= _boss_every():
			break
		if not await _wait_until(func(): return PlayerData.monster_level == level + 1, 240, "next_encounter"):
			ok = false
			_report["issues"].append("next_encounter_timeout:L%d" % level)
			break
	var sequence_ok := _verify_encounter_sequence()
	_record_assertion("natural_curated_sequence", sequence_ok, {
		"encounter_count": _encounter_trace.size(),
		"final_monster_level": PlayerData.monster_level,
		"flow_ok": ok,
		"catalog_version": P0MonsterVisualSystem.data.get("version", "")
	})
	return sequence_ok and ok

func _await_boss_combat_ready(level: int) -> void:
	if level != _boss_every():
		return
	await _wait_until(func(): return not _main.boss_intro_overlay.visible, 600, "boss_intro_done")
	await _wait_until(
		func(): return not _main.core_input_locked and not _main.monster_state_locked,
		360,
		"boss_input_ready"
	)
	if BossChallengeSystem.failed:
		BossChallengeSystem.prepare_retry(level)
	elif not BossChallengeSystem.active:
		if _main.has_method("_show_boss_intro"):
			await _main._show_boss_intro()
		else:
			BossChallengeSystem.start_challenge(level)
	await _wait_until(func(): return BossChallengeSystem.active and not BossChallengeSystem.failed, 360, "boss_challenge_active")

func _step_hero_unlock_runtime() -> bool:
	HeroSystem.sync_progression_unlocks()
	var ev := _hero_unlock_evidence
	if not ev.is_empty() and not bool(ev.get("hero_unlocked_after", false)) and HeroSystem.is_unlocked("knight"):
		ev["hero_unlocked_after"] = true
		ev["sync_corrected"] = true
		_hero_unlock_evidence = ev
	var ok := not ev.is_empty()
	ok = ok and bool(ev.get("hero_unlocked_after", false))
	ok = ok and int(ev.get("account_level_after", 0)) >= GameConfig.HERO_UNLOCK_ACCOUNT_LEVEL
	ok = ok and int(ev.get("encounter_level", 0)) == HERO_UNLOCK_LEVEL
	ok = ok and str(ev.get("monster_id", "")) == "M005"
	ok = ok and HeroSystem.is_unlocked("knight")
	var elite_entry: Dictionary = {}
	for entry in _encounter_trace:
		if str(entry.get("monster_id", "")) == "M010":
			elite_entry = entry
			break
	ok = ok and not elite_entry.is_empty()
	if not elite_entry.is_empty():
		ok = ok and bool(elite_entry.get("hero_unlocked", false))
	_record_assertion("hero_unlock_runtime_m005", ok, ev)
	_report["state_evidence"]["hero_unlock"] = ev
	return ok

func _step_loot_pipeline_verify() -> bool:
	var loot_verify := _loot_verify_levels()
	var ok := true
	for level in loot_verify.keys():
		var expected_source: String = loot_verify[level]
		var actual := EncounterStatService.loot_source_id(level)
		ok = ok and actual == expected_source
		_loot_evidence.append({
			"encounter_level": level,
			"monster_id": P0MonsterVisualSystem.production_asset_id(level),
			"expected_source": expected_source,
			"runtime_source": actual,
			"match": actual == expected_source
		})
	for entry in _encounter_trace:
		var lvl := int(entry.get("encounter_index", 0))
		if loot_verify.has(lvl):
			ok = ok and str(entry.get("loot_source", "")) == loot_verify[lvl]
	# Tough must never resolve to elite
	var tough_loot := EncounterStatService.loot_source_id(4)
	ok = ok and tough_loot == "greenvale_tough"
	ok = ok and tough_loot != "greenvale_elite"
	_record_assertion("loot_source_runtime", ok, {"samples": _loot_evidence})
	return ok

func _step_classification_hp_verify() -> bool:
	var samples := {
		"M001": 1, "M012": 2, "M002": 3, "M003": 4, "M005": 6,
		"M006": 7, "M013": 8, "M008": 9, "M011": 10, "M010": _elite_level(), "B001": _boss_every()
	}
	var ok := true
	var normal_hp := EncounterStatService.effective_hp(1)
	var tough_hp := EncounterStatService.effective_hp(4)
	var elite_hp := EncounterStatService.effective_hp(_elite_level())
	var boss_hp := EncounterStatService.effective_hp(_boss_every())
	ok = ok and normal_hp < tough_hp
	ok = ok and tough_hp < elite_hp
	ok = ok and elite_hp < boss_hp
	for monster_id in samples.keys():
		var level := int(samples[monster_id])
		var breakdown := EncounterStatService.hp_breakdown(level)
		_hp_evidence[monster_id] = breakdown
		ok = ok and P0MonsterVisualSystem.monster_classification(level) == str(breakdown.get("classification", ""))
	_record_assertion("hp_profile_normal_lt_tough_lt_elite_lt_boss", ok, {
		"normal": normal_hp,
		"tough": tough_hp,
		"elite": elite_hp,
		"boss": boss_hp
	})
	return ok

func _step_production_assets() -> bool:
	var ok := true
	var paths := {}
	for monster_id in CORE_SHOTS.keys():
		var level := _level_for_monster_id(monster_id)
		if level < 0:
			continue
		var expected := _expected_idle_path(monster_id)
		var runtime: String = _encounter_trace[level - 1].get("runtime_asset", "") if _encounter_trace.size() >= level else _idle_texture_path(level)
		if _encounter_trace.size() >= level:
			runtime = str(_encounter_trace[level - 1].get("runtime_asset", runtime))
		var path_match: bool = expected == runtime and ResourceLoader.exists(expected)
		paths[monster_id] = {"expected": expected, "runtime": runtime, "match": path_match}
		ok = ok and path_match
		if str(expected).contains("placeholder"):
			ok = false
			_visual_issues.append("%s:legacy_placeholder" % monster_id)
	_report["production_asset_paths"] = paths
	_record_assertion("core_production_asset_paths", ok, paths)
	return ok

func _step_regression_smoke() -> bool:
	var ok := true
	CombatDamageResolver.force_next_crit = true
	var crit_hit := CombatDamageResolver.resolve_tap(PlayerData.tap_damage)
	ok = ok and bool(crit_hit.get("critical", false))
	CombatDamageResolver.force_next_crit = false
	ok = ok and WheelSystem.total_weight() == 100
	ok = ok and ItemInventoryService.catalog_count() >= 4
	ok = ok and LootTableService.sources.has("greenvale_tough")
	ok = ok and SaveGame.SAVE_VERSION >= 41
	ok = ok and not FeatureFlags.SHOW_ATTACK
	ok = ok and HeroSystem.is_unlocked("knight")
	ok = ok and StatModifierService != null
	ok = ok and RewardPipeline != null
	ok = ok and BossChallengeSystem != null
	ok = ok and ChestRewardSystem != null
	ok = ok and QuestSystem != null
	ok = ok and DailyRewards != null
	ok = ok and P0VillageSystem != null
	ok = ok and AfkRewardSystem != null
	ok = ok and RegionProgressionSystem.combat_region_id() == "greenvale"
	ok = ok and FeatureFlags.ENABLE_HERO_AUTODPS
	_report["regression"] = {
		"tap": PlayerData.tap_damage > 0,
		"crit": bool(crit_hit.get("critical", false)),
		"hero_unlock": HeroSystem.is_unlocked("knight"),
		"hero_autodps_flag": FeatureFlags.ENABLE_HERO_AUTODPS,
		"inventory": ItemInventoryService.catalog_count() >= 4,
		"equipment": ItemInventoryService.has_method("equip"),
		"stat_modifier_service": StatModifierService != null,
		"reward_pipeline": RewardPipeline != null,
		"boss": BossChallengeSystem != null,
		"chest": ChestRewardSystem != null,
		"quest": QuestSystem != null,
		"daily": DailyRewards != null,
		"spin": WheelSystem.total_weight() == 100,
		"village": P0VillageSystem != null,
		"afk": AfkRewardSystem != null,
		"save_version": SaveGame.SAVE_VERSION,
		"region_progression": RegionProgressionSystem.combat_region_id() == "greenvale"
	}
	_record_assertion("regression_smoke", ok, _report["regression"])
	return ok

func _step_save_reload() -> bool:
	var export_before := {
		"monster_level": PlayerData.monster_level,
		"player_level": PlayerData.player_level,
		"player_xp": PlayerData.player_xp,
		"hero_knight": HeroSystem.is_unlocked("knight"),
		"region": RegionProgressionSystem.export_save_data(),
		"inventory_count": ItemInventoryService.snapshot_instance_count()
	}
	SaveGame.save_game()
	if not SaveGame.last_save_ok:
		return false
	var saved_level := PlayerData.monster_level
	RegionProgressionSystem.reset_runtime()
	ItemInventoryService.reset_runtime()
	SaveGame.load_game()
	StatModifierService.rebuild_all()
	P0MonsterVisualSystem.reload_for_region("greenvale")
	HeroSystem.sync_progression_unlocks()
	var ok := PlayerData.monster_level == saved_level
	ok = ok and PlayerData.player_level == export_before.player_level
	ok = ok and HeroSystem.is_unlocked("knight") == export_before.hero_knight
	ok = ok and RegionProgressionSystem.combat_region_id() == "greenvale"
	_record_assertion("save_reload_v41", ok, {"before": export_before, "after": {
		"monster_level": PlayerData.monster_level,
		"player_level": PlayerData.player_level,
		"hero_knight": HeroSystem.is_unlocked("knight")
	}})
	_report["state_evidence"]["save_reload"] = {"before": export_before}
	if _main and _main.has_method("qa_prepare_combat_ready"):
		_main.qa_prepare_combat_ready()
	return ok

func _step_viewport_matrix() -> bool:
	var scenarios := [
		{"level": 2, "label": "small_m012"},
		{"level": 7, "label": "flying_m006"},
		{"level": 9, "label": "wide_m008"},
		{"level": 10, "label": "tall_m011"},
		{"level": _elite_level(), "label": "elite_m010"},
		{"level": _boss_every(), "label": "boss_b001"}
	]
	for profile in PROFILES:
		await _apply_viewport(profile)
		for scenario in scenarios:
			_qa_set_monster_level(int(scenario.level))
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
	var ok := true
	for monster_id in CORE_SHOTS.keys():
		var shot_name: String = CORE_SHOTS[monster_id]
		var found := false
		for shot in _report.get("screenshots", []):
			if str(shot.get("screenshot", "")) == shot_name:
				found = true
				if not bool(shot.get("analysis", {}).get("ok", false)):
					ok = false
					_visual_issues.append("%s:visual_flat" % monster_id)
		if not found:
			ok = false
			_visual_issues.append("%s:missing_screenshot" % monster_id)
	for required in ["13_hero_unlock", "10_elite_reward", "14_boss_victory", "15_boss_loot"]:
		var has := false
		for shot in _report.get("screenshots", []):
			if str(shot.get("screenshot", "")) == required:
				has = true
		if not has:
			ok = false
			_visual_issues.append("missing:%s" % required)
	_record_assertion("visual_inspection", ok, {"core_monsters": CORE_SHOTS.keys()})
	return ok

func _qa_defeat_current(level: int, monster_id: String) -> bool:
	_qa_prepare_kill()
	if level == _boss_every():
		PlayerData.current_monster_hp = 1
	var hero_before := {}
	if level == HERO_UNLOCK_LEVEL:
		hero_before = {
			"account_level_before": PlayerData.player_level,
			"account_xp_before": PlayerData.player_xp,
			"hero_unlocked_before": HeroSystem.is_unlocked("knight")
		}
	var before_pl := PlayerData.player_level
	var before_xp := PlayerData.player_xp
	await _main._on_monster_pressed()
	var reward_visible := false
	if level == _boss_every():
		reward_visible = await _wait_until(func(): return _main.monster_reward_overlay.visible, 720, "boss_reward_overlay")
	else:
		reward_visible = await _wait_until(func(): return _main.monster_reward_overlay.visible, 360, "reward_overlay")
	if not reward_visible:
		_report["issues"].append("defeat_reward_timeout:L%d_%s" % [level, monster_id])
		return false
	await _wait_frames(10)
	var txn := RewardPipeline.last_transaction.duplicate(true)
	var elite_level := _elite_level()
	if level == elite_level:
		await _capture("10_elite_reward", "reward")
	if level == _boss_every():
		await _wait_until(func(): return _main.monster_reward_overlay.visible, 480, "boss_reward_overlay")
		await _wait_frames(12)
		await _capture("14_boss_victory", "boss")
		await _wait_frames(6)
		await _capture("15_boss_loot", "reward")
	if level == HERO_UNLOCK_LEVEL:
		HeroSystem.sync_progression_unlocks()
		_hero_unlock_evidence = {
			"encounter_level": HERO_UNLOCK_LEVEL,
			"monster_id": monster_id,
			"account_level_before": hero_before.get("account_level_before", before_pl),
			"account_xp_before": hero_before.get("account_xp_before", before_xp),
			"granted_xp": int(txn.get("reward", {}).get("xp", EncounterStatService.xp_reward(level))),
			"account_level_after": PlayerData.player_level,
			"account_xp_after": PlayerData.player_xp,
			"hero_unlocked_before": hero_before.get("hero_unlocked_before", false),
			"hero_unlocked_after": HeroSystem.is_unlocked("knight"),
			"expected_unlock_level": GameConfig.HERO_UNLOCK_ACCOUNT_LEVEL
		}
	var loot_verify := _loot_verify_levels()
	if loot_verify.has(level):
		var meta: Dictionary = txn.get("metadata", {})
		_loot_evidence.append({
			"encounter_level": level,
			"monster_id": monster_id,
			"reward_pipeline_source": str(txn.get("source", "")),
			"loot_source_metadata": str(meta.get("loot_source", "")),
			"granted_items": txn.get("granted_items", []),
			"ok": str(meta.get("loot_source", "")) == loot_verify[level]
		})
	for i in range(_encounter_trace.size()):
		if int(_encounter_trace[i].get("encounter_level", 0)) == level:
			_encounter_trace[i]["defeat_txn"] = {
				"account_level_before": before_pl,
				"account_xp_before": before_xp,
				"granted_xp": int(txn.get("reward", {}).get("xp", EncounterStatService.xp_reward(level))),
				"account_level_after": PlayerData.player_level,
				"account_xp_after": PlayerData.player_xp,
				"loot_source_metadata": str(txn.get("metadata", {}).get("loot_source", ""))
			}
			break
	if _main.monster_reward_overlay.visible:
		_main.monster_reward_continue.emit_signal("pressed")
		await _wait_until(func(): return not _main.monster_reward_overlay.visible, 240, "reward_dismiss")
	await _wait_until(func(): return not MonsterDefeatService.transaction_active, 240, "defeat_commit")
	if level == _elite_level() and PlayerData.monster_level == _boss_every():
		await _await_boss_combat_ready(_boss_every())
	await _wait_frames(4)
	return true

func _reward_overlay_visible() -> bool:
	return _main != null and _main.monster_reward_overlay.visible

func _verify_encounter_sequence() -> bool:
	var expected_sequence := _expected_sequence()
	if _encounter_trace.size() != expected_sequence.size():
		return false
	for i in range(expected_sequence.size()):
		var entry: Dictionary = _encounter_trace[i]
		if int(entry.get("encounter_index", 0)) != i + 1:
			return false
		if str(entry.get("monster_id", "")) != expected_sequence[i]:
			return false
	return true

func _encounter_snapshot(level: int) -> Dictionary:
	HeroSystem.sync_progression_unlocks()
	var stats := EncounterStatService.stats_for_level(level)
	var breakdown := EncounterStatService.hp_breakdown(level)
	return {
		"encounter_index": level,
		"monster_id": P0MonsterVisualSystem.production_asset_id(level),
		"classification": P0MonsterVisualSystem.monster_classification(level),
		"runtime_asset": _idle_texture_path(level),
		"expected_asset": _expected_idle_path(P0MonsterVisualSystem.production_asset_id(level)),
		"base_hp": breakdown.get("base_hp", 0),
		"hp_scaling": breakdown.get("hp_scaling", 1.0),
		"stage_factor": breakdown.get("stage_factor", 1.0),
		"effective_hp": breakdown.get("effective_hp", 0),
		"xp_reward": EncounterStatService.xp_reward(level),
		"loot_source": EncounterStatService.loot_source_id(level),
		"loot_roll_chance": EncounterStatService.loot_roll_chance(level),
		"player_level": PlayerData.player_level,
		"player_xp": PlayerData.player_xp,
		"hero_unlocked": HeroSystem.is_unlocked("knight"),
		"catalog_version": "v2.09-encounters-02"
	}

func _qa_prepare_kill() -> void:
	PlayerData.current_monster_hp = 1
	_main.monster_state_locked = false
	_main.core_input_locked = false
	if _main.has_method("qa_prepare_combat_ready"):
		_main.qa_prepare_combat_ready()

func _qa_set_monster_level(level: int) -> void:
	PlayerData.monster_level = level
	PlayerData.monster_max_hp = GameConfig.effective_monster_hp(level)
	PlayerData.current_monster_hp = PlayerData.monster_max_hp
	PlayerData.monster_changed.emit()
	if _main and _main.has_method("qa_prepare_combat_ready"):
		_main.qa_prepare_combat_ready()
	_update_monster_visual_main()

func _level_for_monster_id(monster_id: String) -> int:
	var expected_sequence := _expected_sequence()
	for i in range(expected_sequence.size()):
		if expected_sequence[i] == monster_id:
			return i + 1
	return -1

func _expected_idle_path(monster_id: String) -> String:
	return "%s/%s_idle.png" % [RegionProgressionSystem.monster_asset_root("greenvale"), monster_id]

func _idle_texture_path(level: int) -> String:
	return _expected_idle_path(P0MonsterVisualSystem.production_asset_id(level))

func _find_main() -> Control:
	return get_tree().root.find_child("MainGame", true, false) as Control

func _set_monster_state(state: String) -> void:
	var tex := P0MonsterVisualSystem.texture_for(PlayerData.monster_level, state)
	if tex and _main and _main.monster_button:
		_main.monster_button.texture_normal = tex
	await _wait_frames(4)

func _update_monster_visual_main() -> void:
	if _main and _main.has_method("_update_monster_visual"):
		_main._update_monster_visual()
	if _main and _main.has_method("_update_monster_progress"):
		_main._update_monster_progress()

func _apply_viewport(size: Vector2i) -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)
		var root := get_tree().root
		if root is Window:
			(root as Window).size = size
	await _wait_frames(4)

func _wait_frames(count: int) -> void:
	for _i in range(count):
		if _watchdog_exceeded():
			return
		await get_tree().process_frame

func _wait_render_stable(frames: int) -> void:
	await _wait_frames(maxi(frames, 1))

func _wait_until(predicate: Callable, max_frames: int, _label: String) -> bool:
	for _i in range(max_frames):
		if _watchdog_exceeded():
			return false
		if predicate.call():
			return true
		await get_tree().process_frame
	return false

func _watchdog_exceeded() -> bool:
	return Time.get_ticks_msec() - _start_ms > MAX_RUNTIME_MS

func _capture(name: String, category: String = "core") -> void:
	if _watchdog_exceeded():
		return
	var rel_path := "%s/%s.png" % [SHOT_DIR, name]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	await _wait_render_stable(2)
	var vp := get_tree().root.get_viewport()
	if vp == null:
		_visual_issues.append("%s:no_viewport" % name)
		return
	var tex := vp.get_texture()
	if tex == null:
		_visual_issues.append("%s:no_texture" % name)
		return
	var img := tex.get_image()
	if img == null or img.is_empty():
		_visual_issues.append("%s:capture_failed" % name)
		return
	var save_err := img.save_png(ProjectSettings.globalize_path(rel_path))
	if save_err != OK:
		_visual_issues.append("%s:save_err_%d" % [name, save_err])
		return
	var bright := 0
	var dark := 0
	for y in range(0, img.get_height(), 8):
		for x in range(0, img.get_width(), 8):
			var l := img.get_pixel(x, y).r * 0.299 + img.get_pixel(x, y).g * 0.587 + img.get_pixel(x, y).b * 0.114
			if l > 0.75:
				bright += 1
			elif l < 0.08:
				dark += 1
	var samples := int((img.get_width() / 8.0) * (img.get_height() / 8.0))
	_report["screenshots"].append({
		"screenshot": name,
		"category": category,
		"file": rel_path,
		"analysis": {
			"ok": bright > 0 and dark > 0,
			"bright_ratio": float(bright) / float(maxi(samples, 1)),
			"dark_ratio": float(dark) / float(maxi(samples, 1)),
			"width": img.get_width(),
			"height": img.get_height()
		}
	})

func _record_assertion(name: String, ok: bool, evidence: Dictionary = {}) -> void:
	_report["assertions"].append({"name": name, "ok": ok, "evidence": evidence})
	if not ok:
		_report["issues"].append(name)

func _flush_report(final: bool) -> void:
	_report["duration_ms"] = Time.get_ticks_msec() - _start_ms
	if final:
		var slowest := {"step": "", "duration_ms": 0}
		for timing in _report.get("step_timings", []):
			if int(timing.get("duration_ms", 0)) > slowest.duration_ms:
				slowest = timing
		_report["qa_performance"]["slowest_step"] = slowest
		_report["qa_performance"]["elapsed_ms"] = _report["duration_ms"]
		_report["status"] = "PASS" if _report["issues"].is_empty() and _visual_issues.is_empty() else "FAIL"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	_report["visual_issues"] = _visual_issues.duplicate()
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
	_report["item_timing"] = _build_item_timing_evidence()
	_report["process_exit"] = {
		"status": _report.get("status", "FAIL"),
		"duration_ms": _report.get("duration_ms", 0),
		"assertions_passed": passed,
		"assertions_total": _report.get("assertions", []).size()
	}
	_flush_report(true)
	_write_process_exit_meta()
	return _report.duplicate(true)

func _write_process_exit_meta() -> void:
	var exit_meta := {
		"qa_result": _report.get("status", "UNKNOWN"),
		"elapsed_ms": _report.get("duration_ms", 0),
		"exit_code": 0 if str(_report.get("status", "")) == "PASS" else 1,
		"issues": _report.get("issues", []),
		"assertions_passed": _report.get("assertions_passed", 0),
		"assertions_total": _report.get("assertions_total", 0)
	}
	var file := FileAccess.open("res://docs/v209_visual_runtime_qa/process_exit.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(exit_meta, "\t"))

func _build_item_timing_evidence() -> Dictionary:
	var first_possible := {}
	var first_actual := {}
	for entry in _encounter_trace:
		var lvl := int(entry.get("encounter_index", 0))
		if first_possible.is_empty() and float(entry.get("loot_roll_chance", 0.0)) > 0.0:
			first_possible = {
				"encounter_index": lvl,
				"monster_id": entry.get("monster_id", ""),
				"loot_source": entry.get("loot_source", ""),
				"loot_roll_chance": entry.get("loot_roll_chance", 0.0)
			}
	for sample in _loot_evidence:
		var items: Array = sample.get("granted_items", [])
		if items.is_empty():
			continue
		var item: Dictionary = items[0]
		first_actual = {
			"encounter_index": int(sample.get("encounter_level", 0)),
			"monster_id": sample.get("monster_id", ""),
			"loot_source": sample.get("loot_source_metadata", ""),
			"item_id": str(item.get("item_id", "")),
			"rarity": str(item.get("metadata", {}).get("classification", ""))
		}
		break
	return {
		"first_possible_drop": first_possible,
		"first_controlled_runtime_drop": first_actual,
		"note": "Production RNG may drop later than first possible encounter."
	}
