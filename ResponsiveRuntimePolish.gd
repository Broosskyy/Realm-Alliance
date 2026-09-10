extends RefCounted

const VERSION := "v1.67-responsive-runtime-polish-01"
const MIN_TOUCH := 78.0
const PRIMARY_TOUCH := 96.0
const MIN_BODY_FONT := 18
const MIN_SIDE_MARGIN := 18.0

static func apply(root: Control) -> Dictionary:
	if root == null:
		return {"buttons":0,"labels":0,"scrolls":0}
	var viewport := root.get_viewport_rect().size
	var compact := viewport.y < 760.0 or viewport.x < 390.0
	var buttons := _normalize_buttons(root, compact)
	var labels := _normalize_labels(root, compact)
	var scrolls := _normalize_scrolls(root)
	_normalize_overlay_margins(root, viewport, compact)
	_normalize_bottom_navigation(root, viewport, compact)
	return {"buttons":buttons,"labels":labels,"scrolls":scrolls,"compact":compact}

static func _normalize_buttons(root: Control, compact: bool) -> int:
	var count := 0
	for node in root.find_children("*", "Button", true, false):
		var button := node as Button
		if button == null:
			continue
		var target := MIN_TOUCH
		if button.name in ["SpinButton","HomeWheelCTA","TDFightButtonP0","DiceRollButton","HeroUpgradeButtonP0"]:
			target = PRIMARY_TOUCH
		if compact:
			target = maxf(MIN_TOUCH, target - 8.0)
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, target)
		button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"), MIN_BODY_FONT))
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		count += 1
	return count

static func _normalize_labels(root: Control, compact: bool) -> int:
	var count := 0
	for node in root.find_children("*", "Label", true, false):
		var label := node as Label
		if label == null:
			continue
		if label.get_theme_font_size("font_size") < MIN_BODY_FONT:
			label.add_theme_font_size_override("font_size", MIN_BODY_FONT)
		if label.autowrap_mode == TextServer.AUTOWRAP_OFF and label.text.length() > 36:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if compact and label.custom_minimum_size.y > 140.0:
			label.custom_minimum_size.y = maxf(90.0, label.custom_minimum_size.y * 0.82)
		count += 1
	return count

static func _normalize_scrolls(root: Control) -> int:
	var count := 0
	for node in root.find_children("*", "ScrollContainer", true, false):
		var scroll := node as ScrollContainer
		if scroll == null:
			continue
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll.follow_focus = true
		count += 1
	return count

static func _normalize_overlay_margins(root: Control, viewport: Vector2, compact: bool) -> void:
	var overlays := [
		"FeatureHubOverlayP0","SettingsOverlayP0","AccountOverlayP0","SocialOverlayP0",
		"SupportOverlayP0","LiveOpsOverlayP0","ShopOverlayP0","ProgressionOverlayP0","AfkOverlayP0"
	]
	for name in overlays:
		var overlay := root.find_child(name, true, false) as Control
		if overlay == null:
			continue
		overlay.custom_minimum_size.x = minf(overlay.custom_minimum_size.x, maxf(320.0, viewport.x - MIN_SIDE_MARGIN * 2.0))
		if compact:
			overlay.custom_minimum_size.y = minf(overlay.custom_minimum_size.y, viewport.y * 0.88)

static func _normalize_bottom_navigation(root: Control, viewport: Vector2, compact: bool) -> void:
	var menu := root.find_child("BottomMenu", true, false) as Control
	if menu == null:
		return
	var target := 88.0 if compact else 96.0
	menu.custom_minimum_size.y = maxf(menu.custom_minimum_size.y, target)
	for name in ["Btn_Tap","Btn_Rad","Btn_Dorf","MoreFeaturesButtonP0"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, target)
			button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"), 18))
