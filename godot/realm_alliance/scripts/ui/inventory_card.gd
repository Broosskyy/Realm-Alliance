extends "res://scripts/ui/fantasy_button.gd"
class_name RAInventoryCard
var item: Dictionary={}
var item_texture: Texture2D
const Art=preload("res://scripts/ui/item_art.gd")
func configure(data: Dictionary) -> void:
    item=data;item_texture=Art.thumbnail(data.icon);framed=true;custom_minimum_size=Vector2(150,204)
    tooltip_text=str(data.name)
    queue_redraw()
func _draw() -> void:
    if item.is_empty():return
    Kit.box("slot").draw(get_canvas_item(),Rect2(Vector2.ZERO,size))
    var tint=Color(preload("res://scripts/systems/economy68.gd").RARITIES.get(item.rarity,{"color":"#9fbbd8"}).color)
    var frame=StyleBoxFlat.new();frame.bg_color=Color.TRANSPARENT;frame.border_color=tint;frame.set_border_width_all(2);frame.set_corner_radius_all(13)
    draw_style_box(frame,Rect2(Vector2(2,2),size-Vector2(4,4)))
    if item.get("active",false):draw_circle(Vector2(size.x-15,15),5,Kit.CYAN)
    Art.paint(self,item_texture,Vector2(size.x/2,65),Vector2(122,108),item.kind=="weapon")
    var title=str(item.name);var width=size.x-20;var first=title;var second=""
    if Kit.BOLD.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,21).x>width:
        var cut=title.length()
        while cut>1 and Kit.BOLD.get_string_size(title.left(cut),HORIZONTAL_ALIGNMENT_LEFT,-1,21).x>width:cut-=1
        var space=title.left(cut).rfind(" ")
        if space>cut/2:cut=space
        first=title.left(cut).strip_edges();second=title.substr(cut).strip_edges()
        while second.length()>1 and Kit.BOLD.get_string_size(second,HORIZONTAL_ALIGNMENT_LEFT,-1,21).x>width:second=second.left(second.length()-2)+"…"
    draw_string(Kit.BOLD,Vector2(10,137),first,HORIZONTAL_ALIGNMENT_LEFT,width,21,Kit.INK)
    if second!="":draw_string(Kit.BOLD,Vector2(10,161),second,HORIZONTAL_ALIGNMENT_LEFT,width,21,Kit.INK)
    var detail="×%d"%int(item.get("count",1)) if item.kind in ["material","chest"] else str(item.get("progress_label","Lv. %d"%item.level))
    draw_string(Kit.FONT,Vector2(10,189),detail,HORIZONTAL_ALIGNMENT_LEFT,width,20,tint)
    if item.get("better",false) and not item.get("active",false):draw_string(Kit.BOLD,Vector2(size.x-28,29),"↑",HORIZONTAL_ALIGNMENT_LEFT,24,25,Color("#62d998"))
    draw_line(Vector2(12,size.y-8),Vector2(size.x-12,size.y-8),tint,3)
