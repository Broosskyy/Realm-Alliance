extends "res://scripts/ui/fantasy_button.gd"
class_name RAInventoryCard
var item: Dictionary={}
var item_texture: Texture2D
func configure(data: Dictionary) -> void:
    item=data;item_texture=load(data.icon);framed=true;custom_minimum_size=Vector2(190,198)
    tooltip_text=str(data.name)
    queue_redraw()
func _draw() -> void:
    if item.is_empty():return
    Kit.box("hero" if item.get("active",false) else "panel").draw(get_canvas_item(),Rect2(Vector2.ZERO,size))
    var tint=Color("#b65cff") if item.rarity=="epic" else (Color("#31d9ff") if item.rarity=="rare" else Color("#9fbbd8"))
    var texture=item_texture
    var limit=Vector2(120,104)
    var extent=texture.get_size()*minf(limit.x/texture.get_width(),limit.y/texture.get_height())
    draw_texture_rect(texture,Rect2(Vector2(size.x/2,62)-extent/2,extent),false)
    draw_string(Kit.BOLD,Vector2(12,140),item.name,HORIZONTAL_ALIGNMENT_LEFT,size.x-24,18,Kit.INK)
    var detail="×%d"%int(item.get("count",1)) if item.kind in ["material","chest"] else "Lv. %d%s"%[item.level," · Aktiv" if item.get("active",false) else ""]
    draw_string(Kit.FONT,Vector2(12,171),detail,HORIZONTAL_ALIGNMENT_LEFT,size.x-24,19,tint)
    draw_line(Vector2(12,size.y-8),Vector2(size.x-12,size.y-8),tint,3)
