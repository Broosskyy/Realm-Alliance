extends Node
## V2.06.1 runtime QA infrastructure — smoke + full visual acceptance (autoload).

const CombatDamageResolver = preload("res://CombatDamageResolver.gd")
const EncounterProgressService = preload("res://EncounterProgressService.gd")

const SHOT_DIR := "res://docs/v2061_visual_runtime_qa"
const REPORT_JSON := "res://docs/v2061_visual_runtime_qa/visual_acceptance_report.json"
const REPORT_MD := "res://docs/v2061_visual_runtime_qa/visual_acceptance_report.md"
const STATE_EVIDENCE_PATH := "res://docs/v2061_visual_runtime_qa/state_evidence.json"

const PROFILES := [
	Vector2i(1080, 2340),
	Vector2i(1080, 2400),
	Vector2i(1080, 1920),
	Vector2i(1440, 3200)
]

const FULL_REQUIRED_SHOTS := [
	"01_main_1080x2340",
	"02_tap_hit_1080x2340",
	"03_defeat_reward_1080x2340",
	"12_boss_ready_1080x2340",
	"14_boss_combat_1080x2340",
	"15_boss_victory_1080x2340",
	"07_spin_result_1080x2340",
	"08_village_1080x2340",
	"17_afk_return_1080x2340",
	"18_afk_claim_1080x2340",
	"19_main_reload_1080x2340",
]

const TAP_RUNS := 3
const BASELINE_FULL_SEC := 56.6

enum QaMode { SMOKE, FULL }

var _report: Dictionary = {}
var _state_evidence: Array = []
var _running: bool = false
var _mode: QaMode = QaMode.FULL
var _started_ms: int = 0

func _log(msg: String) -> void:
	print("[VisualRuntimeQa] ", msg)
	var mode_flag := FileAccess.READ_WRITE if FileAccess.file_exists("user://visual_qa_log.txt") else FileAccess.WRITE
	var f := FileAccess.open("user://visual_qa_log.txt", mode_flag)
	if f:
		if mode_flag == FileAccess.READ_WRITE:
			f.seek_end()
		f.store_line(msg)
		f.close()

func run_acceptance() -> void:
	await run_full()

func run_smoke() -> void:
	await _run_acceptance(QaMode.SMOKE)

func run_full() -> void:
	await _run_acceptance(QaMode.FULL)

func _run_acceptance(mode: QaMode) -> void:
	if _running:
		return
	_running = true
	_mode = mode
	_started_ms = Time.get_ticks_msec()
	_state_evidence.clear()
	_report = {
		"milestone": "V2.06.1",
		"mode": "smoke" if mode == QaMode.SMOKE else "full",
		"status": "BLOCKED",
		"godot": Engine.get_version_info(),
		"runtime_method": "BootFlow.tscn production flow via autoload VisualRuntimeQa + windows display driver",
		"inputs_executed": [],
		"screenshots": [],
		"state_evidence": [],
		"visual_issues": [],
		"fixes_applied": [
			"V2.06.1 HUD resource bars: UI015-017 replaced by v4 resource_bars via ProductionAssetConvergenceV2061",
			"V2.06.1 Hero portrait slots wired to labeled placeholders + mastery badge",
			"V2.06 Heroes enabled: unlock/deploy/auto-attack/level via HeroSystem",
			"V2.06 Unified CombatDamageResolver hero contract",
			"V2.06 Save v39 hero deployment state",
			"V2.05 regression: quest/daily/chest/boss/afk/spin preserved"
		],
		"asset_verification": [],
		"viewport_matrix": {},
		"tap_determinism": {},
		"regression": {},
		"qa_performance": {},
		"exit": {},
		"apk": {}
	}
	_log("start %s acceptance" % _report["mode"])
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	SettingsService.reduced_motion = true

	_log("tap determinism x%d" % TAP_RUNS)
	_report["tap_determinism"] = await _run_tap_determinism()

	if mode == QaMode.SMOKE:
		await _run_smoke_flow()
	else:
		_log("profile full flow 1080x2340")
		await _run_profile(Vector2i(1080, 2340))
		for profile in PROFILES:
			if profile == Vector2i(1080, 2340):
				continue
			_log("profile main_only %s" % profile)
			await _capture_main_only(profile)

	_log("regression")
	_report["regression"] = await _run_regression_suite()
	_finalize_report()
	_running = false

func _run_smoke_flow() -> void:
	_apply_viewport(Vector2i(1080, 2340))
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
	await _boot_to_main_game()
	var main := _main_scene()
	if main == null:
		_report["visual_issues"].append("Smoke: MainGame missing after boot")
		return
	await _prepare_deterministic_tap(main)
	var profile_result := {"status": "PASS", "shots": [], "issues": []}
	await _capture(main, "01_main_1080x2340", profile_result, "Smoke main gameplay", "smoke_main")
	_record_input("tap_monster")
	var hp_before := PlayerData.current_monster_hp
	await main._on_monster_pressed()
	await _wait_hp_below(hp_before, 60)
	await _capture(main, "02_tap_hit_1080x2340", profile_result, "Smoke TAP hit", "smoke_tap_hit")
	if FeatureFlags.SHOW_HEROES:
		P0TestHarness.apply_profile(P0TestHarness.PROFILE_HERO_UNLOCK)
		if main.has_method("_refresh_all"):
			main.call("_refresh_all")
		await _press_button(main, "MoreFeaturesButtonP0")
		await _wait_overlay_visible("FeatureHubOverlayP0", 45)
		await _press_button(main, "HubHeroesP0")
		await _wait_view_visible("View_Heroes", 45)
		await _press_button(main, "HeroKnight")
		await _press_button(main, "HeroKnight")
		await _press_nav(main, "Btn_Tap")
		await _wait_view_visible("View_TapHero", 45)
		if not HeroSystem.is_deployed("knight"):
			profile_result["issues"].append("smoke: hero deploy failed")
		await _capture(main, "28_hero_deployed_1080x2340", profile_result, "Smoke hero deployed", "smoke_hero_deployed")
	_record_input("nav_spin")
	await _press_nav(main, "Btn_Rad")
	await _wait_view_visible("View_CoinMaster", 45)
	await _capture(main, "04_spin_open_1080x2340", profile_result, "Smoke SPIN open", "smoke_spin_open")
	if not profile_result["issues"].is_empty():
		profile_result["status"] = "FAIL"
		for issue in profile_result["issues"]:
			_report["visual_issues"].append("[smoke] %s" % issue)
	_report["viewport_matrix"]["(1080, 2340)"] = profile_result

