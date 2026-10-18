extends NinePatchRect
class_name RAFantasyPanel
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
@export_enum("panel","boss","hero","slot") var role: String="panel"
func _ready() -> void:
    texture=Kit.TEXTURES.get(role,Kit.TEXTURES.panel)
    var margin=8 if role in ["panel","boss","hero"] else 22
    patch_margin_left=margin;patch_margin_right=margin;patch_margin_top=margin;patch_margin_bottom=margin
    mouse_filter=Control.MOUSE_FILTER_IGNORE
