extends Node2D
class_name RAWeaponUpgradeVFX
# Separate weapon-local light layer; source sword remains replaceable and intact.
var tier=0
var intensity=1.0
var tint=Color("#50d8ff")
func _draw() -> void:
    if tier<=0 or intensity<=0:return
    var a=Vector2(420,190);var b=Vector2(1040,190)
    for i in range(3,0,-1):draw_line(a,b,Color(tint,.055*intensity),float(i*10+tier*3),true)
    draw_line(a,b,Color(tint,.22*intensity),2+tier,true)
    for i in tier:
        var at=a.lerp(b,(i+1.0)/(tier+1.0))
        draw_arc(at,9+tier,0,TAU,16,Color(tint,.6*intensity),2,true)
func configure(level: int,value: float=1.0) -> void:
    var next=0 if level<=0 else mini(3,1+int(level/4))
    if tier==next and intensity==value:return
    tier=next;intensity=value;tint=[Color("#50d8ff"),Color("#50d8ff"),Color("#c394ff"),Color("#ffd16b")][tier];queue_redraw()
