extends "res://scripts/ui/fantasy_button.gd"
class_name RAInventoryCard
var item: Dictionary={}
var item_texture: Texture2D
func configure(data: Dictionary) -> void:
    item=data;item_texture=load(data.icon);framed=true;custom_minimum_size=Vector2(150,182)
    tooltip_text=str(data.name)
    queue_redraw()
func _draw() -> void:
    if item.is_empty():return
    Kit.box("slot").draw(get_canvas_item(),Rect2(Vector2.ZERO,size))
    var tint=Color("#b65cff") if item.rarity=="epic" else (Color("#31d9ff") if item.rarity=="rare" else Color("#9fbbd8"))
    var frame=StyleBoxFlat.new();frame.bg_color=Color.TRANSPARENT;frame.border_color=tint;frame.set_border_width_all(2);frame.set_corner_radius_all(13)
    draw_style_box(frame,Rect2(Vector2(2,2),size-Vector2(4,4)))
    if item.get("active",false):draw_circle(Vector2(size.x-15,15),5,Kit.CYAN)
    var texture=item_texture
    var limit=Vector2(122,108)
    var extent=texture.get_size()*minf(limit.x/texture.get_width(),limit.y/texture.get_height())
    draw_texture_rect(texture,Rect2(Vector2(size.x/2,65)-extent/2,extent),false)
    draw_string(Kit.BOLD,Vector2(10,143),item.name,HORIZONTAL_ALIGNMENT_LEFT,size.x-20,15,Kit.INK)
    var detail="×%d"%int(item.get("count",1)) if item.kind in ["material","chest"] else "Lv. %d%s"%[item.level," · Aktiv" if item.get("active",false) else ""]
    draw_string(Kit.FONT,Vector2(10,168),detail,HORIZONTAL_ALIGNMENT_LEFT,size.x-20,17,tint)
    draw_line(Vector2(12,size.y-8),Vector2(size.x-12,size.y-8),tint,3)
