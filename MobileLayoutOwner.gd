extends RefCounted
class_name MobileLayoutOwner

## V2.01 — single owner for mobile geometry (1080×2340 primary QA viewport).
## Replaces competing passes from ResponsiveLayout, ScreenCompositionService geometry,
## FinalAlphaConvergenceV200 layout, and V194–V197 resize apply() chains.

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

const PROFILE_SMALL := "small"
const PROFILE_STANDARD := "standard"
const PROFILE_TALL := "tall"

const NAV_HEIGHT_SMALL := 96.0
const NAV_HEIGHT_STANDARD := 108.0
const NAV_HEIGHT_TALL := 112.0
const NAV_FONT_SMALL := 20
const NAV_FONT_STANDARD := 22
const NAV_FONT_TALL := 24

static func detect_profile(viewport_size: Vector2) -> String:
	var aspect: float = viewport_size.y / maxf(viewport_size.x, 1.0)
	if viewport_size.x <= 760.0 or viewport_size.y <= 1650.0:
		return PROFILE_SMALL
	if aspect >= 2.05:
		return PROFILE_TALL
	return PROFILE_STANDARD

static func apply(root: Control) -> void:
	if root == null:
		return
	var vp := root.get_viewport_rect().size
	var profile := detect_profile(vp)
	var compact := vp.x < 520.0 or vp.y < 820.0
	_apply_safe_area(root, profile)
	_apply_top_hud(root, profile, compact)
	_apply_primary_navigation(root, profile, compact)
	_apply_home_tap(root, profile, compact)
	_apply_spin_reels(root, profile, compact)
	_apply_village(root, profile, compact)
	_apply_mode_views(root, profile, compact, vp)
	_apply_overlays(root, profile, vp)
	_hide_legacy_nodes(root)

static func _apply_safe_area(root: Control, profile: String) -> void:
	var safe := root.find_child("Safe", true, false) as MarginContainer
	if safe == null:
		return
	match profile:
		PROFILE_SMALL:
			safe.add_theme_constant_override("margin_left", 18)
			safe.add_theme_constant_override("margin_right", 18)
			safe.add_theme_constant_override("margin_top", 22)
			safe.add_theme_constant_override("margin_bottom", 14)
		PROFILE_TALL:
			safe.add_theme_constant_override("margin_left", 28)
			safe.add_theme_constant_override("margin_right", 28)
			safe.add_theme_constant_override("margin_top", 44)
			safe.add_theme_constant_override("margin_bottom", 34)
		_:
			safe.add_theme_constant_override("margin_left", 24)
			safe.add_theme_constant_override("margin_right", 24)
			safe.add_theme_constant_override("margin_top", 36)
			safe.add_theme_constant_override("margin_bottom", 26)

static func _apply_top_hud(root: Control, profile: String, compact: bool) -> void:
	var topbar := root.find_child("TopBar", true, false) as Control
	if topbar:
		topbar.custom_minimum_size.y = 96.0 if profile == PROFILE_SMALL else (120.0 if profile == PROFILE_TALL else 112.0)
		topbar.add_theme_constant_override("separation", 10 if profile == PROFILE_TALL else 8)
	var quick := root.find_child("QuickActions", true, false) as Control
	if quick:
		quick.visible = false
	for name in ["DailyButton", "JourneyButton", "QuestButton", "HeroesGameButton", "LaneBattleButton", "DefenseGameButton", "PuzzleButton", "MetaButton"]:
		var shortcut := root.find_child(name, true, false) as Control
		if shortcut:
			shortcut.visible = false
	var pill_w := 170.0 if profile == PROFILE_SMALL else (250.0 if profile == PROFILE_TALL else 230.0)
	var pill_h := 84.0 if profile == PROFILE_SMALL else (96.0 if profile == PROFILE_TALL else 90.0)
	for name in ["GoldPillP0", "SpinPillP0", "ShieldPillP0"]:
		var pill := root.find_child(name, true, false) as Control
		if pill:
			pill.custom_minimum_size = Vector2(pill_w, pill_h)
	for name in ["GoldLabel", "SpinsLabel", "ShieldsLabel"]:
		var label := root.find_child(name, true, false) as Label
		if label:
			label.add_theme_font_size_override("font_size", 24 if compact else (28 if profile == PROFILE_TALL else 26))
	var settings := root.find_child("SettingsButtonP0", true, false) as Button
	if settings:
		settings.custom_minimum_size = Vector2(88, 88) if compact else Vector2(96, 96)
		ProductionUiBinder.set_icon_max_width(settings, 56)

