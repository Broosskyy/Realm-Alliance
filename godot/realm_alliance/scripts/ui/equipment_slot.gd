extends "res://scripts/ui/fantasy_button.gd"
class_name RAEquipmentSlot
var paint_card: bool=true
var item_name: String=""
var detail: String=""
var rarity_color: Color=Color("#8ab7d4")
var active: bool=false
var owned: bool=false
var item_texture: Texture2D
var compact: bool=false
func set_item(title: String,subtitle: String,tint: Color,selected: bool,available: bool,icon: Texture2D) -> void:
    item_name=title;detail=subtitle;rarity_color=tint;active=selected;owned=available;item_texture=icon;queue_redraw()
func _draw() -> void:
    if not paint_card:
        super._draw();return
    Kit.box("hero" if active else "panel").draw(get_canvas_item(),Rect2(Vector2.ZERO,size))
    if compact:
        if item_texture:draw_texture_rect(item_texture,Rect2(16,5,60,60),false,Color(1,1,1,1 if owned else .5))
        draw_string(Kit.BOLD,Vector2(6,size.y-9),item_name,HORIZONTAL_ALIGNMENT_LEFT,size.x-12,18,Kit.INK if owned else Color("#8395ac"))
        draw_line(Vector2(9,size.y-4),Vector2(size.x-9,size.y-4),rarity_color,2)
        super._draw();return
    draw_line(Vector2(12,size.y-7),Vector2(size.x-12,size.y-7),rarity_color if owned else Color("#26354a"),2,true)
    if item_texture and owned:
        draw_set_transform(Vector2(29,32),-0.5)
        draw_texture_rect(item_texture,Rect2(-26,-13,52,26),false)
        draw_set_transform(Vector2.ZERO)
    elif not owned:
        draw_circle(Vector2(29,32),10,Color("#3e5268"));draw_rect(Rect2(23,29,12,12),Color("#7990a6"))
    draw_string(Kit.BOLD,Vector2(54,27),item_name,HORIZONTAL_ALIGNMENT_LEFT,size.x-65,16,Kit.INK if owned else Color("#8395ac"))
    draw_string(Kit.FONT,Vector2(54,49),detail,HORIZONTAL_ALIGNMENT_LEFT,size.x-65,13,rarity_color if owned else Color("#8395ac"))
    super._draw()
