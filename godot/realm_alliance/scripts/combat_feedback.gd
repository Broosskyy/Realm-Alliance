extends Node2D
class_name RACombatFeedback
var kind: String = "basic"
var age: float = 0
var duration: float = 0.48
func configure(id: String, lifetime: float = 0.48) -> void:
    kind = id
    duration = lifetime
func _process(delta: float) -> void:
    age += delta
    if age >= duration:
        queue_free()
    else:
        queue_redraw()
func _draw() -> void:
    var t=clampf(age/duration,0,1)
    var a=(1-t)*(1-t)
    var color=Color("#73e5ff")
    if kind in ["arcane","mark"]: color=Color("#d790ff")
    if kind in ["fire","burn"]: color=Color("#ff942b")
    if kind in ["telegraph","hit"]: color=Color("#ff534f")
    color.a=a
    match kind:
        "telegraph":
            draw_set_transform(Vector2.ZERO,0,Vector2(1,0.28))
            color.a=0.22+0.14*t
            draw_circle(Vector2.ZERO,100,color)
            draw_arc(Vector2.ZERO,105,-PI/2,-PI/2+TAU*t,64,Color(1,0.6,0.25,0.8),4,true)
        "arcane","mark":
            draw_arc(Vector2.ZERO,60+20*t,0,TAU,48,color,4,true)
            draw_arc(Vector2.ZERO,36+10*t,0,TAU,48,color,2,true)
            for i in 6:
                var p=Vector2.RIGHT.rotated(i*TAU/6)*80
                draw_line(p*0.8,p*1.1,color,4,true)
        "fire","burn":
            for i in 12:
                var phase=float(i)/12
                var x=sin(i*2.7)*60
                var y=-t*(95+50*phase)
                draw_circle(Vector2(x,y),maxf(1,(1-t)*(10+7*phase)),color)
            draw_arc(Vector2.ZERO,40+t*50,0,TAU,40,color,3,true)
        "shield","counter":
            draw_arc(Vector2.ZERO,65+t*55,0,TAU,48,color,5,true)
            draw_line(Vector2(-30,0),Vector2(30,0),color,4,true)
        _:
            var r=65+t*85 if kind=="sky" else 45+t*35
            draw_arc(Vector2.ZERO,r,-2.5,0.25,40,color,12 if kind=="sky" else 5,true)
            var inner=color.lightened(0.4)
            inner.a=a
            draw_arc(Vector2.ZERO,r-8,-2.3,0.15,40,inner,3,true)
            for i in 5:
                var p=Vector2.RIGHT.rotated(i*1.2)*r
                draw_line(p*0.8,p*1.1,color,2,true)