static func _apply_primary_navigation(root: Control, profile: String, compact: bool) -> void:
	var bottom := root.find_child("BottomMenu", true, false) as HBoxContainer
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	var nav_h := NAV_HEIGHT_SMALL if profile == PROFILE_SMALL else (NAV_HEIGHT_TALL if profile == PROFILE_TALL else NAV_HEIGHT_STANDARD)
	var nav_font := NAV_FONT_SMALL if profile == PROFILE_SMALL else (NAV_FONT_TALL if profile == PROFILE_TALL else NAV_FONT_STANDARD)
	if bottom:
		bottom.custom_minimum_size.y = nav_h
		bottom.add_theme_constant_override("separation", 10)
	if more and bottom and more.get_parent() != bottom:
		more.reparent(bottom, false)
	for old_name in ["Btn_Heroes", "Btn_Attack", "Btn_Defense"]:
		var old := root.find_child(old_name, true, false) as Control
		if old:
			old.visible = false
	var nav_specs := {
		"Btn_Tap": ["TAP", "ui.icon.home"],
		"Btn_Rad": ["SPIN", "ui.icon.spin"],
		"Btn_Dorf": ["DORF", "ui.icon.village"],
		"MoreFeaturesButtonP0": ["MODI", "ui.icon.menu"]
	}
	for node_name in nav_specs.keys():
		var button := root.find_child(node_name, true, false) as Button
		if button == null:
			continue
		button.visible = true
		var prefix := str(nav_specs[node_name][0])
		if not button.text.begins_with(prefix):
			button.text = prefix
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, nav_h - 10.0)
		button.add_theme_font_size_override("font_size", nav_font)
		var icon_tex := SemanticAssetRegistry.texture_for_role(str(nav_specs[node_name][1]), false)
		if icon_tex != null:
			button.icon = icon_tex
			button.expand_icon = true
			ProductionUiBinder.set_icon_max_width(button, 52 if compact else 58)

static func _apply_home_tap(root: Control, profile: String, compact: bool) -> void:
	var title := root.find_child("MonsterLevelLabel", true, false) as Label
	var hp := root.find_child("MonsterHP", true, false) as ProgressBar
	var hp_label := root.find_child("MonsterHPLabel", true, false) as Label
	var monster := root.find_child("MonsterButton", true, false) as Control
	var proximity := root.find_child("BossProximityP0", true, false) as Label
	var progress := root.find_child("MonsterProgressLabel", true, false) as Label
	var region_title := root.find_child("RegionProgressTitle", true, false) as Label
	var region_text := root.find_child("RegionProgressText", true, false) as Label
	var cta := root.find_child("HomeWheelCTA", true, false) as Button
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	var tap_prompt := root.find_child("TapPromptArt", true, false) as Control
	var progress_art := root.find_child("MonsterProgressArt", true, false) as Control
	var upgrade := root.find_child("TapUpgradeButton", true, false) as Control
	var synergy := root.find_child("CoreSynergyLabelV174", true, false) as Label
	var momentum := root.find_child("TapMomentumLabelV172", true, false) as Label
	var assist := root.find_child("HeroAssistLabelV172", true, false) as Label
	if tap_prompt:
		tap_prompt.visible = false
	if progress_art:
		progress_art.visible = false
	if upgrade:
		upgrade.visible = false
	if synergy:
		synergy.visible = false
	if momentum:
		momentum.visible = false
	if assist:
		assist.visible = false
	_set_anchor_rect(title, 0.08, 0.02, 0.92, 0.08)
	_set_anchor_rect(hp, 0.14, 0.085, 0.86, 0.135)
	_set_anchor_rect(hp_label, 0.14, 0.088, 0.86, 0.132)
	_set_anchor_rect(proximity, 0.12, 0.138, 0.88, 0.175)
	_set_anchor_rect(region_title, 0.10, 0.178, 0.90, 0.210)
	_set_anchor_rect(region_text, 0.10, 0.208, 0.90, 0.240)
	_set_anchor_rect(monster, 0.10, 0.24, 0.90, 0.68)
	_set_anchor_rect(hint, 0.12, 0.685, 0.88, 0.725)
	_set_anchor_rect(progress, 0.12, 0.728, 0.88, 0.775)
	_set_anchor_rect(cta, 0.12, 0.785, 0.88, 0.885)
	if title:
		title.add_theme_font_size_override("font_size", 28 if compact else (32 if profile == PROFILE_TALL else 30))
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if hp:
		hp.custom_minimum_size.y = 46.0 if compact else 52.0
	if hp_label:
		hp_label.add_theme_font_size_override("font_size", 20 if compact else 22)
	if proximity:
		proximity.add_theme_font_size_override("font_size", 18 if compact else 20)
		proximity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if region_title:
		region_title.add_theme_font_size_override("font_size", 22 if compact else 24)
		region_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if region_text:
		region_text.add_theme_font_size_override("font_size", 18 if compact else 20)
		region_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if progress:
		progress.add_theme_font_size_override("font_size", 22 if compact else 24)
		progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if cta:
		cta.custom_minimum_size.y = 96.0 if compact else 108.0
		cta.add_theme_font_size_override("font_size", 26 if compact else 28)
	if hint:
		hint.add_theme_font_size_override("font_size", 18 if compact else 20)