func _run_profile(size: Vector2i) -> void:
	_apply_viewport(size)
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
	SaveGame.load_game()
	await _boot_to_main_game()
	var main := _main_scene()
	if main == null:
		_report["visual_issues"].append("MainGame missing at %s" % size)
		_report["viewport_matrix"][str(size)] = {"status": "FAIL", "reason": "no_main"}
		return
	await _prepare_deterministic_tap(main)
	var tag := "%dx%d" % [size.x, size.y]
	var profile_result := {"status": "PASS", "shots": [], "issues": []}

	await _capture(main, "01_main_%s" % tag, profile_result, "Main gameplay after boot", "main_boot")
	await _capture(main, "34_hud_resource_bars_%s" % tag, profile_result, "HUD v4 resource bars", "hud_resource_bars")
	await _capture(main, "35_hud_gold_bar_%s" % tag, profile_result, "Gold resource bar close", "hud_gold_bar")
	await _capture(main, "36_hud_spin_shield_bars_%s" % tag, profile_result, "Spin and shield resource bars", "hud_spin_shield")
	_record_input("tap_monster")
	var hp_before := PlayerData.current_monster_hp
	await main._on_monster_pressed()
	await _wait_hp_below(hp_before, 60)
	await _capture(main, "02_tap_hit_%s" % tag, profile_result, "After TAP hit", "tap_hit")
	await _capture_crit_hit(main, tag, profile_result)
	if _overlay_visible(main, "MonsterRewardOverlay"):
		await _capture(main, "03_defeat_reward_%s" % tag, profile_result, "Defeat/reward state", "defeat_reward")
		await _press_button(main, "MonsterRewardContinue")
		await _wait_combat_ready(main, 180)
	else:
		await _tap_until_defeat_reward(main, profile_result)
		await _capture(main, "03_defeat_reward_%s" % tag, profile_result, "Defeat/reward state", "defeat_reward")
		await _press_button(main, "MonsterRewardContinue")
		await _wait_combat_ready(main, 180)
	await _capture(main, "04_upgrade_open_%s" % tag, profile_result, "Upgrade panel visible", "upgrade_open")
	var tap_before := PlayerData.tap_damage
	var gold_before_upgrade := PlayerData.gold
	if PlayerData.gold < GameConfig.tap_upgrade_cost(PlayerData.tap_level):
		PlayerData.gold = GameConfig.tap_upgrade_cost(PlayerData.tap_level) + 50
	_record_input("tap_upgrade")
	await _press_button(main, "TapUpgradeButton")
	await _wait_render_stable(3)
	var upgrade_ok := PlayerData.tap_damage > tap_before and PlayerData.gold < gold_before_upgrade
	if not upgrade_ok:
		profile_result["issues"].append("tap upgrade did not increase damage")
	await _capture(main, "05_upgrade_bought_%s" % tag, profile_result, "After TAP upgrade", "upgrade_bought")
	await _run_hero_flow_qa(main, tag, profile_result)
	await _run_quest_daily_chest_flow_qa(main, tag, profile_result)
	await _run_boss_flow_qa(main, tag, profile_result)
	await _dismiss_overlays(main)
	_record_input("nav_spin")
	await _press_nav(main, "Btn_Rad")
	await _wait_view_visible("View_CoinMaster", 45)
	await _capture(main, "06_spin_open_%s" % tag, profile_result, "SPIN open", "spin_open")
	_record_input("spin")
	if PlayerData.spins <= 0:
		PlayerData.spins = 3
	await _press_button(main, "SpinButton")
	await _wait_spin_complete(main)
	await _capture(main, "07_spin_result_%s" % tag, profile_result, "SPIN result", "spin_result")
	await _dismiss_overlays(main)
	_record_input("nav_village")
	await _press_nav(main, "Btn_Dorf")
	await _wait_view_visible("View_ClashDorf", 45)
	await _capture(main, "08_village_%s" % tag, profile_result, "Village", "village")
	await _run_afk_flow_qa(main, tag, profile_result)
	var reload_ok := await _verify_save_reload(main, profile_result)
	if not reload_ok:
		profile_result["issues"].append("save reload state mismatch")
	await _capture(main, "19_main_reload_%s" % tag, profile_result, "Main after reload", "main_reload")
	_record_input("nav_modi")
	await _press_nav(main, "Btn_Tap")
	await _wait_render(2)
	await _press_button(main, "MoreFeaturesButtonP0")
	await _wait_overlay_visible("FeatureHubOverlayP0", 45)
	await _capture(main, "09_modes_%s" % tag, profile_result, "MODI feature hub", "modes_hub")
	await _press_button(main, "FeatureHubCloseP0")
	await _wait_render(2)
	await _press_button(main, "SettingsButtonP0")
	await _wait_overlay_visible("SettingsOverlayP0", 45)
	await _capture(main, "10_overlay_%s" % tag, profile_result, "Settings overlay", "settings_overlay")
	await _press_button(main, "SettingsCloseP0")
	await _wait_render(2)
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)
	await _capture(main, "11_return_main_%s" % tag, profile_result, "Return to main", "return_main")
	await _verify_assets_on_screen(main, profile_result)
	if not profile_result["issues"].is_empty():
		profile_result["status"] = "FAIL"
		for issue in profile_result["issues"]:
			_report["visual_issues"].append("[%s] %s" % [tag, issue])
	_report["viewport_matrix"][str(size)] = profile_result

func _capture_main_only(size: Vector2i) -> void:
	_apply_viewport(size)
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
	get_tree().change_scene_to_file("res://MainGame.tscn")
	await _wait_until_main_ready()
	var main := _main_scene()
	var tag := "%dx%d" % [size.x, size.y]
	var profile_result := {"status": "PASS" if main != null else "FAIL", "shots": [], "issues": []}
	if main == null:
		profile_result["issues"].append("MainGame missing")
		_report["viewport_matrix"][str(size)] = profile_result
		return
	if main.has_method("_apply_mobile_runtime_polish"):
		main.call("_apply_mobile_runtime_polish")
	await _prepare_deterministic_tap(main)
	await _capture(main, "01_main_%s" % tag, profile_result, "Main gameplay viewport matrix", "matrix_main")
	_report["viewport_matrix"][str(size)] = profile_result

