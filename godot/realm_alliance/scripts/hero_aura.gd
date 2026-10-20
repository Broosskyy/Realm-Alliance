extends Node2D
class_name RAHeroAura
var shielded: bool = false
var shield_ratio: float = 1.0
var evolution: bool = false
var awakened: bool=false
var form_rank:int=0
var mastery_rank:int=0
var fx_intensity: float=1.0
var clock: float = 0.0
func _process(delta: float) -> void:
    clock += delta
    if visible:
        queue_redraw()
func _draw() -> void:
    if mastery_rank>0:
        var tints=[Color("#9fbbd8"),Color("#62d998"),Color("#31d9ff"),Color("#b65cff"),Color("#e2a7ff"),Color("#ffca65")]
        var tint=tints[clampi(mastery_rank,0,5)]
        for i in mastery_rank:
            var p=Vector2(100+(i-(mastery_rank-1)*.5)*20,-310)
            draw_colored_polygon(PackedVector2Array([p+Vector2(0,-6),p+Vector2(4,0),p+Vector2(0,6),p+Vector2(-4,0)]),Color(tint,.9))
        if fx_intensity>0:
            draw_set_transform(Vector2(0,-6),0,Vector2(1,.26));draw_arc(Vector2.ZERO,90+mastery_rank*4,0,TAU,56,Color(tint,.3*fx_intensity),2,true);draw_set_transform(Vector2.ZERO)
            if mastery_rank>=3:
                for i in mastery_rank:draw_circle(Vector2(100,-190)+Vector2(105,0).rotated(i*TAU/mastery_rank+clock*.15),2,Color(tint,.5*fx_intensity))
    if fx_intensity<=0:return
    if form_rank>=1:
        # Small, bounded runes are a separate equipment/VFX layer.
        var tint=Color("#ffcc62") if form_rank==3 else Color("#6ad8ff")
        for side in [-1,1]:
            var origin=Vector2(100+side*68,-205)
            draw_polyline(PackedVector2Array([origin+Vector2(-6,-15),origin+Vector2(8,0),origin+Vector2(-6,15)]),Color(tint,.65*fx_intensity),3,true)
    if form_rank==3:
        for i in 3:
            var center=Vector2(100,-215)
            draw_arc(center,145+i*7,clock*.2+i*TAU/3,clock*.2+i*TAU/3+.85,18,Color(1,.68,.15,(.45-i*.1)*fx_intensity),3,true)
    if awakened:
        var center=Vector2(100,-205)
        draw_arc(center,132,0,TAU,64,Color(1,.72,.25,.24*fx_intensity),2,true)
        draw_arc(center,125,0,TAU,64,Color(1,.85,.45,.12*fx_intensity),5,true)
        for i in 8:
            var point=center+Vector2.RIGHT.rotated(i*TAU/8+clock*.08)*132
            draw_line(point-Vector2(0,5),point+Vector2(0,5),Color(1,.83,.4,.7*fx_intensity),2,true)
    if evolution:
        draw_set_transform(Vector2(0,-8),0,Vector2(1,0.30))
        draw_arc(Vector2.ZERO,95,0,TAU,64,Color(0.22,0.85,1,0.5*fx_intensity),3,true)
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