static func _apply_spin_reels(root: Control, _profile: String, compact: bool) -> void:
	var view := root.find_child("View_CoinMaster", true, false) as Control
	if view == null:
		return
	var s := view.size
	if s.x <= 1.0 or s.y <= 1.0:
		s = root.get_viewport_rect().size
	var reel_w := clampf(s.x * 0.19, 128.0, 230.0)
	var reel_h := clampf(s.y * 0.30, 260.0, 400.0)
	var gap := clampf(s.x * 0.016, 12.0, 22.0)
	var group_w := reel_w * 3.0 + gap * 2.0
	var left := (s.x - group_w) * 0.5
	var top := clampf(s.y * 0.24, 200.0, 290.0)
	for i in range(3):
		var reel := root.find_child("Reel%d" % (i + 1), true, false) as Control
		if reel:
			reel.set_anchors_preset(Control.PRESET_TOP_LEFT)
			reel.position = Vector2(left + float(i) * (reel_w + gap), top)
			reel.size = Vector2(reel_w, reel_h)
			reel.scale = Vector2.ONE
	var line := root.find_child("Payline", true, false) as Control
	if line:
		line.set_anchors_preset(Control.PRESET_TOP_LEFT)
		line.position = Vector2(left - 14.0, top + reel_h * 0.47)
		line.size = Vector2(group_w + 28.0, clampf(reel_h * 0.085, 26.0, 38.0))
	var win := root.find_child("WinLineLabel", true, false) as Label
	if win:
		win.set_anchors_preset(Control.PRESET_TOP_LEFT)
		win.position = Vector2(left, top + reel_h + 8.0)
		win.size = Vector2(group_w, 48.0)
		win.add_theme_font_size_override("font_size", 18 if compact else 22)
	var machine := root.find_child("SpinMachineFrame", true, false) as Control
	if machine:
		machine.set_anchors_preset(Control.PRESET_TOP_LEFT)
		machine.position = Vector2(left - 58.0, top - 68.0)
		machine.size = Vector2(group_w + 116.0, reel_h + 138.0)
		machine.scale = Vector2.ONE
	var title := root.find_child("WheelTitle", true, false) as Label
	if title:
		title.text = "REALM SPIN"
		title.add_theme_font_size_override("font_size", 30 if compact else 34)
		_set_anchor_rect(title, 0.10, 0.02, 0.90, 0.075)
	var jackpot := root.find_child("JackpotPanel", true, false) as Control
	if jackpot:
		_set_anchor_rect(jackpot, 0.18, 0.08, 0.82, 0.135)
	var status := root.find_child("SpinStatusPanel", true, false) as Control
	if status:
		_set_anchor_rect(status, 0.12, 0.62, 0.88, 0.685)
	var result := root.find_child("WheelResult", true, false) as Label
	if result:
		_set_anchor_rect(result, 0.12, 0.69, 0.88, 0.735)
		result.add_theme_font_size_override("font_size", 24 if compact else 28)
	var button := root.find_child("SpinButton", true, false) as Button
	if button:
		_set_anchor_rect(button, 0.10, 0.755, 0.90, 0.885)
		button.custom_minimum_size.y = 96.0 if compact else 108.0
		button.add_theme_font_size_override("font_size", 28 if compact else 30)

