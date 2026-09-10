extends Node

const CALIBRATION_VERSION := "v1.62-full-ui-convergence-01"
const BODY_FONT := 18
const SECONDARY_FONT := 20
const PRIMARY_FONT := 24
const SCREEN_TITLE_FONT := 30
const TOUCH_MIN := 78.0
const PRIMARY_TOUCH := 100.0

func apply(root: Control) -> void:
	if root == null:
		return
	_calibrate_primary_mode_access(root)
	_calibrate_home_tap(root)
	_calibrate_spin(root)
	_calibrate_village(root)
	_calibrate_feature_hub(root)
	_calibrate_quest_screen(root)
	for pair in [["ShopVBox",18],["ProgressionVBox",18],["AfkVBox",18],["LiveOpsVBox",14],["AccountVBox",16],["SocialVBox",16],["SupportVBox",16]]:
		_calibrate_overlay_stack(root, str(pair[0]), int(pair[1]))
	_calibrate_bottom_navigation(root)

func _calibrate_primary_mode_access(root: Control) -> void:
	for name in ["DailyButton","HeroesGameButton","LaneBattleButton","DefenseGameButton","PuzzleButton","MetaButton","JourneyButton","QuestButton"]:
		var button := root.find_child(name, true, false) as Button
		if button: button.visible = false
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	if more:
		more.visible = true
		more.text = "MODI"
		more.custom_minimum_size = Vector2(180,78)
		more.add_theme_font_size_override("font_size",22)

func _calibrate_home_tap(root: Control) -> void:
	var monster := root.find_child("MonsterButton", true, false) as Control
	var monster_title := root.find_child("MonsterLevelLabel", true, false) as Label
	var hp := root.find_child("MonsterHP", true, false) as ProgressBar
	var hp_label := root.find_child("MonsterHPLabel", true, false) as Label
	var progress := root.find_child("MonsterProgressLabel", true, false) as Label
	var spin_cta := root.find_child("HomeWheelCTA", true, false) as Button
	for art_name in ["TapPromptArt","MonsterProgressArt"]:
		var art := root.find_child(art_name, true, false) as CanvasItem
		if art: art.visible = false
	var first_hint := root.find_child("FirstSessionHintP0", true, false) as Label
	if monster: monster.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if first_hint:
		first_hint.add_theme_font_size_override("font_size", maxi(first_hint.get_theme_font_size("font_size"),24))
		first_hint.modulate = Color(1.0,0.96,0.80,0.96)
	if monster_title:
		monster_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		monster_title.add_theme_font_size_override("font_size", maxi(monster_title.get_theme_font_size("font_size"),28))
	if hp: hp.custom_minimum_size.y = maxf(hp.custom_minimum_size.y,52.0)
	if hp_label:
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.add_theme_font_size_override("font_size", maxi(hp_label.get_theme_font_size("font_size"),20))
	if progress:
		progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		progress.add_theme_font_size_override("font_size", maxi(progress.get_theme_font_size("font_size"),20))
	if spin_cta:
		spin_cta.custom_minimum_size.y = maxf(spin_cta.custom_minimum_size.y,PRIMARY_TOUCH)
		spin_cta.add_theme_font_size_override("font_size", maxi(spin_cta.get_theme_font_size("font_size"),PRIMARY_FONT))

func _calibrate_spin(root: Control) -> void:
	for name in ["SpinStatusPanel","NoSpinsPanel"]:
		var panel := root.find_child(name,true,false) as Control
		if panel: panel.custom_minimum_size.y = maxf(panel.custom_minimum_size.y,88.0)
	for name in ["SpinStatusLabel","JackpotLabel","WinLineLabel"]:
		var label := root.find_child(name,true,false) as Label
		if label:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", maxi(label.get_theme_font_size("font_size"),18 if name=="WinLineLabel" else 20))
	var spin_button := root.find_child("SpinButton",true,false) as Button
	if spin_button:
		spin_button.custom_minimum_size.y = maxf(spin_button.custom_minimum_size.y,112.0)
		spin_button.add_theme_font_size_override("font_size", maxi(spin_button.get_theme_font_size("font_size"),26))

func _calibrate_village(root: Control) -> void:
	var grid := root.find_child("P0BuildingGrid",true,false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation",18)
		grid.add_theme_constant_override("v_separation",18)
		for child in grid.get_children():
			if child is Button:
				var button := child as Button
				button.custom_minimum_size.y = maxf(button.custom_minimum_size.y,210.0)
				button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"),18))
	for name in ["VillageForgeActionV153","VillageTempleActionV153","VillageProsperityClaimV153"]:
		var node := root.find_child(name,true,false) as Button
		if node: node.custom_minimum_size.y = maxf(node.custom_minimum_size.y,88.0)

func _calibrate_feature_hub(root: Control) -> void:
	var grid := root.find_child("FeatureHubGrid",true,false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation",14)
		grid.add_theme_constant_override("v_separation",14)
		for child in grid.get_children():
			if child is Button:
				var button := child as Button
				button.custom_minimum_size.y = maxf(button.custom_minimum_size.y,112.0)
				button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"),SECONDARY_FONT))
	for name in ["FeatureHubSubtitleP0","FeatureHubHintP0"]:
		var label := root.find_child(name,true,false) as Label
		if label:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _calibrate_quest_screen(root: Control) -> void:
	var list := root.find_child("QuestList",true,false) as VBoxContainer
	if list: list.add_theme_constant_override("separation",14)
	var summary := root.find_child("QuestSummaryLabel",true,false) as Label
	if summary:
		summary.custom_minimum_size.y = maxf(summary.custom_minimum_size.y,112.0)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.add_theme_font_size_override("font_size", maxi(summary.get_theme_font_size("font_size"),19))

func _calibrate_overlay_stack(root: Control, name: String, separation: int) -> void:
	var box := root.find_child(name,true,false) as VBoxContainer
	if box == null: return
	box.add_theme_constant_override("separation",separation)
	for child in box.get_children():
		if child is Label:
			var label := child as Label
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			if label.name.to_lower().contains("title") or label.name == "Title":
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.add_theme_font_size_override("font_size", maxi(label.get_theme_font_size("font_size"),SCREEN_TITLE_FONT))
		elif child is Button:
			var button := child as Button
			button.custom_minimum_size.y = maxf(button.custom_minimum_size.y,TOUCH_MIN)
			button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"),SECONDARY_FONT))

func _calibrate_bottom_navigation(root: Control) -> void:
	var bottom := root.find_child("BottomMenu",true,false)
	if bottom and bottom is Container: (bottom as Container).add_theme_constant_override("separation",10)
	for name in ["Btn_Tap","Btn_Rad","Btn_Dorf","MoreFeaturesButtonP0"]:
		var node := root.find_child(name,true,false) as Button
		if node:
			node.custom_minimum_size.y = maxf(node.custom_minimum_size.y,96.0)
			node.add_theme_font_size_override("font_size", maxi(node.get_theme_font_size("font_size"),20))
