extends Button
class_name RAFantasyButton
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
var framed: bool=false
var role: String="primary"
func _ready() -> void:
    theme=Kit.native_theme()
    if not framed:
        for state in ["normal","hover","pressed","disabled","focus"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
func _draw() -> void:
    if not framed and (is_hovered() or button_pressed or has_focus()):
        var c=Color(0.2,0.75,1,0.07 if not button_pressed else 0.16)
        draw_rect(Rect2(Vector2.ZERO,size),c)
