extends Control
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Art=preload("res://scripts/ui/item_art.gd")
var age=0.0
var intensity=1.0
var item_texture:Texture2D
var weapon=false
var tint=Color("#ffcc68")
var closed=preload("res://assets/work708/ui/chest_closed.tres")
var opened=preload("res://assets/work708/ui/chest_open.tres")
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE;custom_minimum_size.y=300
func _process(delta:float) -> void:
    if intensity<=0:age=2.0;set_process(false)
    else:age=minf(3,age+delta)
    queue_redraw()
func skip() -> void:age=2.0;queue_redraw()
func _draw() -> void:
    var center=Vector2(size.x/2,150)
    var t=clampf((age-.22)/.6,0,1) if intensity>0 else 1.0
    draw_circle(center,115,Color(tint,.035+.035*t))
    draw_arc(center,107,-PI+age*.18,age*.18,44,Color(tint,.35),2,true)
    if intensity>0 and age<1.2:
        for i in 10:
            var p=center+Vector2(40+age*75,0).rotated(i*TAU/10)
            draw_circle(p,2,Color(tint,sin(clampf(age,0,1)*PI)*.5*intensity))
    var chest=closed if age<.28 and intensity>0 else opened
    var chest_size=Vector2(215,215)
    draw_texture_rect(chest,Rect2(center+Vector2(-107,-92),chest_size),false,Color(1,1,1,1-t*.65))
    if item_texture and t>0:
        Art.paint(self,item_texture,center+Vector2(0,-18*t),Vector2(170,180)*lerpf(.6,1,t),weapon,Color(1,1,1,t))
