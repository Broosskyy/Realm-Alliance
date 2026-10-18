extends Control
class_name RAWorldMap
# Map artwork is reused as a live region atlas, not a screenshot UI.
# Buttons obey actual WorldProgress unlocks; all labels/stars are saved data.
signal stage_selected(index: int)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const ART=preload("res://assets/world65/world_map.webp")
const NODES=[Vector2(.16,.79),Vector2(.51,.62),Vector2(.12,.44),Vector2(.48,.27),Vector2(.2,.07)]
var session
var region="wolkgarten"
func configure(model,id: String) -> void:
    session=model;region=id;custom_minimum_size=Vector2(644,800)
func _ready() -> void:
    clip_contents=true
    var atlas=AtlasTexture.new();atlas.atlas=ART
    atlas.region=Rect2(0 if region=="wolkgarten" else 600,0,600,800)
    var image=TextureRect.new();image.texture=atlas;image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_SCALE;image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);image.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(image)
    for i in 5:
        var d=session.World.encounter(region,i)
        var stars=session.World.stars(session.profile,region,i)
        var unlocked=session.World.can_enter(session.profile,region,i)
        var b=Button.new();b.name="Stage_"+region+"_"+str(i)
        b.position=Vector2(NODES[i].x*644,NODES[i].y*800);b.size=Vector2(246,94)
        b.theme=Kit.native_theme();b.add_theme_font_size_override("font_size",21)
        b.add_theme_stylebox_override("normal",Kit.box("boss" if d.kind=="boss" else "panel"))
        b.disabled=not unlocked or session.read_only
        b.text=("♛ " if d.kind=="boss" else ("◆ " if unlocked else "▣ "))+"%d-%d · %s\n%s"%[session.World.IDS.find(region)+1,i+1,{"normal":"Normal","elite":"Elite","boss":"Boss"}[d.kind],"★".repeat(stars)+"☆".repeat(3-stars)]
        b.tooltip_text=d.name+" · "+("Betreten / wiederholen" if unlocked else "Vorherige Stage abschließen")
        b.pressed.connect(func():stage_selected.emit(i));add_child(b)
