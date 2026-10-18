extends Control
class_name RAResourceBar
const BACK=preload("res://assets/ui/work63/bar_back.svg")
const FILL=preload("res://assets/ui/work63/bar_fill.svg")
@export var ratio: float=1
@export var fill_color: Color=Color("#36df73")
static var _back: StyleBoxTexture
static var _fill: StyleBoxTexture
static func paint(owner: CanvasItem, r: Rect2, value: float, color: Color) -> void:
    if not _back:
        _back=StyleBoxTexture.new();_back.texture=BACK
        _fill=StyleBoxTexture.new();_fill.texture=FILL
        for side in [SIDE_LEFT,SIDE_RIGHT]:_back.set_texture_margin(side,10);_fill.set_texture_margin(side,8)
    _back.draw(owner.get_canvas_item(),r)
    var f=r.grow(-3);f.size.x*=clampf(value,0,1)
    if f.size.x>1:
        _fill.modulate_color=color;_fill.draw(owner.get_canvas_item(),f)
func _draw() -> void:paint(self,Rect2(Vector2.ZERO,size),ratio,fill_color)
