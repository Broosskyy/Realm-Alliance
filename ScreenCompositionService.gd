extends Node

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

const COMPOSITION_VERSION := "v1.61-screen-composition-01"
const PRIMARY_NAV_HEIGHT := 118.0
const PRIMARY_NAV_FONT := 21

func apply(root: Control) -> void:
	# V2.01: all geometry and navigation owned by MobileLayoutOwner via ResponsiveLayout.
	pass

func _compose_primary_navigation(root: Control) -> void:
	var quick := root.find_child("QuickActions", true, false) as Control
	var bottom := root.find_child("BottomMenu", true, false) as HBoxContainer
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	if quick:
		quick.visible = false
	if bottom:
		bottom.custom_minimum_size.y = PRIMARY_NAV_HEIGHT
		bottom.add_theme_constant_override("separation", 8)
	if more and bottom and more.get_parent() != bottom:
		more.reparent(bottom, false)
	if more:
		more.visible = true
		more.text = "MODI"
		more.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		more.custom_minimum_size = Vector2(0, PRIMARY_NAV_HEIGHT - 8.0)
		more.add_theme_font_size_override("font_size", PRIMARY_NAV_FONT)
		more.icon = SemanticAssetRegistry.texture_for_role("ui.icon.menu", false)
		more.expand_icon = true
		ProductionUiBinder.set_icon_max_width(more, 58)

	var nav_specs := {
		"Btn_Tap": ["TAP", "ui.icon.home"],
		"Btn_Rad": ["SPIN", "ui.icon.spin"],
		"Btn_Dorf": ["DORF", "ui.icon.village"]
	}
	for node_name in nav_specs.keys():
		var button := root.find_child(node_name, true, false) as Button
		if button == null:
			continue
		button.visible = true
		button.text = str(nav_specs[node_name][0])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, PRIMARY_NAV_HEIGHT - 8.0)
		button.add_theme_font_size_override("font_size", PRIMARY_NAV_FONT)
		var icon_tex := SemanticAssetRegistry.texture_for_role(str(nav_specs[node_name][1]), false)
		if icon_tex != null:
			button.icon = icon_tex
		button.expand_icon = true
		ProductionUiBinder.set_icon_max_width(button, 58)
	for old_name in ["Btn_Heroes","Btn_Attack","Btn_Defense"]:
		var old := root.find_child(old_name, true, false) as Control
		if old:
			old.visible = false

func _compose_home(root: Control) -> void:
	var view := root.find_child("View_TapHero", true, false) as Control
	if view == null:
		return
	var title := root.find_child("MonsterLevelLabel", true, false) as Label
	var hp := root.find_child("MonsterHP", true, false) as ProgressBar
	var hp_label := root.find_child("MonsterHPLabel", true, false) as Label
	var monster := root.find_child("MonsterButton", true, false) as Control
	var hit := root.find_child("MonsterHitOverlay", true, false) as Control
	var reward_burst := root.find_child("RewardBurst", true, false) as Control
	var progress := root.find_child("MonsterProgressLabel", true, false) as Label
	var proximity := root.find_child("BossProximityP0", true, false) as Label
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	var tap_prompt_art := root.find_child("TapPromptArt", true, false) as Control
	var progress_art := root.find_child("MonsterProgressArt", true, false) as Control
	var cta := root.find_child("HomeWheelCTA", true, false) as Button
	var reward := root.find_child("RewardLabel", true, false) as Label
	var upgrade := root.find_child("TapUpgradeButton", true, false) as Button
	if tap_prompt_art: tap_prompt_art.visible = false
	if progress_art: progress_art.visible = false
	if upgrade: upgrade.visible = false
	_set_rect(title, 0.10, 0.025, 0.90, 0.085)
	_set_rect(hp, 0.18, 0.095, 0.82, 0.145)
	_set_rect(hp_label, 0.18, 0.098, 0.82, 0.143)
	_set_rect(proximity, 0.18, 0.150, 0.82, 0.190)
	_set_rect(monster, 0.12, 0.205, 0.88, 0.680)
	_set_rect(hit, 0.12, 0.205, 0.88, 0.680)
	_set_rect(reward_burst, 0.23, 0.300, 0.77, 0.625)
	_set_rect(hint, 0.18, 0.665, 0.82, 0.710)
	_set_rect(progress, 0.18, 0.715, 0.82, 0.770)
	_set_rect(cta, 0.14, 0.790, 0.86, 0.895)
	_set_rect(reward, 0.14, 0.900, 0.86, 0.950)
	if title:
		title.add_theme_font_size_override("font_size", 30)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if hp:
		hp.custom_minimum_size.y = 48.0
	if hp_label:
		hp_label.add_theme_font_size_override("font_size", 20)
	if progress:
		progress.add_theme_font_size_override("font_size", 23)
		progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ProductionUiBinder.apply_backdrop(progress, "ui.home.boss_progress", false, 0.18)
	if hint:
		hint.add_theme_font_size_override("font_size", 20)
		hint.modulate = Color(1.0,0.96,0.82,0.94)
	if cta:
		cta.custom_minimum_size.y = 104.0
		cta.add_theme_font_size_override("font_size", 28)
		ProductionUiBinder.apply_backdrop(cta, "ui.button.spin.primary", false, 0.20, true)

