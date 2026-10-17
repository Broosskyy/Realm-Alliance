extends Node2D
class_name RAHeroAura
var shielded: bool = false
var shield_ratio: float = 1.0
var evolution: bool = false
var clock: float = 0.0
func _process(delta: float) -> void:
    clock += delta
    if visible:
        queue_redraw()
func _draw() -> void:
    if evolution:
        draw_set_transform(Vector2(0,-8),0,Vector2(1,0.30))
        draw_arc(Vector2.ZERO,95,0,TAU,64,Color(0.22,0.85,1,0.5),3,true)
        for i in 8:
            var p=Vector2.RIGHT.rotated(i*TAU/8+clock*0.15)*90
            draw_circle(p,3,Color(0.6,0.9,1,0.7))
        draw_set_transform(Vector2.ZERO)
    if shielded:
        var p=Vector2(40,-200)
        draw_set_transform(p,0,Vector2(0.8,1))
        draw_circle(Vector2.ZERO,173,Color(0.14,0.62,1,0.07))
        draw_arc(Vector2.ZERO,173,-PI/2,-PI/2+TAU*shield_ratio,64,Color(0.4,0.86,1,0.8),4,true)
        draw_set_transform(Vector2.ZERO)
