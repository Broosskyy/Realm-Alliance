extends "res://scripts/ui/fantasy_panel.gd"
class_name RANotificationToast
var title_label: Label
var detail_label: Label
func _ready() -> void:
    role="boss";super._ready()
    title_label=Label.new();detail_label=Label.new()
    for label in [title_label,detail_label]:
        label.mouse_filter=Control.MOUSE_FILTER_IGNORE
        label.add_theme_font_override("font",Kit.BOLD if label==title_label else Kit.FONT)
        label.add_theme_color_override("font_color",Color("#ffd16b") if label==title_label else Color("#a5c2de"))
        label.add_theme_color_override("font_outline_color",Color("#020815"));label.add_theme_constant_override("outline_size",2)
        label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
        add_child(label)
func display(title: String,detail: String,compact: bool) -> void:
    if title_label==null:return
    title_label.text=title if compact else title+" · "+detail
    title_label.position=Vector2(16,13 if compact else 7)
    title_label.size=Vector2(size.x-32,26)
    title_label.add_theme_font_size_override("font_size",13 if compact else 14)
    detail_label.text=detail;detail_label.position=Vector2(16,51);detail_label.size=Vector2(size.x-32,27)
    detail_label.add_theme_font_size_override("font_size",12);detail_label.visible=compact
    tooltip_text=title+" · "+detail
