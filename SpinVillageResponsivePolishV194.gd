extends RefCounted
class_name SpinVillageResponsivePolishV194

const VERSION := "v1.94-spin-village-responsive-polish-01"

static func apply(root: Control) -> void:
	if root == null:
		return
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	_polish_spin(root, compact)
	_polish_village(root, compact)
	_polish_navigation(root, compact)

static func _polish_spin(root: Control, compact: bool) -> void:
	var view := root.find_child("View_CoinMaster", true, false) as Control
	if view == null:
		return
	var machine := root.find_child("SpinMachineFrame", true, false) as TextureRect
	var status := root.find_child("SpinStatusPanel", true, false) as Control
	var result := root.find_child("WheelResult", true, false) as Label
	var button := root.find_child("SpinButton", true, false) as Button
	var jackpot := root.find_child("JackpotPanel", true, false) as Control
	if compact:
		if machine:
			machine.offset_left = -390.0
			machine.offset_right = 390.0
			machine.offset_top = -355.0
			machine.offset_bottom = 245.0
		if status:
			status.anchor_left = 0.10
			status.anchor_right = 0.90
			status.offset_top = 168.0
			status.offset_bottom = 228.0
		if jackpot:
			jackpot.anchor_left = 0.12
			jackpot.anchor_right = 0.88
			jackpot.offset_top = 82.0
			jackpot.offset_bottom = 160.0
		if result:
			result.add_theme_font_size_override("font_size", 26)
			result.offset_top = -274.0
			result.offset_bottom = -220.0
		if button:
			button.anchor_left = 0.08
			button.anchor_right = 0.92
			button.offset_top = -205.0
			button.offset_bottom = -62.0
			button.add_theme_font_size_override("font_size", 32)
	else:
		if button:
			button.anchor_left = 0.16
			button.anchor_right = 0.84
			button.add_theme_font_size_override("font_size", 36)

static func _polish_village(root: Control, compact: bool) -> void:
	var grid := root.find_child("P0BuildingGrid", true, false) as GridContainer
	if grid:
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 16 if compact else 24)
		grid.add_theme_constant_override("v_separation", 16 if compact else 24)
		grid.anchor_left = 0.04 if compact else 0.07
		grid.anchor_right = 0.96 if compact else 0.93
		grid.anchor_top = 0.24
		grid.anchor_bottom = 0.70
	for name in ["BuildingTownhall","BuildingGoldmine","BuildingForge","BuildingLuck"]:
		var b := root.find_child(name, true, false) as Button
		if b:
			b.custom_minimum_size = Vector2(0.0, 300.0 if compact else 360.0)
			b.add_theme_font_size_override("font_size", 20 if compact else 24)
	for name in ["BuildingTownhallArt","BuildingGoldmineArt","BuildingForgeArt","BuildingLuckArt"]:
		var art := root.find_child(name, true, false) as TextureRect
		if art:
			var half := 112.0 if compact else 138.0
			art.offset_left = -half
			art.offset_top = -half - 16.0
			art.offset_right = half
			art.offset_bottom = half - 16.0
	var ambient := root.find_child("VillageAmbient", true, false) as TextureRect
	if ambient:
		ambient.modulate = Color(1.0,1.0,1.0,0.72)
		if compact:
			ambient.offset_left = 210.0
			ambient.offset_top = 320.0
			ambient.offset_right = 870.0
			ambient.offset_bottom = 650.0
	var row := root.find_child("VillageFunctionRowV153", true, false) as HBoxContainer
	if row:
		row.add_theme_constant_override("separation", 12 if compact else 18)

static func _polish_navigation(root: Control, compact: bool) -> void:
	var menu := root.find_child("BottomMenu", true, false) as HBoxContainer
	if menu:
		menu.add_theme_constant_override("separation", 6 if compact else 10)
	for name in ["Btn_Tap","Btn_Rad","Btn_Dorf","MoreFeaturesButtonP0"]:
		var b := root.find_child(name, true, false) as Button
		if b:
			b.custom_minimum_size.y = 82.0 if compact else 94.0
			b.add_theme_font_size_override("font_size", 17 if compact else 19)

static func spin_begin(root: Control, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var machine := root.find_child("SpinMachineFrame", true, false) as TextureRect
	if machine:
		machine.pivot_offset = machine.size * 0.5
		var tween := machine.create_tween()
		tween.tween_property(machine, "scale", Vector2(1.018,1.018), 0.10)
		tween.tween_property(machine, "scale", Vector2.ONE, 0.16)

static func spin_stop(root: Control, reel_index: int, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var reel := root.find_child("Reel%d" % (reel_index + 1), true, false) as TextureRect
	if reel:
		reel.pivot_offset = reel.size * 0.5
		var tween := reel.create_tween()
		tween.tween_property(reel, "scale", Vector2(1.045,0.97), 0.055)
		tween.tween_property(reel, "scale", Vector2.ONE, 0.10)

static func spin_result(root: Control, special: bool, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var line := root.find_child("Payline", true, false) as TextureRect
	if line:
		line.pivot_offset = line.size * 0.5
		var tween := line.create_tween()
		tween.tween_property(line, "scale", Vector2(1.05,1.16), 0.08)
		tween.tween_property(line, "scale", Vector2.ONE, 0.14)
	var jackpot := root.find_child("JackpotPanel", true, false) as Control
	if special and jackpot:
		jackpot.pivot_offset = jackpot.size * 0.5
		var jt := jackpot.create_tween()
		jt.tween_property(jackpot, "scale", Vector2(1.06,1.06), 0.10)
		jt.tween_property(jackpot, "scale", Vector2.ONE, 0.18)

static func village_refresh(root: Control, reduced_motion: bool) -> void:
	if root == null:
		return
	for name in ["BuildingTownhallArt","BuildingGoldmineArt","BuildingForgeArt","BuildingLuckArt"]:
		var art := root.find_child(name, true, false) as TextureRect
		if art:
			art.modulate = Color.WHITE
	if reduced_motion:
		return
	var bar := root.find_child("VillageGrowthBarV153", true, false) as ProgressBar
	if bar:
		bar.pivot_offset = bar.size * 0.5