func _compose_spin(root: Control) -> void:
	var title := root.find_child("WheelTitle", true, false) as Label
	var jackpot := root.find_child("JackpotPanel", true, false) as Control
	var machine := root.find_child("SpinMachineFrame", true, false) as TextureRect
	var reel1 := root.find_child("Reel1", true, false) as Control
	var reel2 := root.find_child("Reel2", true, false) as Control
	var reel3 := root.find_child("Reel3", true, false) as Control
	var payline := root.find_child("Payline", true, false) as Control
	var win_line := root.find_child("WinLineLabel", true, false) as Label
	var status := root.find_child("SpinStatusPanel", true, false) as Control
	var result := root.find_child("WheelResult", true, false) as Label
	var button := root.find_child("SpinButton", true, false) as Button
	_set_rect(title, 0.12, 0.025, 0.88, 0.080)
	_set_rect(jackpot, 0.20, 0.090, 0.80, 0.145)
	_set_rect(machine, 0.055, 0.165, 0.945, 0.665)
	_set_rect(reel1, 0.170, 0.260, 0.355, 0.555)
	_set_rect(reel2, 0.407, 0.260, 0.592, 0.555)
	_set_rect(reel3, 0.645, 0.260, 0.830, 0.555)
	_set_rect(payline, 0.125, 0.418, 0.875, 0.455)
	_set_rect(win_line, 0.18, 0.575, 0.82, 0.615)
	_set_rect(status, 0.16, 0.635, 0.84, 0.700)
	_set_rect(result, 0.14, 0.710, 0.86, 0.760)
	_set_rect(button, 0.13, 0.790, 0.87, 0.900)
	if machine:
		ProductionUiBinder.apply_texture(machine, "spin.machine.frame", false)
	if button:
		button.custom_minimum_size.y = 112.0
		button.add_theme_font_size_override("font_size", 30)
	if title:
		title.add_theme_font_size_override("font_size", 34)
	if win_line:
		win_line.add_theme_font_size_override("font_size", 18)

func _compose_village(root: Control) -> void:
	var title := root.find_child("VillageTitle", true, false) as Label
	var subtitle := root.find_child("VillageSubtitleP0", true, false) as Label
	var growth_label := root.find_child("VillageGrowthLabelV153", true, false) as Label
	var growth := root.find_child("VillageGrowthBarV153", true, false) as ProgressBar
	var ground := root.find_child("VillageGround", true, false) as Control
	var ambient := root.find_child("VillageAmbient", true, false) as Control
	var grid := root.find_child("P0BuildingGrid", true, false) as GridContainer
	var function_row := root.find_child("VillageFunctionRowV153", true, false) as HBoxContainer
	var prosperity := root.find_child("VillageProsperityClaimV153", true, false) as Button
	var mine_status := root.find_child("GoldmineStatusP0", true, false) as Label
	var mine_claim := root.find_child("GoldmineClaimButtonP0", true, false) as Button
	_set_rect(title, 0.08, 0.020, 0.92, 0.075)
	_set_rect(subtitle, 0.10, 0.078, 0.90, 0.115)
	_set_rect(growth_label, 0.14, 0.118, 0.86, 0.150)
	_set_rect(growth, 0.18, 0.152, 0.82, 0.180)
	_set_rect(ground, 0.03, 0.185, 0.97, 0.760)
	_set_rect(ambient, 0.23, 0.235, 0.77, 0.420)
	_set_rect(grid, 0.06, 0.235, 0.94, 0.690)
	_set_rect(function_row, 0.07, 0.705, 0.93, 0.775)
	_set_rect(prosperity, 0.12, 0.790, 0.88, 0.860)
	_set_rect(mine_status, 0.12, 0.865, 0.88, 0.900)
	_set_rect(mine_claim, 0.18, 0.905, 0.82, 0.965)
	if grid:
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 14)
		for child in grid.get_children():
			if child is Button:
				_prepare_building_button(child as Button)
	if title:
		title.add_theme_font_size_override("font_size", 32)
	if subtitle:
		subtitle.add_theme_font_size_override("font_size", 18)
	if growth:
		growth.custom_minimum_size.y = 30.0
	if prosperity:
		prosperity.custom_minimum_size.y = 78.0
	if mine_claim:
		mine_claim.custom_minimum_size.y = 72.0

func _prepare_building_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0, 260)
	button.clip_contents = true
	button.add_theme_font_size_override("font_size", 18)
	var label := button.get_node_or_null("RuntimeLabelV161") as Label
	if label == null:
		label = Label.new()
		label.name = "RuntimeLabelV161"
		label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		label.offset_left = 12
		label.offset_right = -12
		label.offset_top = -82
		label.offset_bottom = -10
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1.0,0.98,0.92,1.0))
		label.add_theme_color_override("font_outline_color", Color(0.02,0.03,0.05,0.96))
		label.add_theme_constant_override("outline_size", 5)
		button.add_child(label)

func set_building_label(button: Button, text: String) -> void:
	var label := button.get_node_or_null("RuntimeLabelV161") as Label
	if label:
		label.text = text
		button.text = ""
	else:
		button.text = text

func _set_rect(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	if control == null:
		return
	control.anchor_left = left
	control.anchor_top = top
	control.anchor_right = right
	control.anchor_bottom = bottom
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0