func _run_tap_determinism() -> Dictionary:
	var runs: Array = []
	for i in TAP_RUNS:
		P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
		P0BootDiagnostics.qa_direct_main_load = true
		get_tree().change_scene_to_file("res://MainGame.tscn")
		await _wait_until_main_ready()
		P0BootDiagnostics.qa_direct_main_load = false
		await _wait_render_stable(20)
		var main := _main_scene()
		var run_result := {
			"run": i + 1,
			"pass": false,
			"hp_before": 0,
			"hp_after": 0,
			"monster_max_hp": 0,
			"reason": ""
		}
		if main == null:
			run_result["reason"] = "main_missing"
			runs.append(run_result)
			continue
		await _prepare_deterministic_tap(main)
		run_result["hp_before"] = PlayerData.current_monster_hp
		run_result["monster_max_hp"] = PlayerData.monster_max_hp
		if run_result["hp_before"] != run_result["monster_max_hp"]:
			run_result["reason"] = "hp_not_full"
			runs.append(run_result)
			continue
		var block_reason := _tap_block_reason(main)
		if not block_reason.is_empty():
			run_result["reason"] = block_reason
			runs.append(run_result)
			continue
		await main._on_monster_pressed()
		await _wait_hp_below(run_result["hp_before"], 90)
		run_result["hp_after"] = PlayerData.current_monster_hp
		run_result["pass"] = run_result["hp_after"] < run_result["hp_before"]
		if not run_result["pass"]:
			run_result["reason"] = "hp_unchanged"
		runs.append(run_result)
	var pass_count := 0
	for entry in runs:
		if bool(entry.get("pass", false)):
			pass_count += 1
	return {
		"required": TAP_RUNS,
		"pass_count": pass_count,
		"pass": pass_count == TAP_RUNS,
		"runs": runs
	}

func _run_regression_suite() -> Dictionary:
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_FRESH)
	P0BootDiagnostics.qa_direct_main_load = true
	get_tree().change_scene_to_file("res://MainGame.tscn")
	await _wait_until_main_ready()
	P0BootDiagnostics.qa_direct_main_load = false
	var main := _main_scene()
	var reg := {
		"boot": main != null,
		"tap": bool(_report.get("tap_determinism", {}).get("pass", false)),
		"navigation": false,
		"spin": false,
		"save": false
	}
	if main == null:
		return reg
	await _prepare_deterministic_tap(main)
	await _press_nav(main, "Btn_Rad")
	await _wait_view_visible("View_CoinMaster", 45)
	reg["navigation"] = _view_visible(main, "View_CoinMaster")
	if PlayerData.spins <= 0:
		PlayerData.spins = 3
	await _press_button(main, "SpinButton")
	await _wait_spin_complete(main)
	reg["spin"] = not bool(main.get("wheel_spinning")) and str(RewardPipeline.last_transaction.get("source", "")) == RewardPipeline.SOURCE_SPIN
	var gold_before := PlayerData.gold + 11
	PlayerData.gold = gold_before
	SaveGame.save_game()
	SaveGame.load_game()
	reg["save"] = PlayerData.gold == gold_before
	return reg

func _prepare_deterministic_tap(main: Control) -> void:
	if main.has_method("qa_prepare_combat_ready"):
		main.call("qa_prepare_combat_ready")
	elif main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	await _dismiss_overlays(main)
	core_input_unlock(main)
	await _wait_until(func() -> bool: return _main_tap_ready(main), 180)
	await _wait_render_stable(2)
	_force_combat_ready(main)
	await _wait_until(func() -> bool: return _main_tap_ready(main), 120)

func _force_combat_ready(main: Control) -> void:
	if main == null:
		return
	if main.has_method("qa_prepare_combat_ready"):
		main.call("qa_prepare_combat_ready")
	elif main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")

func _main_tap_ready(main: Control) -> bool:
	return _tap_block_reason(main).is_empty()

func _tap_block_reason(main: Control) -> String:
	if main == null:
		return "main_missing"
	if main.has_method("_core_modal_open") and bool(main.call("_core_modal_open")):
		return "core_modal_open"
	if bool(main.get("core_input_locked")):
		return "core_input_locked"
	if bool(main.get("monster_state_locked")):
		return "monster_state_locked"
	if bool(main.get("monster_reaction_active")):
		return "monster_reaction_active"
	if PlayerData.current_monster_hp <= 0:
		return "monster_hp_zero"
	return ""

func _boot_to_main_game() -> void:
	get_tree().change_scene_to_file("res://BootFlow.tscn")
	await _wait_render_stable(4)
	var boot := get_tree().current_scene
	if boot and boot.has_method("_guest_game"):
		_record_input("boot_guest")
		boot.call("_guest_game")
	await _wait_until_main_ready()
	_log("main loaded=%s" % (_main_scene() != null))

func _wait_until_main_ready() -> void:
	await _wait_until(func() -> bool: return _main_scene() != null, 180)
	var main := _main_scene()
	if main and main.has_method("_apply_mobile_runtime_polish"):
		main.call("_apply_mobile_runtime_polish")
	await _wait_render_stable(4)

func _main_scene() -> Control:
	var current := get_tree().current_scene
	if current != null and current.name == "MainGame":
		return current as Control
	return null

