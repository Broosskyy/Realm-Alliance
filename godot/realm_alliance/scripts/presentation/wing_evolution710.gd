extends Node2D
class_name RAWingEvolution710
# Texture-backed extra feathers use the existing authored gold/blue material.
# This is runtime composition, not fifteen recolored copies of the same sheet.
const Progress=preload("res://scripts/systems/wing_progression710.gd")
const FEATHER=[Vector2(82,38),Vector2(105,83),Vector2(146,115),Vector2(219,137),Vector2(246,127),Vector2(196,94),Vector2(135,70)]
var plus=0
var family="sky_wings"
var intensity=1.0
var clock=0.0
var source:Texture2D
var layout:Dictionary={}
func configure(texture:Texture2D,value:int,id:String,fx:float=1.0) -> void:
    source=texture;plus=clampi(value,0,15);family=id;intensity=clampf(fx,0,1)
    if is_inside_tree():intensity=minf(intensity,[1.0,.4,0.0][clampi(int(get_tree().root.get_meta("realm_effect_level",0)),0,2)])
    layout=Progress.visual(plus);set_process(plus>=10 and intensity>0);queue_redraw()
func _process(delta:float) -> void:
    clock+=delta;queue_redraw()
func _draw() -> void:
    if source==null or layout.is_empty():return
    var colors=PackedColorArray([Color.WHITE])
    var dim=source.get_size()
    for i in int(layout.feathers):
        var side=-1.0 if i%2==0 else 1.0
        var row=int(i/2)
        var anchor=Vector2(-145,-18+row*10) if side<0 else Vector2(12,-22+row*7)
        if bool(layout.second_fan) and row>=4:anchor+=Vector2(-25 if side<0 else 12,18)
        var points=PackedVector2Array();var uv=PackedVector2Array()
        for v in FEATHER:
            var offset=(v-Vector2(224,130))*Vector2(1 if side<0 else -.5,1)
            offset=offset.rotated(-.12+row*.13)
            points.append(anchor+offset*(.9+plus*.012))
            uv.append(v/dim)
        draw_polygon(points,colors,uv,source)
    var tint=Color("#66dfff") if family=="sky_wings" else Color("#ffc36e")
    for i in int(layout.crystals):
        var center=Vector2(-56-i*35,-48-i*9)
        var gem=PackedVector2Array([center+Vector2(0,-10),center+Vector2(7,0),center+Vector2(0,10),center+Vector2(-7,0)])
        draw_colored_polygon(gem,Color(tint,.9));draw_polyline(PackedVector2Array([gem[0],gem[1],gem[2],gem[3],gem[0]]),Color("#f5d58d"),1.5,true)
    if bool(layout.rim) and intensity>0:
        for i in 5:
            var at=Vector2(-80-i*38,-85-i*14+sin(clock*1.6+i)*5)
            draw_circle(at,1.2+int(bool(layout.final)),Color(tint,(.3+.2*sin(clock+i))*intensity))
    if bool(layout.crown):
        var c=Vector2(-12,-22)
        draw_polyline(PackedVector2Array([c+Vector2(-18,5),c+Vector2(-10,-10),c,c+Vector2(10,-10),c+Vector2(18,5)]),Color("#e9c976"),2,true)
