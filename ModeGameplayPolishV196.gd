extends RefCounted
class_name ModeGameplayPolishV196

const VERSION := "v1.96-mode-gameplay-polish-01"

static func apply(root: Control) -> void:
	if root == null:
		return
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	_polish_puzzle(root, compact)
	_polish_heroes(root, compact)
	_polish_lane(root, compact)
	_polish_mode_hub(root, compact, vp)

static func _polish_puzzle(root: Control, compact: bool) -> void:
	var panel := root.find_child("PuzzlePanel", true, false) as Control
	if panel:
		panel.anchor_left = 0.08 if compact else 0.10
		panel.anchor_right = 0.92 if compact else 0.90
		panel.anchor_top = 0.24 if compact else 0.23
		panel.anchor_bottom = 0.66 if compact else 0.65
	var grid := root.find_child("PuzzleGrid", true, false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation", 8 if compact else 14)
		grid.add_theme_constant_override("v_separation", 8 if compact else 14)
	for i in range(9):
		var cell := root.find_child("PuzzleCell%d" % i, true, false) as Button
		if cell:
			cell.custom_minimum_size = Vector2(112.0, 100.0) if compact else Vector2(168.0, 138.0)
			cell.add_theme_font_size_override("font_size", 26 if compact else 32)
			cell.pivot_offset = cell.size * 0.5
	var hint := root.find_child("PuzzleHintLabel", true, false) as Label
	if hint:
		hint.add_theme_font_size_override("font_size", 19 if compact else 23)
	var result := root.find_child("PuzzleResultLabel", true, false) as Label
	if result:
		result.add_theme_font_size_override("font_size", 20 if compact else 25)

static func _polish_heroes(root: Control, compact: bool) -> void:
	var cards := root.find_child("HeroCards", true, false) as HBoxContainer
	if cards:
		cards.anchor_left = 0.035 if compact else 0.05
		cards.anchor_right = 0.965 if compact else 0.95
		cards.add_theme_constant_override("separation", 8 if compact else 16)
	for name in ["HeroKnight", "HeroArcher", "HeroMage"]:
		var card := root.find_child(name, true, false) as Button
		if card:
			card.custom_minimum_size.y = 190.0 if compact else 235.0
			card.add_theme_font_size_override("font_size", 18 if compact else 22)
			card.pivot_offset = card.size * 0.5
	for name in ["HeroSpecializationButtonP0", "HeroMasteryClaimP0", "HeroWeaponButton", "HeroCharmButton", "HeroUpgradeButtonP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.add_theme_font_size_override("font_size", 17 if compact else 21)
	var dps := root.find_child("AutoDPSLabel", true, false) as Label
	if dps:
		dps.add_theme_font_size_override("font_size", 22 if compact else 27)

static func _polish_lane(root: Control, compact: bool) -> void:
	var hud := root.find_child("LaneHUD", true, false) as VBoxContainer
	if hud:
		hud.anchor_left = 0.04 if compact else 0.07
		hud.anchor_right = 0.96 if compact else 0.93
	var buttons := root.find_child("LaneButtons", true, false) as HBoxContainer
	if buttons:
		buttons.anchor_left = 0.055 if compact else 0.09
		buttons.anchor_right = 0.945 if compact else 0.91
		buttons.add_theme_constant_override("separation", 10 if compact else 18)
	for name in ["LaneLeftButton", "LaneRightButton"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = 104.0 if compact else 124.0
			button.add_theme_font_size_override("font_size", 21 if compact else 26)
			button.pivot_offset = button.size * 0.5
	for name in ["LaneTechButtonP0", "LaneMasteryClaimP0", "LaneNextBattleP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.add_theme_font_size_override("font_size", 17 if compact else 20)

static func _polish_mode_hub(root: Control, compact: bool, vp: Vector2) -> void:
	var overlay := root.find_child("FeatureHubOverlayP0", true, false) as PanelContainer
	if overlay:
		var half_w := min(440.0, max(160.0, vp.x * 0.46))
		var half_h := min(610.0, max(280.0, vp.y * 0.45))
		overlay.offset_left = -half_w
		overlay.offset_right = half_w
		overlay.offset_top = -half_h
		overlay.offset_bottom = half_h
		overlay.pivot_offset = overlay.size * 0.5
	var grid := root.find_child("FeatureHubGrid", true, false) as GridContainer
	if grid:
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 8 if compact else 14)
		grid.add_theme_constant_override("v_separation", 8 if compact else 14)
	for name in ["HubHeroesP0","HubJourneyP0","HubPuzzleP0","HubDefenseP0","HubLaneP0","HubMetaP0","HubProfileP0","HubShopP0","HubLiveOpsP0","HubProgressionP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = 96.0 if compact else 124.0
			button.add_theme_font_size_override("font_size", 16 if compact else 19)
			button.pivot_offset = button.size * 0.5
	var title := root.find_child("Title", true, false) as Label
	if title and title.get_parent() and title.get_parent().name == "FeatureHubVBox":
		title.add_theme_font_size_override("font_size", 30 if compact else 38)

static func puzzle_feedback(root: Control, index: int, matched: bool, completed: bool, reduced_motion: bool) -> void:
	if root == null:
		return
	var cell := root.find_child("PuzzleCell%d" % index, true, false) as Button
	if cell and not reduced_motion:
		cell.pivot_offset = cell.size * 0.5
		var t := cell.create_tween()
		t.tween_property(cell, "scale", Vector2(1.06, 1.06), 0.07)
		t.tween_property(cell, "scale", Vector2.ONE, 0.10)
	if matched:
		var result := root.find_child("PuzzleResultLabel", true, false) as Label
		if result and not reduced_motion:
			result.pivot_offset = result.size * 0.5
			var rt := result.create_tween()
			rt.tween_property(result, "scale", Vector2(1.035,1.035), 0.08)
			rt.tween_property(result, "scale", Vector2.ONE, 0.13)
		for i in range(9):
			var c := root.find_child("PuzzleCell%d" % i, true, false) as Button
			if c:
				c.modulate = Color(1.0, 0.97, 0.78, 1.0)
				var ct := c.create_tween()
				ct.tween_property(c, "modulate", Color.WHITE, 0.20 if completed else 0.14)

static func hero_selected(root: Control, hero_id: String, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var map := {"knight":"HeroKnight", "archer":"HeroArcher", "mage":"HeroMage"}
	var button := root.find_child(str(map.get(hero_id, "")), true, false) as Button
	if button:
		button.pivot_offset = button.size * 0.5
		var t := button.create_tween()
		t.tween_property(button, "scale", Vector2(1.045,1.045), 0.08)
		t.tween_property(button, "scale", Vector2.ONE, 0.13)

static func hero_upgrade_feedback(root: Control, hero_id: String, success: bool, reduced_motion: bool) -> void:
	if root == null or not success:
		return
	hero_selected(root, hero_id, reduced_motion)
	var bar := root.find_child("HeroMasteryBarP0", true, false) as ProgressBar
	if bar and not reduced_motion:
		bar.pivot_offset = bar.size * 0.5
		var t := bar.create_tween()
		t.tween_property(bar, "scale", Vector2(1.0,1.08), 0.08)
		t.tween_property(bar, "scale", Vector2.ONE, 0.12)

static func lane_layout(root: Control, state: Dictionary) -> void:
	if root == null:
		return
	var view := root.find_child("View_LaneAttack", true, false) as Control
	if view == null:
		return
	var size := view.size
	if size.x <= 1.0 or size.y <= 1.0:
		size = root.get_viewport_rect().size
	var unit_size := 132.0 if size.x < 620.0 else 160.0
	var left := root.find_child("LaneLeftUnit", true, false) as TextureRect
	var right := root.find_child("LaneRightUnit", true, false) as TextureRect
	var push: Array = state.get("lane_push", [0.0,0.0])
	var p0 := clamp(float(push[0]), 0.0, 1.0) if push.size() > 0 else 0.0
	var p1 := clamp(float(push[1]), 0.0, 1.0) if push.size() > 1 else 0.0
	var start_y := size.y * 0.77
	var end_y := size.y * 0.27
	if left:
		left.size = Vector2(unit_size, unit_size)
		left.position = Vector2(size.x * 0.28 - unit_size * 0.5, lerp(start_y, end_y, p0))
	if right:
		right.size = Vector2(unit_size, unit_size)
		right.position = Vector2(size.x * 0.72 - unit_size * 0.5, lerp(start_y, end_y, p1))

static func lane_deploy_feedback(root: Control, lane_index: int, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var unit_name := "LaneLeftUnit" if lane_index == 0 else "LaneRightUnit"
	var button_name := "LaneLeftButton" if lane_index == 0 else "LaneRightButton"
	var unit := root.find_child(unit_name, true, false) as Control
	var button := root.find_child(button_name, true, false) as Button
	if unit:
		unit.pivot_offset = unit.size * 0.5
		var ut := unit.create_tween()
		ut.tween_property(unit, "scale", Vector2(1.10,1.10), 0.07)
		ut.tween_property(unit, "scale", Vector2.ONE, 0.12)
	if button:
		button.pivot_offset = button.size * 0.5
		var bt := button.create_tween()
		bt.tween_property(button, "scale", Vector2(0.97,0.97), 0.05)
		bt.tween_property(button, "scale", Vector2.ONE, 0.09)

static func lane_result_feedback(root: Control, won: bool, reduced_motion: bool) -> void:
	if root == null:
		return
	var label := root.find_child("LaneResult", true, false) as Label
	if label:
		label.modulate = Color(1.0, 0.94, 0.68, 1.0) if won else Color(1.0, 0.82, 0.82, 1.0)
		var ft := label.create_tween()
		ft.tween_property(label, "modulate", Color.WHITE, 0.28)
		if not reduced_motion:
			label.pivot_offset = label.size * 0.5
			var st := label.create_tween()
			st.tween_property(label, "scale", Vector2(1.04,1.04), 0.08)
			st.tween_property(label, "scale", Vector2.ONE, 0.14)

static func mode_hub_open(root: Control, reduced_motion: bool) -> void:
	if root == null:
		return
	var overlay := root.find_child("FeatureHubOverlayP0", true, false) as PanelContainer
	if overlay == null:
		return
	overlay.modulate = Color.WHITE
	overlay.scale = Vector2.ONE
	if reduced_motion:
		return
	overlay.pivot_offset = overlay.size * 0.5
	overlay.modulate.a = 0.90
	overlay.scale = Vector2(0.985,0.985)
	var t := overlay.create_tween().set_parallel(true)
	t.tween_property(overlay, "modulate:a", 1.0, 0.14)
	t.tween_property(overlay, "scale", Vector2.ONE, 0.16)
