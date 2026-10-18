extends Node2D
class_name RAStatusVFX
var eye: Texture2D = preload("res://assets/vfx/arcane_eye.png")
var flame: Texture2D = preload("res://assets/vfx/fire_impact.png")
var shield: Texture2D = preload("res://assets/vfx/shield.png")
var mark: bool = false
var burn: bool = false
var shielded: bool = false
var shield_ratio: float = 0
var clock: float = 0
var intensity: float = 1
var hero_at: Vector2
var enemy_at: Vector2
func _process(delta: float) -> void:
    if not (mark or burn or shielded):return
    clock+=delta;queue_redraw()
func _draw() -> void:
    if mark:
        draw_texture_rect(eye,Rect2(enemy_at+Vector2(-55,-100),Vector2(110,110)),false,Color(1,1,1,0.65+0.12*sin(clock*3)))
    if burn:
        for i in 3:
            var p=fmod(clock*0.75+i/3.0,1)
            var size=55+25*sin(i*2.7)
            var at=enemy_at+Vector2(sin(i*2.4)*65,-p*125+40)
            draw_texture_rect(flame,Rect2(at-Vector2.ONE*size/2,Vector2.ONE*size),false,Color(1,1,1,(1-p)*0.75*maxf(0.35,intensity)))
    if shielded:
        draw_texture_rect(shield,Rect2(hero_at+Vector2(-100,-145),Vector2(200,245)),false,Color(0.8,0.95,1,0.32+0.25*shield_ratio))
