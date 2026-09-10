extends RefCounted
class_name FullUiConvergenceV197

const VERSION := "v1.97-full-ui-convergence-01"
const PRIMARY_VIEWS := ["View_TapHero","View_CoinMaster","View_ClashDorf","View_RealmJourney","View_Meta","View_Puzzle","View_TowerDefense","View_Heroes","View_LaneAttack","View_Daily","View_Quests"]
const OVERLAYS := ["FeatureHubOverlayP0","SettingsOverlayP0","AccountOverlayP0","SocialOverlayP0","SupportOverlayP0","LiveOpsOverlayP0","ShopOverlayP0","ProgressionOverlayP0","AfkOverlayP0"]

static func apply(root: Control) -> void:
	if root == null:
		return
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	_polish_safe_area(root, compact)
	_polish_views(root, compact)
	_polish_overlays(root, compact, vp)
	_polish_touch_targets(root, compact)
	_polish_copy_readability(root, compact)
	_polish_navigation(root, compact)

static func _polish_safe_area(root: Control, compact: bool) -> void:
	var safe := root.find_child("Safe", true, false) as MarginContainer
	if safe:
		var margin := 14 if compact else 22
		safe.add_theme_constant_override("margin_left", margin)
		safe.add_theme_constant_override("margin_right", margin)
		safe.add_theme_constant_override("margin_top", 10 if compact else 16)
		safe.add_theme_constant_override("margin_bottom", 10 if compact else 16)

static func _polish_views(root: Control, compact: bool) -> void:
	for name in PRIMARY_VIEWS:
		var view := root.find_child(name, true, false) as Control
		if view:
			view.modulate = Color.WHITE
			view.scale = Vector2.ONE
			view.pivot_offset = view.size * 0.5
	for node in root.find_children("*", "VBoxContainer", true, false):
		var box := node as VBoxContainer
		if box and _inside_primary_view(box):
			box.add_theme_constant_override("separation", 8 if compact else 12)
	for node in root.find_children("*", "HBoxContainer", true, false):
		var box := node as HBoxContainer
		if box and _inside_primary_view(box):
			box.add_theme_constant_override("separation", 7 if compact else 11)

static func _polish_overlays(root: Control, compact: bool, vp: Vector2) -> void:
	for name in OVERLAYS:
		var overlay := root.find_child(name, true, false) as Control
		if overlay == null:
			continue
		overlay.pivot_offset = overlay.size * 0.5
		if overlay is PanelContainer:
			var max_w := min(860.0, vp.x - (20.0 if compact else 48.0))
			var max_h := min(1040.0, vp.y - (24.0 if compact else 64.0))
			if overlay.anchor_left == 0.5 and overlay.anchor_right == 0.5:
				overlay.offset_left = -max_w * 0.5
				overlay.offset_right = max_w * 0.5
			if overlay.anchor_top == 0.5 and overlay.anchor_bottom == 0.5:
				overlay.offset_top = -max_h * 0.5
				overlay.offset_bottom = max_h * 0.5

static func _polish_touch_targets(root: Control, compact: bool) -> void:
	for node in root.find_children("*", "Button", true, false):
		var button := node as Button
		if button == null or not _is_game_ui(button):
			continue
		var min_h := 72.0 if compact else 78.0
		if button.name in ["Btn_Tap","Btn_Rad","Btn_Dorf","MoreFeaturesButtonP0"]:
			min_h = 82.0 if compact else 96.0
		button.custom_minimum_size.y = max(button.custom_minimum_size.y, min_h)
		button.add_theme_font_size_override("font_size", max(16, button.get_theme_font_size("font_size")))
		button.pivot_offset = button.size * 0.5

static func _polish_copy_readability(root: Control, compact: bool) -> void:
	for node in root.find_children("*", "Label", true, false):
		var label := node as Label
		if label == null or not _is_game_ui(label):
			continue
		var current := label.get_theme_font_size("font_size")
		if current > 0 and current < 17:
			label.add_theme_font_size_override("font_size", 17 if compact else 18)
		if label.autowrap_mode != TextServer.AUTOWRAP_OFF:
			label.custom_minimum_size.x = 0.0

static func _polish_navigation(root: Control, compact: bool) -> void:
	var menu := root.find_child("BottomMenu", true, false) as HBoxContainer
	if menu:
		menu.add_theme_constant_override("separation", 6 if compact else 10)
	for hidden in ["Btn_Heroes","Btn_Attack","Btn_Defense"]:
		var old := root.find_child(hidden, true, false) as Control
		if old:
			old.visible = false

static func view_enter(root: Control, target: Control, reduced_motion: bool) -> void:
	if root == null or target == null:
		return
	target.modulate = Color.WHITE
	target.scale = Vector2.ONE
	if reduced_motion:
		return
	target.pivot_offset = target.size * 0.5
	target.modulate.a = 0.90
	target.scale = Vector2(1.006, 1.006)
	var t := target.create_tween().set_parallel(true)
	t.tween_property(target, "modulate:a", 1.0, 0.12)
	t.tween_property(target, "scale", Vector2.ONE, 0.14)

static func _inside_primary_view(node: Node) -> bool:
	var p := node
	while p:
		if p.name in PRIMARY_VIEWS:
			return true
		p = p.get_parent()
	return false

static func _is_game_ui(node: Node) -> bool:
	return node != null and not str(node.name).begins_with("Debug")
