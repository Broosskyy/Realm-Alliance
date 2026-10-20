extends Node2D
class_name RAWeaponUpgradeVFX
# Weapon-local detail follows the actual exchangeable hand socket.
var tier=0
var refinement=0
var intensity=1.0
var tint=Color("#50d8ff")
var clock=0.0
func _ready() -> void:
    set_process(false)
func _process(delta:float) -> void:
    clock+=delta;queue_redraw()
func _draw() -> void:
    if tier<=0 or intensity<=0:return
    var a=Vector2(420,190);var b=Vector2(1040,190)
    var strength=.5+refinement/38.0
    for i in range(3,0,-1):draw_line(a,b,Color(tint,.04*intensity*strength),float(i*8+tier*3),true)
    draw_line(a,b,Color(tint,.18*intensity),1.0+refinement*.18,true)
    for i in tier:
        var at=a.lerp(b,(i+1.0)/(tier+1.0))
        draw_arc(at,7+tier,0,TAU,16,Color(tint,.45*intensity),1.5,true)
    if refinement>=8:
        for i in 3:
            var progress=fposmod(clock*.18+i*.31,1.0)
            var at=a.lerp(b,progress)+Vector2(0,sin(clock*2+i)*9)
            draw_circle(at,1.8,Color(tint,sin(progress*PI)*.65*intensity))
func configure(level:int,value:float=1.0) -> void:
    if is_inside_tree():value=minf(value,[1.0,.4,0.0][clampi(int(get_tree().root.get_meta("realm_effect_level",0)),0,2)])
    var next=0 if level<=0 else mini(3,1+int(level/4))
    if tier==next and refinement==level and intensity==value:return
    tier=next;refinement=clampi(level,0,19);intensity=clampf(value,0,1)
    tint=[Color("#50d8ff"),Color("#50d8ff"),Color("#c394ff"),Color("#ffd16b")][tier]
    set_process(refinement>=8 and intensity>0);queue_redraw()