func _apply_viewport(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(size)
	var root := get_tree().root
	if root is Window:
		(root as Window).size = size
	await get_tree().process_frame

func _wait_render(frames: int) -> void:
	for _i in range(maxi(frames, 1)):
		await get_tree().process_frame

func _wait_render_stable(frames: int) -> void:
	for _i in range(maxi(frames, 1)):
		RenderingServer.force_draw()
		await get_tree().process_frame

func _wait_until(condition: Callable, max_frames: int) -> bool:
	for _i in range(maxi(max_frames, 1)):
		if condition.is_valid() and bool(condition.call()):
			return true
		await get_tree().process_frame
	return condition.is_valid() and bool(condition.call())

func _wait_hp_below(hp_before: int, max_frames: int) -> bool:
	return await _wait_until(func() -> bool: return PlayerData.current_monster_hp < hp_before, max_frames)

func _wait_view_visible(view_name: String, max_frames: int) -> bool:
	return await _wait_until(func() -> bool:
		var scene := _main_scene()
		return scene != null and _view_visible(scene, view_name)
	, max_frames)

func _wait_overlay_visible(overlay_name: String, max_frames: int) -> bool:
	return await _wait_until(func() -> bool:
		var scene := _main_scene()
		return scene != null and _overlay_visible(scene, overlay_name)
	, max_frames)

func _wait_combat_ready(main: Control, max_frames: int) -> bool:
	return await _wait_until(func() -> bool: return _main_tap_ready(main), max_frames)

func _wait_defeat_reward_overlay(main: Control, max_frames: int) -> bool:
	return await _wait_until(func() -> bool: return _overlay_visible(main, "MonsterRewardOverlay"), max_frames)

func _tap_until_defeat_reward(main: Control, profile_result: Dictionary, max_taps: int = 60) -> void:
	if _overlay_visible(main, "MonsterRewardOverlay"):
		return
	var taps := 0
	while taps < max_taps and PlayerData.current_monster_hp > 0:
		if _overlay_visible(main, "MonsterRewardOverlay"):
			break
		if not _main_tap_ready(main):
			if main.has_method("qa_prepare_combat_ready"):
				main.call("qa_prepare_combat_ready")
			await _wait_combat_ready(main, 90)
			if not _main_tap_ready(main):
				await _wait_render_stable(2)
				continue
		await main._on_monster_pressed()
		taps += 1
		await _wait_render_stable(1)
		if _overlay_visible(main, "MonsterRewardOverlay"):
			break
	if not _overlay_visible(main, "MonsterRewardOverlay"):
		await _wait_defeat_reward_overlay(main, 240)
	if not _overlay_visible(main, "MonsterRewardOverlay"):
		profile_result["issues"].append("defeat reward overlay not shown")

func _tap_until_boss_defeat_reward(main: Control, profile_result: Dictionary) -> void:
	var taps := 0
	while taps < 40 and PlayerData.current_monster_hp > 0:
		if _overlay_visible(main, "MonsterRewardOverlay"):
			break
		if str(RewardPipeline.last_transaction.get("source", "")) == RewardPipeline.SOURCE_BOSS_DEFEAT:
			break
		if not P0MonsterVisualSystem.is_boss(PlayerData.monster_level):
			profile_result["issues"].append("boss encounter lost before defeat")
			break
		if not _main_tap_ready(main):
			if main.has_method("qa_prepare_combat_ready"):
				main.call("qa_prepare_combat_ready")
			await _wait_combat_ready(main, 90)
			continue
		await main._on_monster_pressed()
		taps += 1
		await _wait_render_stable(1)
	if not _overlay_visible(main, "MonsterRewardOverlay") and str(RewardPipeline.last_transaction.get("source", "")) != RewardPipeline.SOURCE_BOSS_DEFEAT:
		await _wait_defeat_reward_overlay(main, 240)
	if str(RewardPipeline.last_transaction.get("source", "")) != RewardPipeline.SOURCE_BOSS_DEFEAT:
		profile_result["issues"].append("boss reward transaction missing")

func _run_hero_flow_qa(main: Control, tag: String, profile_result: Dictionary) -> void:
	if not FeatureFlags.SHOW_HEROES:
		profile_result["issues"].append("heroes feature flag disabled")
		return
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)
	await _press_button(main, "MoreFeaturesButtonP0")
	await _wait_overlay_visible("FeatureHubOverlayP0", 45)
	await _press_button(main, "HubHeroesP0")
	await _wait_view_visible("View_Heroes", 45)
	await _capture(main, "28_hero_collection_locked_%s" % tag, profile_result, "Hero collection locked", "hero_collection_locked")
	if HeroSystem.is_unlocked("knight"):
		profile_result["issues"].append("knight should be locked on fresh profile")
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_HERO_UNLOCK)
	if main.has_method("_refresh_all"):
		main.call("_refresh_all")
	await _wait_render_stable(4)
	if not HeroSystem.is_unlocked("knight"):
		profile_result["issues"].append("knight unlock via player level 5 failed")
	await _capture(main, "29_hero_unlock_%s" % tag, profile_result, "Hero unlock", "hero_unlock")
	await _press_button(main, "HeroKnight")
	await _wait_render_stable(2)
	await _capture(main, "37_hero_detail_%s" % tag, profile_result, "Hero detail selected", "hero_detail")
	await _press_button(main, "HeroKnight")
	await _wait_render_stable(2)
	if not HeroSystem.is_deployed("knight"):
		profile_result["issues"].append("knight deploy failed")
	await _capture(main, "30_hero_deployed_%s" % tag, profile_result, "Hero deployed", "hero_deployed")
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)
	var hp_before_hero := PlayerData.current_monster_hp
	var mlevel_before := PlayerData.monster_level
	var strike := HeroSystem.force_attack_tick()
	var hit: Dictionary = strike.get("hit", {})
	if not bool(strike.get("ok", false)):
		profile_result["issues"].append("hero force attack failed: %s" % str(strike.get("message", "?")))
	elif int(strike.get("damage", 0)) <= 0:
		profile_result["issues"].append("hero auto attack damage was zero")
	elif int(strike.get("hp_after", hp_before_hero)) >= hp_before_hero and PlayerData.monster_level == mlevel_before:
		profile_result["issues"].append("hero auto attack did not reduce HP")
	if str(hit.get("source_type", CombatDamageResolver.last_hit.get("source_type", ""))) != "hero":
		profile_result["issues"].append("hero damage not via unified resolver")
	await _wait_render_stable(4)
	await _capture(main, "31_hero_auto_attack_%s" % tag, profile_result, "Hero auto attack", "hero_auto_attack")
	var hp_before_tap := PlayerData.current_monster_hp
	await main._on_monster_pressed()
	await _wait_hp_below(hp_before_tap, 60)
	await _capture(main, "32_combined_combat_%s" % tag, profile_result, "Combined combat", "combined_combat")
	await _press_button(main, "MoreFeaturesButtonP0")
	await _wait_overlay_visible("FeatureHubOverlayP0", 45)
	await _press_button(main, "HubHeroesP0")
	await _wait_view_visible("View_Heroes", 45)
	var power_before := HeroSystem.get_power("knight")
	var gold_before := PlayerData.gold
	var cost := HeroSystem.get_upgrade_cost("knight")
	if PlayerData.gold < cost:
		PlayerData.gold = cost + 200
	await _press_button(main, "HeroUpgradeButtonP0")
	await _wait_render_stable(3)
	if HeroSystem.get_power("knight") <= power_before:
		profile_result["issues"].append("hero level up did not increase power")
	if PlayerData.gold >= gold_before and cost > 0:
		profile_result["issues"].append("hero level up did not spend gold")
	await _capture(main, "33_hero_level_up_%s" % tag, profile_result, "Hero level up", "hero_level_up")
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)

