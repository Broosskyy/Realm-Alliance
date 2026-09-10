extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

static func button(text: String, role_id: String, family: String = "primary_button") -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 96.0 if family == "primary_button" else 78.0
	b.add_theme_font_size_override("font_size", 24)
	ProductionUiBinder.apply_backdrop(b, role_id, true, 0.20, true)
	return b

static func label(text: String, title := false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 30 if title else 18)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if title else HORIZONTAL_ALIGNMENT_LEFT
	return l

static func icon(role_id: String, min_size := 64.0) -> TextureRect:
	var t := TextureRect.new()
	t.custom_minimum_size = Vector2(min_size, min_size)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex := SemanticAssetRegistry.texture_for_role(role_id, true) if Engine.get_main_loop() else null
	if tex != null: t.texture = tex
	return t
