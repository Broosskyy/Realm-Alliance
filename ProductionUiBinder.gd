extends RefCounted

const ART_PREFIX := "__ProductionArt_"

static func apply_backdrop(control: Control, role_id: String, allow_medium := true, patch_ratio := 0.16, clear_native_background := false) -> bool:
	if control == null:
		return false
	var texture := AssetRegistry.production_texture_for(role_id, allow_medium)
	if texture == null:
		return false
	var node_name := ART_PREFIX + "background"
	var art := control.get_node_or_null(node_name) as NinePatchRect
	if art == null:
		art = NinePatchRect.new()
		art.name = node_name
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.show_behind_parent = true
		art.z_index = -1
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.add_child(art)
		control.move_child(art, 0)
	art.texture = texture
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var source_size := texture.get_size()
	var patch_x := maxi(8, int(source_size.x * clampf(patch_ratio, 0.05, 0.30)))
	var patch_y := maxi(8, int(source_size.y * clampf(patch_ratio, 0.05, 0.30)))
	art.set_patch_margin(SIDE_LEFT, patch_x)
	art.set_patch_margin(SIDE_RIGHT, patch_x)
	art.set_patch_margin(SIDE_TOP, patch_y)
	art.set_patch_margin(SIDE_BOTTOM, patch_y)
	if clear_native_background:
		_clear_native_background(control)
	return true

static func apply_texture(control: TextureRect, role_id: String, allow_medium := true) -> bool:
	if control == null:
		return false
	var texture := AssetRegistry.production_texture_for(role_id, allow_medium)
	if texture == null:
		return false
	control.texture = texture
	return true

static func set_icon_max_width(button: Button, width: int) -> void:
	if button == null or width <= 0:
		return
	button.add_theme_constant_override("icon_max_width", width)

static func _clear_native_background(control: Control) -> void:
	var transparent := StyleBoxFlat.new()
	transparent.bg_color = Color(0, 0, 0, 0)
	transparent.border_width_left = 0
	transparent.border_width_top = 0
	transparent.border_width_right = 0
	transparent.border_width_bottom = 0
	if control is PanelContainer:
		control.add_theme_stylebox_override("panel", transparent)
	elif control is Button:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			control.add_theme_stylebox_override(state, transparent)
	elif control is ProgressBar:
		control.add_theme_stylebox_override("background", transparent)