func _run_quest_daily_chest_flow_qa(main: Control, tag: String, profile_result: Dictionary) -> void:
	_record_input("nav_quests")
	await _press_button(main, "QuestButton")
	await _wait_view_visible("View_Quests", 45)
	await _capture(main, "20_quest_initial_%s" % tag, profile_result, "Quest initial", "quest_initial")
	var claimed_id := ""
	var category := ""
	for cat in ["starter", "daily"]:
		for row in ObjectiveSystem.rows(cat):
			if bool(row.get("ready", false)):
				claimed_id = str(row.get("id", ""))
				category = cat
				break
		if not claimed_id.is_empty():
			break
	if not claimed_id.is_empty():
		var gold_before := PlayerData.gold
		var claim := ObjectiveSystem.claim(category, claimed_id)
		if not bool(claim.get("ok", false)):
			profile_result["issues"].append("quest claim failed: %s" % claimed_id)
		elif PlayerData.gold <= gold_before and int(claim.get("reward", {}).get("gold", 0)) > 0:
			profile_result["issues"].append("quest claim did not increase gold")
		var duplicate := ObjectiveSystem.claim(category, claimed_id)
		if bool(duplicate.get("ok", false)):
			profile_result["issues"].append("quest duplicate claim not blocked")
		await _capture(main, "21_quest_complete_%s" % tag, profile_result, "Quest complete", "quest_complete")
		await _capture(main, "22_quest_reward_%s" % tag, profile_result, "Quest reward", "quest_reward")
	if main.has_method("_rebuild_quests"):
		main.call("_rebuild_quests")
	await _press_button(main, "DailyButton")
	await _wait_view_visible("View_Daily", 45)
	await _capture(main, "23_daily_screen_%s" % tag, profile_result, "Daily screen", "daily_screen")
	if DailyRewards.can_claim_today():
		var gold_before_daily := PlayerData.gold
		var daily := DailyRewards.claim_today()
		if not bool(daily.get("ok", false)):
			profile_result["issues"].append("daily claim failed")
		elif PlayerData.gold <= gold_before_daily:
			profile_result["issues"].append("daily claim did not increase gold")
		var daily_dup := DailyRewards.claim_today()
		if bool(daily_dup.get("ok", false)):
			profile_result["issues"].append("daily duplicate claim not blocked")
		if str(RewardPipeline.last_transaction.get("source", "")) != RewardPipeline.SOURCE_DAILY:
			profile_result["issues"].append("daily reward not via RewardPipeline")
		await _capture(main, "24_daily_complete_%s" % tag, profile_result, "Daily complete", "daily_complete")
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)

func _run_boss_flow_qa(main: Control, tag: String, profile_result: Dictionary) -> void:
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)
	P0TestHarness.apply_profile(P0TestHarness.PROFILE_BOSS_READY)
	if main.has_method("_refresh_all"):
		main.call("_refresh_all")
	await _wait_combat_ready(main, 180)
	await _capture(main, "12_boss_ready_%s" % tag, profile_result, "Boss ready", "boss_ready")
	if main.has_method("_show_boss_intro"):
		await main._show_boss_intro()
	await _capture(main, "13_boss_intro_%s" % tag, profile_result, "Boss intro", "boss_intro")
	PlayerData.tap_damage = maxi(PlayerData.tap_damage, 40)
	await _capture(main, "14_boss_combat_%s" % tag, profile_result, "Boss combat", "boss_combat")
	if BossChallengeSystem.active:
		BossChallengeSystem.time_remaining = 0.01
		BossChallengeSystem.tick(0.05)
		await _wait_render_stable(6)
		await _capture(main, "14b_boss_failure_%s" % tag, profile_result, "Boss failure", "boss_failure")
		if not BossChallengeSystem.failed:
			profile_result["issues"].append("boss failure state not set")
		await main._on_monster_pressed()
		await _wait_render_stable(4)
		await _capture(main, "14c_boss_retry_%s" % tag, profile_result, "Boss retry", "boss_retry")
	PlayerData.tap_damage = maxi(PlayerData.tap_damage, 120)
	await _tap_until_boss_defeat_reward(main, profile_result)
	await _wait_defeat_reward_overlay(main, 240)
	await _capture(main, "15_boss_victory_%s" % tag, profile_result, "Boss victory", "boss_victory")
	await _capture(main, "16_boss_reward_%s" % tag, profile_result, "Boss reward", "boss_reward")
	await _press_button(main, "MonsterRewardContinue")
	await _wait_combat_ready(main, 180)
	await _capture(main, "17_stage_progress_%s" % tag, profile_result, "Stage progression", "stage_progress")
	if ChestRewardSystem.has_pending_chest():
		await _press_button(main, "QuestButton")
		await _wait_view_visible("View_Quests", 45)
		await _capture(main, "25_chest_acquired_%s" % tag, profile_result, "Chest acquired", "chest_acquired")
		var pending := ChestRewardSystem.next_pending()
		var chest_id := str(pending.get("chest_id", ""))
		var gold_before_chest := PlayerData.gold
		var opened := ChestRewardSystem.open_chest(chest_id)
		if not bool(opened.get("ok", false)):
			profile_result["issues"].append("chest open failed")
		elif PlayerData.gold <= gold_before_chest and int(opened.get("reward", {}).get("gold", 0)) > 0:
			profile_result["issues"].append("chest open did not increase gold")
		var dup_open := ChestRewardSystem.open_chest(chest_id)
		if bool(dup_open.get("ok", false)):
			profile_result["issues"].append("chest duplicate open not blocked")
		await _capture(main, "26_chest_opening_%s" % tag, profile_result, "Chest opening", "chest_opening")
		await _capture(main, "27_chest_reward_%s" % tag, profile_result, "Chest reward", "chest_reward")
		await _press_nav(main, "Btn_Tap")
		await _wait_view_visible("View_TapHero", 45)