static func _apply_village(root: Control, profile: String, compact: bool) -> void:
	var view := root.find_child("View_ClashDorf", true, false) as Control
	if view == null:
		return
	var title := root.find_child("VillageTitle", true, false) as Label
	var subtitle := root.find_child("VillageSubtitleP0", true, false) as Label
	var growth_label := root.find_child("VillageGrowthLabelV153", true, false) as Label
	var growth := root.find_child("VillageGrowthBarV153", true, false) as ProgressBar
	var ground := root.find_child("VillageGround", true, false) as TextureRect
	var ambient := root.find_child("VillageAmbient", true, false) as TextureRect
	var grid := root.find_child("P0BuildingGrid", true, false) as GridContainer
	var function_row := root.find_child("VillageFunctionRowV153", true, false) as Control
	var prosperity := root.find_child("VillageProsperityClaimV153", true, false) as Button
	var mine_status := root.find_child("GoldmineStatusP0", true, false) as Label
	var mine_claim := root.find_child("GoldmineClaimButtonP0", true, false) as Button
	_set_anchor_rect(title, 0.06, 0.015, 0.94, 0.065)
	_set_anchor_rect(subtitle, 0.08, 0.068, 0.92, 0.105)
	_set_anchor_rect(growth_label, 0.10, 0.108, 0.90, 0.138)
	_set_anchor_rect(growth, 0.12, 0.140, 0.88, 0.168)
	_set_anchor_rect(ground, 0.0, 0.16, 1.0, 0.78)
	_set_anchor_rect(grid, 0.05, 0.20, 0.95, 0.72)
	_set_anchor_rect(function_row, 0.06, 0.735, 0.94, 0.805)
	_set_anchor_rect(prosperity, 0.10, 0.815, 0.90, 0.885)
	_set_anchor_rect(mine_status, 0.10, 0.890, 0.90, 0.925)
	_set_anchor_rect(mine_claim, 0.14, 0.930, 0.86, 0.985)
	if ground:
		var bg := load("res://assets/world/greenvale/BG001_gruenhain_home_v11.png") as Texture2D
		if bg != null:
			ground.texture = bg
		ground.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ground.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		ground.modulate = Color(1, 1, 1, 0.92)
	if ambient:
		ambient.visible = false
	var glow := root.find_child("BuildingSelectGlow", true, false) as Control
	if glow:
		glow.visible = false
	if grid:
		grid.columns = 2
		grid.z_index = 2
		grid.add_theme_constant_override("h_separation", 14 if profile == PROFILE_TALL else 12)
		grid.add_theme_constant_override("v_separation", 14 if profile == PROFILE_TALL else 12)
		for child in grid.get_children():
			if child is Button:
				child.custom_minimum_size = Vector2(0, 280.0 if profile == PROFILE_TALL else (240.0 if compact else 260.0))
				child.add_theme_font_size_override("font_size", 18 if compact else 20)
	if title:
		title.add_theme_font_size_override("font_size", 30 if compact else 32)
	if subtitle:
		subtitle.add_theme_font_size_override("font_size", 18 if compact else 20)
	if prosperity:
		prosperity.custom_minimum_size.y = 80.0
	if mine_claim:
		mine_claim.custom_minimum_size.y = 76.0

static func _apply_mode_views(root: Control, profile: String, compact: bool, vp: Vector2) -> void:
	_apply_puzzle_layout(root, compact)
	_apply_heroes_layout(root, compact, profile)
	_apply_lane_layout(root, compact)
	_apply_td_layout(root, compact)
	_apply_mode_hub_layout(root, compact, vp)

