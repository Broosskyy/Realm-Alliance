extends Node
func light() -> void:
    if SettingsService.haptics_enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(24)
func medium() -> void:
    if SettingsService.haptics_enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(42)
func success() -> void:
    if SettingsService.haptics_enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(65)