func _run_afk_flow_qa(main: Control, tag: String, profile_result: Dictionary) -> void:
	await _press_nav(main, "Btn_Tap")
	await _wait_view_visible("View_TapHero", 45)
	await _dismiss_overlays(main)
	AfkRewardSystem.qa_prepare_seconds(600)
	if main.has_method("_show_afk_if_pending_p0"):
		main.call("_show_afk_if_pending_p0")
	await _wait_until(func() -> bool: return _overlay_visible(main, "AfkOverlayP0"), 90)
	await _capture(main, "17_afk_return_%s" % tag, profile_result, "AFK return", "afk_return")
	var gold_before := PlayerData.gold
	await _press_button(main, "AfkClaimP0")
	await _wait_render_stable(4)
	var second := AfkRewardSystem.claim()
	if bool(second.get("ok", false)):
		profile_result["issues"].append("afk duplicate claim not blocked")
	if PlayerData.gold <= gold_before:
		profile_result["issues"].append("afk claim did not increase gold")
	await _dismiss_overlays(main)
	core_input_unlock(main)
	await _capture(main, "18_afk_claim_%s" % tag, profile_result, "AFK claim", "afk_claim")

func core_input_unlock(main: Control) -> void:
	if main != null and main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")

func _verify_save_reload(main: Control, profile_result: Dictionary) -> bool:
	var expected := {
		"monster_level": PlayerData.monster_level,
		"gold": PlayerData.gold,
		"tap_level": PlayerData.tap_level,
		"tap_damage": PlayerData.tap_damage,
		"hero_deployed": HeroSystem.get_deployed_hero_id(),
		"hero_level": HeroSystem.get_level(HeroSystem.get_selected_hero_id())
	}
	SaveGame.save_game()
	SaveGame.load_game()
	var ok := PlayerData.monster_level == int(expected.monster_level) \
		and PlayerData.gold == int(expected.gold) \
		and PlayerData.tap_level == int(expected.tap_level) \
		and PlayerData.tap_damage == int(expected.tap_damage) \
		and HeroSystem.get_deployed_hero_id() == str(expected.hero_deployed) \
		and HeroSystem.get_level(HeroSystem.get_selected_hero_id()) == int(expected.hero_level)
	if main != null and main.has_method("_refresh_all"):
		main.call("_refresh_all")
	return ok

func _wait_spin_complete(main: Control) -> void:
	await _wait_until(func() -> bool:
		var scene := _main_scene()
		if scene == null:
			return true
		return not bool(scene.get("wheel_spinning"))
	, 240)
	await _wait_render_stable(2)

func _snapshot_state(main: Control, step: String, screenshot_filename: String) -> Dictionary:
	var vp := get_tree().root.get_viewport().get_visible_rect().size
	var active_view := ""
	for view_name in ["View_TapHero", "View_CoinMaster", "View_ClashDorf", "View_Quests"]:
		if _view_visible(main, view_name):
			active_view = view_name
			break
	return {
		"step": step,
		"screenshot": screenshot_filename,
		"timestamp_ms": Time.get_ticks_msec(),
		"viewport": [int(vp.x), int(vp.y)],
		"active_view": active_view,
		"encounter_id": P0MonsterVisualSystem.encounter_id_for_level(PlayerData.monster_level),
		"monster_id": P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level),
		"monster_level": PlayerData.monster_level,
		"monster_hp": PlayerData.current_monster_hp,
		"monster_max_hp": PlayerData.monster_max_hp,
		"gold": PlayerData.gold,
		"spins": PlayerData.spins,
		"shields": PlayerData.shields,
		"core_input_locked": bool(main.get("core_input_locked")) if main else true,
		"monster_state_locked": bool(main.get("monster_state_locked")) if main else true,
		"wheel_spinning": bool(main.get("wheel_spinning")) if main else false,
		"tap_damage": PlayerData.tap_damage,
		"tap_level": PlayerData.tap_level,
		"crit_level": PlayerData.crit_level,
		"crit_chance_pct": int(round(GameConfig.effective_crit_chance() * 100.0)),
		"last_hit_critical": bool(CombatDamageResolver.last_hit.get("critical", false)),
		"encounter_progress": EncounterProgressService.progress_label(PlayerData.monster_level),
		"stage": EncounterProgressService.stage_in_cycle(PlayerData.monster_level),
		"reward_source": str(RewardPipeline.last_transaction.get("source", "")),
		"reward_transaction_id": str(RewardPipeline.last_transaction.get("transaction_id", "")),
		"gold_before_txn": int(RewardPipeline.last_transaction.get("balances_before", {}).get("gold", PlayerData.gold)),
		"gold_after_txn": int(RewardPipeline.last_transaction.get("balances_after", {}).get("gold", PlayerData.gold)),
		"boss_state": str(BossChallengeSystem.snapshot().get("boss_state", "")),
		"boss_hp": PlayerData.current_monster_hp,
		"boss_timer": snapped(BossChallengeSystem.time_remaining, 0.1),
		"afk_elapsed": int(AfkRewardSystem.pending_reward.get("seconds", AfkRewardSystem.last_prepared_seconds)),
		"afk_calculated_reward": int(AfkRewardSystem.pending_reward.get("gold", 0)),
		"afk_claimed": AfkRewardSystem.pending_reward.is_empty(),
		"player_level": PlayerData.player_level,
		"player_xp": PlayerData.player_xp,
		"daily_bucket": ObjectiveSystem.daily_bucket,
		"daily_progress": ObjectiveSystem.daily.duplicate(true),
		"quest_ready_count": ObjectiveSystem.ready_count(),
		"chest_pending": ChestRewardSystem.pending_count(),
		"boss_failure": BossChallengeSystem.failed,
		"hero_id": HeroSystem.get_deployed_hero_id(),
		"hero_owned": HeroSystem.is_unlocked("knight"),
		"hero_unlocked": HeroSystem.is_unlocked(HeroSystem.get_selected_hero_id()),
		"hero_level": HeroSystem.get_level(HeroSystem.get_selected_hero_id()),
		"hero_deployed": not HeroSystem.get_deployed_hero_id().is_empty(),
		"hero_power": HeroSystem.get_power(HeroSystem.get_deployed_hero_id()) if not HeroSystem.get_deployed_hero_id().is_empty() else 0,
		"hero_dps": snapped(HeroSystem.get_total_auto_dps(), 0.1),
		"hero_attack_interval": HeroSystem.get_attack_interval(HeroSystem.get_deployed_hero_id()) if not HeroSystem.get_deployed_hero_id().is_empty() else 0.0,
		"damage_source": str(CombatDamageResolver.last_hit.get("source_type", "")),
		"hero_damage": int(CombatDamageResolver.last_hit.get("damage", 0)) if str(CombatDamageResolver.last_hit.get("source_type", "")) == "hero" else 0
	}

