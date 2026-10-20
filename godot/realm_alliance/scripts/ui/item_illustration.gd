extends Control
const Art=preload("res://scripts/ui/item_art.gd")
var icon:Texture2D
var weapon=false
func configure(path:String) -> void:
    icon=Art.thumbnail(path);weapon=path.contains("/weapons/");queue_redraw()
func _draw() -> void:
    if icon:Art.paint(self,icon,size/2,size-Vector2(12,12),weapon)
