extends RefCounted
class_name FinalAlphaConvergenceV200

const VERSION := "v2.00-alpha-vertical-slice-01"

static func validate_and_reset(root: Control) -> void:
	_reset_transient_visuals(root)
	_validate_assets_once()

static func _fix_spin_geometry(root: Control) -> void:
	var view := root.find_child("View_CoinMaster", true, false) as Control
	if view == null: return
	var s := view.size
	if s.x <= 1.0 or s.y <= 1.0: return
	var compact := s.x < 700.0 or s.y < 900.0
	var reel_w := clamp(s.x * 0.18, 118.0, 220.0)
	var reel_h := clamp(s.y * 0.34, 250.0, 390.0)
	var gap := clamp(s.x * 0.018, 10.0, 24.0)
	var group_w := reel_w * 3.0 + gap * 2.0
	var left := (s.x - group_w) * 0.5
	var top := clamp(s.y * 0.27, 210.0, 310.0)
	for i in range(3):
		var reel := root.find_child("Reel%d" % (i + 1), true, false) as TextureRect
		if reel:
			reel.position = Vector2(left + i * (reel_w + gap), top)
			reel.size = Vector2(reel_w, reel_h)
			reel.scale = Vector2.ONE
	var line := root.find_child("Payline", true, false) as TextureRect
	if line:
		line.position = Vector2(left - 12.0, top + reel_h * 0.47)
		line.size = Vector2(group_w + 24.0, clamp(reel_h * 0.085, 24.0, 36.0))
	var win := root.find_child("WinLineLabel", true, false) as Label
	if win:
		win.position = Vector2(left, top + reel_h + 10.0)
		win.size = Vector2(group_w, 46.0)
		win.add_theme_font_size_override("font_size", 18 if compact else 22)
	var machine := root.find_child("SpinMachineFrame", true, false) as TextureRect
	if machine:
		machine.set_anchors_preset(Control.PRESET_CENTER)
		machine.position = Vector2(left - 55.0, top - 65.0)
		machine.size = Vector2(group_w + 110.0, reel_h + 135.0)
		machine.scale = Vector2.ONE
	var result := root.find_child("WheelResult", true, false) as Label
	if result: result.add_theme_font_size_override("font_size", 25 if compact else 30)

static func _fix_village_geometry(root: Control) -> void:
	var view := root.find_child("View_ClashDorf", true, false) as Control
	if view == null: return
	var ambient := root.find_child("VillageAmbient", true, false) as TextureRect
	if ambient:
		ambient.set_anchors_preset(Control.PRESET_CENTER)
		var w := clamp(view.size.x * 0.55, 300.0, 620.0)
		var h := w * 0.52
		ambient.position = Vector2((view.size.x-w)*0.5, view.size.y*0.30)
		ambient.size = Vector2(w,h)
		ambient.modulate = Color(1,1,1,0.58)
		ambient.z_index = 0
	var grid := root.find_child("P0BuildingGrid", true, false) as GridContainer
	if grid: grid.z_index = 2
	var glow := root.find_child("BuildingSelectGlow", true, false) as TextureRect
	if glow: glow.z_index = 3

static func _reset_transient_visuals(root: Control) -> void:
	var monster := root.find_child("MonsterButton", true, false) as Control
	if monster:
		monster.modulate = Color.WHITE
		monster.rotation = 0.0
		if monster.scale.x < 0.75 or monster.scale.y < 0.75: monster.scale = Vector2.ONE

static func _enforce_primary_nav(root: Control) -> void:
	for old_name in ["Btn_Heroes","Btn_Attack","Btn_Defense"]:
		var old := root.find_child(old_name,true,false) as Control
		if old: old.visible = false
	for pair in [["Btn_Tap","TAP"],["Btn_Rad","SPIN"],["Btn_Dorf","DORF"],["MoreFeaturesButtonP0","MODI"]]:
		var b := root.find_child(str(pair[0]),true,false) as Button
		if b:
			if not b.text.begins_with(str(pair[1])): b.text = str(pair[1])
			b.custom_minimum_size.y = max(b.custom_minimum_size.y, 82.0)

static func _validate_assets_once() -> void:
	if not Engine.is_editor_hint():
		var r := ProductionAssetRegistry.validate_registry()
		var b := ProductionAssetRegistry.validate_bindings()
		if not bool(r.get("ok",false)): push_warning("V2.00 registry missing: %s" % str(r.get("missing",[])))
		if not bool(b.get("ok",false)): push_warning("V2.00 bindings missing: %s" % str(b.get("missing",[])))