func _capture_crit_hit(main: Control, tag: String, profile_result: Dictionary) -> void:
	await _wait_combat_ready(main, 120)
	CombatDamageResolver.force_next_crit = true
	await main._on_monster_pressed()
	await _wait_render_stable(5)
	var found_crit := bool(CombatDamageResolver.last_hit.get("critical", false))
	if not found_crit and _overlay_visible(main, "MonsterRewardOverlay"):
		await _press_button(main, "MonsterRewardContinue")
		await _wait_combat_ready(main, 120)
		CombatDamageResolver.force_next_crit = true
		await main._on_monster_pressed()
		await _wait_render_stable(5)
		found_crit = bool(CombatDamageResolver.last_hit.get("critical", false))
	await _capture(main, "02b_crit_hit_%s" % tag, profile_result, "Critical hit", "crit_hit")
	if not found_crit:
		profile_result["issues"].append("crit screenshot could not be produced")

func _capture(main: Control, filename: String, profile_result: Dictionary, label: String, step: String) -> void:
	await _wait_render_stable(3)
	var evidence := _snapshot_state(main, step, filename)
	_state_evidence.append(evidence)
	var analysis: Dictionary = await _grab_viewport_image(filename)
	analysis["label"] = label
	analysis["state"] = evidence
	profile_result["shots"].append(analysis)
	_report["screenshots"].append(analysis)
	if not bool(analysis.get("ok", false)):
		profile_result["issues"].append("%s capture failed: %s" % [filename, analysis.get("reason", "?")])

func _grab_viewport_image(filename: String) -> Dictionary:
	var rel := "%s/%s.png" % [SHOT_DIR, filename]
	var abs_path := ProjectSettings.globalize_path(rel)
	RenderingServer.force_draw()
	await get_tree().process_frame
	var vp := get_tree().root.get_viewport()
	if vp == null:
		return {"ok": false, "reason": "no_viewport", "file": rel, "filename": filename}
	var tex := vp.get_texture()
	if tex == null:
		return {"ok": false, "reason": "no_texture", "file": rel, "filename": filename}
	var img := tex.get_image()
	if img == null or img.is_empty():
		return {"ok": false, "reason": "empty_image", "file": rel, "filename": filename}
	var err := img.save_png(abs_path)
	if err != OK:
		return {"ok": false, "reason": "save_error_%s" % err, "file": rel, "filename": filename}
	return _analyze_image(img, rel, filename)

func _analyze_image(img: Image, rel_path: String, filename: String) -> Dictionary:
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
	var ok := w >= 900 and h >= 1600 and dark_ratio < 0.92 and bright_ratio > 0.04
	var result := {
		"ok": ok,
		"file": rel_path,
		"filename": filename,
		"width": w,
		"height": h,
		"dark_ratio": snapped(dark_ratio, 0.001),
		"bright_ratio": snapped(bright_ratio, 0.001),
		"size_ok": w >= 900 and h >= 1600,
		"not_black": dark_ratio < 0.92,
		"has_content": bright_ratio > 0.04
	}
	if not ok:
		result["reason"] = "analysis_fail dark=%.2f bright=%.2f" % [dark_ratio, bright_ratio]
	return result

func _tap_monster(main: Control, times: int) -> void:
	for _i in range(times):
		if not _main_tap_ready(main):
			break
		await main._on_monster_pressed()
		await _wait_render(4)
		if main.has_method("_core_modal_open") and bool(main.call("_core_modal_open")):
			await _dismiss_overlays(main)

func _press_nav(main: Control, node_name: String) -> void:
	if main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	await _press_button(main, node_name)

func _press_button(main: Control, node_name: String) -> void:
	var btn: Node = main.find_child(node_name, true, false)
	if btn is BaseButton:
		(btn as BaseButton).emit_signal("pressed")
	await _wait_render(2)

func _dismiss_overlays(main: Control) -> void:
	if main.has_method("_reset_core_transient_state"):
		main.call("_reset_core_transient_state")
	for name in ["MonsterRewardContinue", "WheelRewardContinueP0", "NoSpinsClose", "FeatureHubCloseP0", "SettingsCloseP0", "BuildingUpgradeCloseP0"]:
		var btn: Node = main.find_child(name, true, false)
		if btn is BaseButton and (btn as BaseButton).visible:
			(btn as BaseButton).emit_signal("pressed")
			await _wait_render(3)

func _view_visible(main: Control, node_name: String) -> bool:
	var node := main.find_child(node_name, true, false) as Control
	return node != null and node.visible

func _overlay_visible(main: Control, node_name: String) -> bool:
	var node := main.find_child(node_name, true, false) as Control
	return node != null and node.visible

