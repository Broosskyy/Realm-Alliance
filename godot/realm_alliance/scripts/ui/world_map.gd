extends Control
class_name RAWorldMap
# Map artwork is reused as a live region atlas, not a screenshot UI.
# Buttons obey actual WorldProgress unlocks; all labels/stars are saved data.
signal stage_selected(index: int)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const ART=preload("res://assets/world65/world_map.webp")
const NODES=[Vector2(.22,.81),Vector2(.67,.64),Vector2(.26,.47),Vector2(.69,.29),Vector2(.37,.12)]
var session
var region="wolkgarten"
func configure(model,id: String) -> void:
    session=model;region=id;custom_minimum_size=Vector2(644,800)
func _ready() -> void:
    clip_contents=true
    var atlas=AtlasTexture.new();atlas.atlas=ART
    atlas.region=Rect2(0 if region=="wolkgarten" else 600,0,600,800)
    var image=TextureRect.new();image.texture=atlas;image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_SCALE;image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);image.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(image)
    var route=Line2D.new();route.width=5;route.default_color=Color("#debe79",.7)
    for point in NODES:route.add_point(Vector2(point.x*644,point.y*800))
    add_child(route)
    for i in 5:
        var d=session.World.encounter(region,i);var stars=session.World.stars(session.profile,region,i);var unlocked=session.World.can_enter(session.profile,region,i)
        var center=Vector2(NODES[i].x*644,NODES[i].y*800)
        var b=Button.new();b.name="Stage_"+region+"_"+str(i);b.position=center-Vector2(48,48);b.size=Vector2(96,96);b.theme=Kit.native_theme();b.add_theme_font_size_override("font_size",24)
        var plate=StyleBoxFlat.new();plate.bg_color=Color("#13233c");plate.border_color=Color("#ffce72") if d.kind=="boss" else Color("#3bdcff") if unlocked else Color("#5c697b");plate.set_border_width_all(3);plate.set_corner_radius_all(48);b.add_theme_stylebox_override("normal",plate)
        b.disabled=not unlocked or session.read_only;b.text="%d-%d"%[session.World.IDS.find(region)+1,i+1];b.tooltip_text=d.name;b.pressed.connect(func():stage_selected.emit(i));add_child(b)
        var label=Label.new();label.text=d.name;label.position=center+Vector2(-100,76);label.size=Vector2(200,28);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",19);label.add_theme_constant_override("outline_size",5);label.add_theme_color_override("font_outline_color",Color("#030b18"));label.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(label)
        for j in 3:
            var star=TextureRect.new();star.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;star.texture=load("res://assets/ui/work61/star.svg");star.size=Vector2(24,24);star.position=center+Vector2(-40+j*28,49);star.modulate=Color("#ffd16b") if j<stars else Color("#384b64");star.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(star)
