extends Button
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Economy=preload("res://scripts/systems/economy68.gd")
var illustration:Texture2D
var display_name=""
var detail=""
var owned=false
var active=false
var rarity="rare"
var rank=0
var hero_card=false
var clock=0.0
var _accum=0.0
func _ready() -> void:
    custom_minimum_size=Vector2(250,360)
    for state in ["normal","hover","pressed","disabled","focus"]:add_theme_stylebox_override(state,StyleBoxEmpty.new())
func _process(delta:float) -> void:
    if not is_visible_in_tree():return
    if int(get_tree().root.get_meta("realm_effect_level",0))==2:return
    clock+=delta;_accum+=delta
    if _accum>.05:_accum=0;queue_redraw()
func _draw() -> void:
    var color=Color(Economy.RARITIES.get(rarity,Economy.RARITIES.common).color)
    draw_style_box(Kit.box("slot"),Rect2(Vector2.ZERO,size))
    var center=Vector2(size.x*.5,size.y*.36)
    draw_circle(center,minf(size.x*.43,size.y*.3),Color(color,.06 if owned else .025))
    draw_arc(center,size.x*.39,-2.8,-.3,36,Color(color,.2),1.5,true)
    if illustration:
        var limit=Vector2(size.x-16,size.y-112);var extent=illustration.get_size()*minf(limit.x/illustration.get_width(),limit.y/illustration.get_height())
        var lift=-2 if button_pressed else 0
        draw_texture_rect(illustration,Rect2(Vector2((size.x-extent.x)/2,8+lift),extent),false,Color.WHITE if owned else Color(.55,.58,.65))
    draw_rect(Rect2(5,size.y-112,size.x-10,107),Color("#030c19",.96))
    var rim=StyleBoxFlat.new();rim.bg_color=Color.TRANSPARENT;rim.border_color=color if owned else color.darkened(.5);rim.set_border_width_all(3 if active else 2);rim.set_corner_radius_all(10);draw_style_box(rim,Rect2(Vector2(2,2),size-Vector2(4,4)))
    var title=display_name
    while title.length()>1 and Kit.BOLD.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,24).x>size.x-24:title=title.left(title.length()-2)+"…"
    draw_string(Kit.BOLD,Vector2(12,size.y-83),title,HORIZONTAL_ALIGNMENT_LEFT,size.x-24,24,Kit.INK)
    draw_string(Kit.FONT,Vector2(12,size.y-57),detail,HORIZONTAL_ALIGNMENT_LEFT,size.x-24,21,Color("#b2c5d6"))
    draw_string(Kit.BOLD,Vector2(12,size.y-32),Economy.RARITIES.get(rarity,Economy.RARITIES.common).name,HORIZONTAL_ALIGNMENT_LEFT,size.x-24,19,color)
    if hero_card:
        for i in 5:
            var p=Vector2(20+i*23,size.y-14)
            draw_colored_polygon(PackedVector2Array([p+Vector2(0,-6),p+Vector2(5,0),p+Vector2(0,6),p+Vector2(-5,0)]),color if i<rank else Color("#28415a"))
    elif not owned:draw_string(Kit.FONT,Vector2(12,size.y-10),"Noch nicht gefunden",HORIZONTAL_ALIGNMENT_LEFT,size.x-24,17,Color("#7f95ae"))
    if active:
        draw_circle(Vector2(size.x-25,25),15,Color("#169b52"));draw_polyline(PackedVector2Array([Vector2(size.x-34,25),Vector2(size.x-27,31),Vector2(size.x-16,18)]),Color.WHITE,3,true)
    if owned and int(get_tree().root.get_meta("realm_effect_level",0))==0:
        var x=fposmod(clock*32+float(display_name.hash()%100),size.x)
        draw_line(Vector2(x,3),Vector2(minf(size.x-5,x+24),3),Color(color,.4),2,true)