static func _apply_puzzle_layout(root: Control, compact: bool) -> void:
	var panel := root.find_child("PuzzlePanel", true, false) as Control
	if panel:
		_set_anchor_rect(panel, 0.08 if compact else 0.10, 0.22, 0.92 if compact else 0.90, 0.66)
	var grid := root.find_child("PuzzleGrid", true, false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation", 10 if compact else 14)
		grid.add_theme_constant_override("v_separation", 10 if compact else 14)
	for i in range(9):
		var cell := root.find_child("PuzzleCell%d" % i, true, false) as Button
		if cell:
			cell.custom_minimum_size = Vector2(120.0, 108.0) if compact else Vector2(176.0, 148.0)
			cell.add_theme_font_size_override("font_size", 28 if compact else 34)
	for name in ["PuzzleHintLabel", "PuzzleResultLabel", "PuzzleStatusLabel"]:
		var label := root.find_child(name, true, false) as Label
		if label:
			label.add_theme_font_size_override("font_size", 20 if compact else 24)

static func _apply_heroes_layout(root: Control, compact: bool, profile: String) -> void:
	var cards := root.find_child("HeroCards", true, false) as HBoxContainer
	if cards:
		_set_anchor_rect(cards, 0.04, 0.16, 0.96, 0.58)
		cards.add_theme_constant_override("separation", 12 if compact else 16)
	var card_h := 200.0 if compact else (250.0 if profile == PROFILE_TALL else 230.0)
	for name in ["HeroKnight", "HeroArcher", "HeroMage"]:
		var card := root.find_child(name, true, false) as Button
		if card:
			card.custom_minimum_size.y = card_h
			card.add_theme_font_size_override("font_size", 20 if compact else 22)
	for name in ["HeroSpecializationButtonP0", "HeroMasteryClaimP0", "HeroWeaponButton", "HeroCharmButton", "HeroUpgradeButtonP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 76.0)
			button.add_theme_font_size_override("font_size", 19 if compact else 22)
	var dps := root.find_child("AutoDPSLabel", true, false) as Label
	if dps:
		dps.add_theme_font_size_override("font_size", 24 if compact else 28)
	var hero_title := root.find_child("HeroTitle", true, false) as Label
	if hero_title:
		hero_title.add_theme_font_size_override("font_size", 30 if compact else 34)

static func _apply_lane_layout(root: Control, compact: bool) -> void:
	var hud := root.find_child("LaneHUD", true, false) as Control
	if hud:
		_set_anchor_rect(hud, 0.05, 0.02, 0.95, 0.20)
	var buttons := root.find_child("LaneButtons", true, false) as HBoxContainer
	if buttons:
		_set_anchor_rect(buttons, 0.06, 0.84, 0.94, 0.96)
		buttons.add_theme_constant_override("separation", 12 if compact else 18)
	for name in ["LaneLeftButton", "LaneRightButton"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = 108.0 if compact else 124.0
			button.add_theme_font_size_override("font_size", 22 if compact else 26)
	for name in ["LaneLeftUnit", "LaneRightUnit"]:
		var unit := root.find_child(name, true, false) as Control
		if unit and unit.get_parent() is Control:
			var parent := unit.get_parent() as Control
			var pw := parent.size.x
			var ph := parent.size.y
			var uw := clampf(pw * 0.18, 120.0, 180.0)
			var uh := uw
			if name == "LaneLeftUnit":
				unit.set_anchors_preset(Control.PRESET_TOP_LEFT)
				unit.position = Vector2(pw * 0.08, ph * 0.62)
				unit.size = Vector2(uw, uh)
			else:
				unit.set_anchors_preset(Control.PRESET_TOP_LEFT)
				unit.position = Vector2(pw * 0.74, ph * 0.62)
				unit.size = Vector2(uw, uh)

static func _apply_td_layout(root: Control, compact: bool) -> void:
	var hud := root.find_child("TDHUD", true, false) as Control
	if hud:
		_set_anchor_rect(hud, 0.05, 0.02, 0.95, 0.22)
	var view := root.find_child("View_TowerDefense", true, false) as Control
	if view:
		var vw := view.size.x
		var vh := view.size.y
		var tower_a := root.find_child("TowerA", true, false) as Control
		var tower_b := root.find_child("TowerB", true, false) as Control
		var enemy := root.find_child("TDEnemyMarker", true, false) as Control
		var tw := clampf(vw * 0.22, 130.0, 220.0)
		var th := tw
		if tower_a:
			tower_a.set_anchors_preset(Control.PRESET_TOP_LEFT)
			tower_a.position = Vector2(vw * 0.08, vh * 0.34)
			tower_a.size = Vector2(tw, th)
		if tower_b:
			tower_b.set_anchors_preset(Control.PRESET_TOP_LEFT)
			tower_b.position = Vector2(vw * 0.68, vh * 0.48)
			tower_b.size = Vector2(tw, th)
		if enemy:
			enemy.set_anchors_preset(Control.PRESET_TOP_LEFT)
			enemy.position = Vector2(vw * 0.42, vh * 0.12)
			enemy.size = Vector2(tw * 0.85, th * 0.85)
	for name in ["TDBuildButton", "TDFightButton", "TDUpgradeButton"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = 88.0 if compact else 96.0
			button.add_theme_font_size_override("font_size", 20 if compact else 22)

static func _apply_mode_hub_layout(root: Control, compact: bool, vp: Vector2) -> void:
	var overlay := root.find_child("FeatureHubOverlayP0", true, false) as PanelContainer
	if overlay:
		var half_w := minf(480.0, maxf(300.0, vp.x * 0.44))
		var half_h := minf(680.0, maxf(420.0, vp.y * 0.42))
		overlay.offset_left = -half_w
		overlay.offset_right = half_w
		overlay.offset_top = -half_h
		overlay.offset_bottom = half_h
	var grid := root.find_child("FeatureHubGrid", true, false) as GridContainer
	if grid:
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 12 if compact else 16)
		grid.add_theme_constant_override("v_separation", 12 if compact else 16)
	for name in ["HubHeroesP0", "HubJourneyP0", "HubPuzzleP0", "HubDefenseP0", "HubLaneP0", "HubMetaP0", "HubProfileP0", "HubShopP0", "HubLiveOpsP0", "HubProgressionP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = 108.0 if compact else 132.0
			button.add_theme_font_size_override("font_size", 18 if compact else 21)
	var hub_title := root.find_child("FeatureHubOverlayP0", true, false)
	if hub_title:
		var title := hub_title.find_child("Title", true, false) as Label
		if title:
			title.add_theme_font_size_override("font_size", 30 if compact else 34)

static func _apply_overlays(root: Control, profile: String, vp: Vector2) -> void:
	var scale := 0.88 if profile == PROFILE_SMALL else (1.04 if profile == PROFILE_TALL else 1.0)
	var overlay_sizes := {
		"SettingsOverlayP0": Vector2(920, 1040),
		"MonsterRewardOverlay": Vector2(920, 540),
		"WheelRewardOverlayP0": Vector2(880, 560),
		"BuildingUpgradeOverlayP0": Vector2(880, 720),
		"FeatureHubOverlayP0": Vector2(900, 1200),
		"AccountOverlayP0": Vector2(880, 1040),
		"SocialOverlayP0": Vector2(900, 1180),
		"SupportOverlayP0": Vector2(880, 1080),
		"LiveOpsOverlayP0": Vector2(940, 1520),
		"ShopOverlayP0": Vector2(900, 1240),
		"ProgressionOverlayP0": Vector2(900, 1260),
		"AfkOverlayP0": Vector2(820, 700),
		"LevelUpOverlayP0": Vector2(860, 560),
		"RewardModal": Vector2(880, 520)
	}
	for node_name in overlay_sizes.keys():
		var overlay := root.find_child(node_name, true, false) as Control
		if overlay == null:
			continue
		var size: Vector2 = overlay_sizes[node_name] * scale
		size.x = minf(size.x, maxf(320.0, vp.x - 40.0))
		size.y = minf(size.y, maxf(420.0, vp.y - 80.0))
		_center_box(overlay, size)
		_bump_overlay_typography(overlay)

static func _bump_overlay_typography(scope: Node) -> void:
	for child in scope.find_children("*", "Label", true, false):
		var label := child as Label
		if label == null:
			continue
		var current := label.get_theme_font_size("font_size")
		if current < 18:
			label.add_theme_font_size_override("font_size", 18)
	for child in scope.find_children("*", "Button", true, false):
		var button := child as Button
		if button:
			button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 72.0)

static func _hide_legacy_nodes(root: Control) -> void:
	for name in ["TownHallArt", "GoldMineArt", "ForgeArt", "GoldMineLabel", "ForgeLabel", "TownHallButton"]:
		var node := root.find_child(name, true, false) as Control
		if node:
			node.visible = false
	var wheel_title := root.find_child("WheelTitle", true, false) as Label
	if wheel_title:
		wheel_title.text = "REALM SPIN"

static func _set_anchor_rect(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.anchor_left = left
	control.anchor_top = top
	control.anchor_right = right
	control.anchor_bottom = bottom
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0

static func _center_box(control: Control, size: Vector2) -> void:
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.offset_left = -size.x * 0.5
	control.offset_top = -size.y * 0.5
	control.offset_right = size.x * 0.5
	control.offset_bottom = size.y * 0.5
