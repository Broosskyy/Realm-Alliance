extends Control
class_name RAStageBackdrop
# Keep the painted fighting surface under the actors on every viewport shape.
var texture:Texture2D:
    set(value):texture=value;queue_redraw()
var ground_y=0.0
var floor_ratio=.71
func align_ground(value:float,ratio:float) -> void:
    ground_y=value;floor_ratio=ratio;queue_redraw()
func _draw() -> void:
    if not texture:return
    var source=texture.get_size()
    var floor=source.y*floor_ratio
    var factor=maxf(size.x/source.x,maxf(ground_y/floor,(size.y-ground_y)/(source.y-floor)))
    var extent=source*factor
    draw_texture_rect(texture,Rect2(Vector2((size.x-extent.x)*.5,ground_y-floor*factor),extent),false)
