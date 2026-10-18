extends ConfirmationDialog
class_name RAFantasyModal
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
func _ready() -> void:
    theme=Kit.native_theme()
