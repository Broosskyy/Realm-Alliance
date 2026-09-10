extends Node

signal profile_changed(profile_name: String)

const MobileLayoutOwner = preload("res://MobileLayoutOwner.gd")

## Legacy autoload entry — delegates to MobileLayoutOwner (V2.01 single layout owner).
var current_profile: String = "standard"

func detect_profile(viewport_size: Vector2) -> String:
	return MobileLayoutOwner.detect_profile(viewport_size)

func apply(root: Control) -> void:
	var profile: String = MobileLayoutOwner.detect_profile(root.get_viewport_rect().size)
	if profile != current_profile:
		current_profile = profile
		profile_changed.emit(profile)
	MobileLayoutOwner.apply(root)
