extends ConfirmationDialog
class_name RAFantasyModal
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
func _ready() -> void:
    dialog_autowrap=true
    theme=Kit.native_theme()
    get_ok_button().custom_minimum_size.y=88
    get_cancel_button().custom_minimum_size.y=88