func _verify_assets_on_screen(main: Control, profile_result: Dictionary) -> void:
	var checks := [
		["M001_monster", "MonsterButton", "TextureButton"],
		["gruenhain_bg", "Background", "TextureRect"],
		["gold_hud", "GoldPillP0", "TextureRect"],
		["spin_hud", "SpinPillP0", "TextureRect"],
		["shield_hud", "ShieldPillP0", "TextureRect"]
	]
	for entry in checks:
		var id: String = entry[0]
		var node: Node = main.find_child(entry[1], true, false)
		if node == null:
			profile_result["issues"].append("missing node %s" % entry[1])
			continue
		var verified := false
		var tex: Texture2D = null
		if node is TextureButton:
			tex = (node as TextureButton).texture_normal
			verified = tex != null
		elif node is TextureRect:
			tex = (node as TextureRect).texture
			verified = tex != null
		if id.ends_with("_hud"):
			if tex != null and _is_legacy_hud_pill(tex):
				profile_result["issues"].append("%s still uses legacy UI015-017 pill" % entry[1])
				verified = false
			elif tex != null and not _is_production_resource_bar(tex):
				profile_result["issues"].append("%s not bound to v4 resource_bars" % entry[1])
				verified = false
		if verified:
			_report["asset_verification"].append({"asset": id, "node": entry[1], "verified": true})
		else:
			if tex == null:
				profile_result["issues"].append("asset not bound: %s" % id)
			_report["asset_verification"].append({"asset": id, "node": entry[1], "verified": false})
	if FeatureFlags.SHOW_HEROES:
		for hero_node in ["HeroKnight", "HeroArcher", "HeroMage"]:
			var button := main.find_child(hero_node, true, false) as Button
			if button == null:
				continue
			var portrait := button.find_child("HeroPortraitV2061", false, false) as TextureRect
			var portrait_ok := portrait != null and portrait.texture != null and portrait.texture.resource_path.find("hero_") >= 0 and portrait.texture.resource_path.find("portrait") >= 0
			_report["asset_verification"].append({"asset": "hero_portrait_%s" % hero_node, "node": hero_node, "verified": portrait_ok})
			if not portrait_ok:
				profile_result["issues"].append("hero portrait slot missing on %s" % hero_node)

func _is_legacy_hud_pill(tex: Texture2D) -> bool:
	var path := tex.resource_path
	return path.find("UI015") >= 0 or path.find("UI016") >= 0 or path.find("UI017") >= 0

func _is_production_resource_bar(tex: Texture2D) -> bool:
	return tex.resource_path.find("resource_bars") >= 0

func _record_input(action: String) -> void:
	if action not in _report["inputs_executed"]:
		_report["inputs_executed"].append(action)

func _finalize_report() -> void:
	var elapsed_sec := float(Time.get_ticks_msec() - _started_ms) / 1000.0
	_report["state_evidence"] = _state_evidence.duplicate(true)
	_report["qa_performance"] = {
		"elapsed_sec": snapped(elapsed_sec, 0.1),
		"baseline_full_sec": BASELINE_FULL_SEC,
		"mode": _report["mode"]
	}

	var tap_ok: bool = bool(_report.get("tap_determinism", {}).get("pass", false))
	var reg: Dictionary = _report.get("regression", {})
	var reg_ok: bool = bool(reg.get("boot", false)) and bool(reg.get("navigation", false)) and bool(reg.get("spin", false)) and bool(reg.get("save", false)) and bool(reg.get("tap", false))

	var shots_ok := true
	var required: Array = ["01_main_1080x2340", "02_tap_hit_1080x2340", "04_spin_open_1080x2340"] if _mode == QaMode.SMOKE else FULL_REQUIRED_SHOTS
	for req in required:
		var found := false
		for shot in _report["screenshots"]:
			if str(shot.get("filename", "")) == req and bool(shot.get("ok", false)):
				found = true
				break
		if not found:
			shots_ok = false

	var visual_issues: Array = _report["visual_issues"]
	var visual_ok: bool = shots_ok and visual_issues.is_empty()
	if _mode == QaMode.FULL:
		for key in _report["viewport_matrix"]:
			if str(_report["viewport_matrix"][key].get("status", "")) != "PASS":
				visual_ok = false

	if tap_ok and reg_ok and visual_ok:
		_report["status"] = "PASS"
	else:
		_report["status"] = "BLOCKED"
		if not tap_ok:
			_report["visual_issues"].append("TAP determinism failed: %s/%s" % [_report["tap_determinism"].get("pass_count", 0), TAP_RUNS])
		if not reg_ok:
			_report["visual_issues"].append("Regression failed: %s" % JSON.stringify(reg))
		if not shots_ok:
			_report["visual_issues"].append("Required screenshot evidence missing or invalid")

	_report["exit"] = {
		"method": "get_tree().quit(code)",
		"expected_code": 0 if _report["status"] == "PASS" else 1,
		"note": "Exit -1 from outer shell timeout/kill is not Godot quit; host uses quit(0|1)"
	}

	var json_path := ProjectSettings.globalize_path(REPORT_JSON)
	var json_file := FileAccess.open(json_path, FileAccess.WRITE)
	if json_file:
		json_file.store_string(JSON.stringify(_report, "\t"))
		json_file.close()

	var evidence_path := ProjectSettings.globalize_path(STATE_EVIDENCE_PATH)
	var evidence_file := FileAccess.open(evidence_path, FileAccess.WRITE)
	if evidence_file:
		evidence_file.store_string(JSON.stringify(_state_evidence, "\t"))
		evidence_file.close()

	_write_markdown_report()
	print(JSON.stringify({"status": _report["status"], "elapsed_sec": elapsed_sec, "tap": _report["tap_determinism"]}))

func _write_markdown_report() -> void:
	var lines: PackedStringArray = []
	lines.append("# V2.06.0 Visual Runtime Acceptance")
	lines.append("")
	lines.append("**Status:** %s" % _report.get("status", "BLOCKED"))
	lines.append("**Mode:** %s" % _report.get("mode", "full"))
	lines.append("**Elapsed:** %.1fs (baseline full ~%.0fs)" % [_report["qa_performance"].get("elapsed_sec", 0.0), BASELINE_FULL_SEC])
	lines.append("")
	lines.append("## PASS/FAIL logic")
	lines.append("")
	lines.append("- TAP determinism: %s/%s required" % [_report["tap_determinism"].get("pass_count", 0), TAP_RUNS])
	lines.append("- Regression: `%s`" % JSON.stringify(_report.get("regression", {})))
	lines.append("- Visual screenshots + viewport matrix must PASS")
	lines.append("- No manual PASS overrides")
	lines.append("")
	lines.append("## Screenshots")
	lines.append("")
	for shot in _report.get("screenshots", []):
		lines.append("- `%s.png` — %s — %s" % [shot.get("filename", "?"), shot.get("label", ""), "PASS" if shot.get("ok") else "FAIL"])
	lines.append("")
	lines.append("## State evidence")
	lines.append("")
	lines.append("`state_evidence.json` — %d entries linked to captures" % _state_evidence.size())
	var md_path := ProjectSettings.globalize_path(REPORT_MD)
	var md_file := FileAccess.open(md_path, FileAccess.WRITE)
	if md_file:
		md_file.store_string("\n".join(lines))
		md_file.close()

func get_report() -> Dictionary:
	return _report.duplicate(true)
