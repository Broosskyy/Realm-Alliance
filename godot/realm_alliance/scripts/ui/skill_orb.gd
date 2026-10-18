extends "res://scripts/ui/fantasy_button.gd"
class_name RASkillOrb
var orb: Texture2D
var shield: Texture2D=preload("res://assets/ui/work61/shield.svg")
var definition: Dictionary={}
var cooldown: float=0
var locked: bool=false
var affordable: bool=true
var label: String=""
func configure(texture: Texture2D,d: Dictionary,remaining: float,is_locked: bool,can_afford: bool,title: String) -> void:
    orb=texture;definition=d;cooldown=remaining;locked=is_locked;affordable=can_afford;label=title;queue_redraw()
func _draw() -> void:
    super._draw()
    if orb==null:return
    var center=Vector2(size.x/2,61)
    draw_texture_rect(orb,Rect2(center-Vector2(66,66),Vector2(132,132)),false,Color(0.57,0.63,0.73) if locked or not affordable else Color.WHITE)
    if definition.id=="guardian_wall" and not locked:
        draw_circle(center,37,Color("#112b50"));draw_texture_rect(shield,Rect2(center-Vector2(26,29),Vector2(52,58)),false)
    if cooldown>0:
        var p=PackedVector2Array([center]);var ratio=clampf(cooldown/float(definition.cooldown),0,1)
        for i in 33:p.append(center+Vector2.RIGHT.rotated(-PI/2+TAU*ratio*i/32)*55)
        draw_colored_polygon(p,Color(0,0.015,0.06,0.72));draw_arc(center,58,-PI/2,-PI/2+TAU*ratio,64,Color(0.8,0.94,1,0.8),2,true)
        text_at("%.1f"%cooldown,Rect2(center-Vector2(45,20),Vector2(90,40)),28,Kit.INK)
    else:
        Kit.box("panel").draw(get_canvas_item(),Rect2(center.x-43,center.y+39,86,23))
        var value="Lv. %d"%definition.unlock_level if locked else ("BEREIT" if definition.cost_type=="none" else "%d %s"%[definition.cost,"M" if definition.cost_type=="momentum" else "Z"])
        text_at(value,Rect2(center.x-43,center.y+39,86,23),12,Color("#9fbbd8") if locked or not affordable else Kit.CYAN)
    text_at(label,Rect2(center.x-80,center.y+66,160,22),14,Kit.INK)
func text_at(value: String,r: Rect2,font_size: int,color: Color) -> void:
    var w=Kit.BOLD.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
    var at=Vector2(r.get_center().x-w/2,r.position.y+(r.size.y+font_size*.72)/2)
    draw_string(Kit.BOLD,at+Vector2(1,1),value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("#020815"))
    draw_string(Kit.BOLD,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
