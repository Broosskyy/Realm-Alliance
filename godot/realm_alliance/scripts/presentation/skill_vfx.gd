extends Node2D
class_name RASkillVFX
var model_deadline: float=-1
var texture: Texture2D
var frames:Array[Texture2D]=[]
var secondary: Texture2D
var kind: String = "impact"
var age: float = 0
var duration: float = 0.5
var diameter: float = 240
var intensity: float = 1
var target: Vector2 = Vector2.ZERO
var follow_node: Node2D
var follow_offset: Vector2=Vector2(60,0)
var origin: Vector2 = Vector2.ZERO
func _process(delta: float) -> void:
    if model_deadline>=0:return
    if is_instance_valid(follow_node):global_position=follow_node.to_global(follow_offset)
    age+=delta
    if age>=duration:queue_free()
    else:queue_redraw()
func _draw() -> void:
    var t=clampf(age/maxf(duration,0.001),0,1)
    var alpha=(1-smoothstep(0.28,1,t))*intensity
    var size=diameter*lerpf(0.45,1.08,ease(t,0.25))
    var angle=0.0
    if kind=="charge":
        alpha=sin(t*PI)*0.8*intensity;size=diameter*lerpf(0.45,1,t);angle=t*0.5
    elif kind=="projectile":
        position=origin.lerp(target,smoothstep(0,1,t));size=diameter*(0.65+sin(t*PI)*0.35);angle=t*0.7
    elif kind=="slash":
        size=diameter*lerpf(0.75,1.15,t);angle=lerpf(-0.22,0.12,t)
    elif kind=="eruption_warning":
        draw_set_transform(Vector2.ZERO,0,Vector2(1,.26))
        draw_circle(Vector2.ZERO,diameter*.5,Color(1,.25,.04,(.10+.12*t)*intensity))
        draw_arc(Vector2.ZERO,diameter*.5,-PI/2,-PI/2+TAU*t,48,Color(1,.55,.12,.75*intensity),5,true)
        return
    elif kind=="spawn":
        size=diameter*lerpf(0.3,1.3,t);alpha=sin(t*PI)*intensity
    draw_set_transform(Vector2.ZERO,angle)
    var current=frames[frame_index()] if not frames.is_empty() else texture
    if current:draw_texture_rect(current,Rect2(Vector2.ONE*-size/2,Vector2.ONE*size),false,Color(1,1,1,alpha))
    if secondary:
        var r=size*0.65
        draw_texture_rect(secondary,Rect2(Vector2.ONE*-r/2,Vector2.ONE*r),false,Color(1,1,1,alpha*0.7))
func frame_index() -> int:
    return mini(frames.size()-1,maxi(0,int(clampf(age/maxf(duration,.001),0,1)*frames.size()))) if not frames.is_empty() else 0
