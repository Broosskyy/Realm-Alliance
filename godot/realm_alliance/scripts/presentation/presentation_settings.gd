extends RefCounted
class_name RAPresentationSettings
const PATH="user://realm_presentation.cfg"
var sound: bool = true
var effects: int = 0
func load_settings() -> void:
    var c=ConfigFile.new()
    if c.load(PATH)==OK:
        sound=bool(c.get_value("presentation","sound",true))
        effects=clampi(int(c.get_value("presentation","effects",0)),0,2)
func save_settings() -> void:
    var c=ConfigFile.new();c.set_value("presentation","sound",sound);c.set_value("presentation","effects",effects);c.save(PATH)
func intensity() -> float:
    return [1.0,0.4,0.0][effects]
