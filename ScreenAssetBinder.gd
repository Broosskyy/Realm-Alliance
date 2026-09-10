extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

static func apply(root: Node) -> Dictionary:
	var applied := 0
	var skipped := 0
	if root == null or not root.has_node("/root/SemanticAssetRegistry"):
		return {"applied": 0, "skipped": 0}
	var all_screens: Dictionary = SemanticAssetRegistry.contracts.get("screens", {})
	for screen_id in all_screens.keys():
		var screen: Dictionary = all_screens[screen_id]
		for node_name in screen.get("nodes", {}).keys():
			var spec: Dictionary = screen["nodes"][node_name]
			var node := root.find_child(str(node_name), true, false)
			if node == null or not (node is Control):
				skipped += 1
				continue
			var confidence := str(spec.get("confidence", "low"))
			if confidence == "low" or confidence == "hold":
				skipped += 1
				continue
			var role_id := str(spec.get("role", ""))
			var family := str(spec.get("family", "panel"))
			if role_id.is_empty():
				skipped += 1
				continue
			if _apply_to_control(node as Control, role_id, family, confidence == "medium"):
				applied += 1
			else:
				skipped += 1
	return {"applied": applied, "skipped": skipped}

static func _apply_to_control(control: Control, role_id: String, family: String, allow_medium: bool) -> bool:
	if family == "icon":
		var icon_tex := SemanticAssetRegistry.texture_for_role(role_id, allow_medium)
		if icon_tex == null: return false
		if control is Button:
			(control as Button).icon = icon_tex
			(control as Button).expand_icon = true
			return true
		if control is TextureRect:
			(control as TextureRect).texture = icon_tex
			(control as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			(control as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			return true
		return false
	if control is TextureRect:
		var tex := SemanticAssetRegistry.texture_for_role(role_id, allow_medium)
		if tex == null: return false
		(control as TextureRect).texture = tex
		(control as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		(control as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return true
	var ratio := 0.14
	if family == "primary_button":
		control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, 96.0)
		ratio = 0.20
	elif family == "secondary_button":
		control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, 78.0)
		ratio = 0.18
	elif family == "progress_bar":
		control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, 54.0)
		ratio = 0.20
	return ProductionUiBinder.apply_backdrop(control, role_id, allow_medium, ratio, control is Button or control is ProgressBar)
