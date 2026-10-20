extends "res://scripts/ui/modal_dialog.gd"
var content:VBoxContainer
var scroll:ScrollContainer
var _build_serial=0
func setup_sheet(caption:String) -> void:
    game_page=true;title=caption;get_cancel_button().hide();confirmed.connect(queue_free);canceled.connect(queue_free)
func clear_sheet() -> int:
    _build_serial+=1
    var offset=scroll.scroll_vertical if is_instance_valid(scroll) else 0
    if not is_instance_valid(scroll):
        scroll=Scroll.new();scroll.name="GamePageScroll";add_child(scroll)
        content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",16);scroll.add_child(content)
    for child in content.get_children():content.remove_child(child);child.queue_free()
    return offset
func finish_sheet(offset:int=0) -> void:
    if visible:call_deferred("_prepare_body")
    var serial=_build_serial
    await get_tree().process_frame;await get_tree().process_frame
    if is_instance_valid(scroll) and serial==_build_serial:scroll.scroll_vertical=offset
func label_at(parent:Control,text:String,px:int=23,tint:Color=Kit.INK) -> Label:
    var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",px);l.add_theme_color_override("font_color",tint);parent.add_child(l);return l
func button_at(parent:Control,text:String,fn:Callable,enabled:bool=true) -> Button:
    var b=Button.new();b.text=text;b.custom_minimum_size=Vector2(0,108);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.add_theme_font_size_override("font_size",22);b.disabled=not enabled;b.pressed.connect(fn);parent.add_child(b);return b
func field_at(parent:Control,placeholder:String,secret:bool=false) -> LineEdit:
    var input=LineEdit.new();input.placeholder_text=placeholder;input.secret=secret;input.custom_minimum_size.y=104;input.max_length=256 if secret else 120;parent.add_child(input);return input
func art_at(parent:Control,path:String,height:float=180) -> Control:
    var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(path);art.custom_minimum_size=Vector2(0,height);art.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(art);return art
func section(parent:Control,role:String="panel") -> VBoxContainer:
    var p=PanelContainer.new();p.add_theme_stylebox_override("panel",Kit.box(role));parent.add_child(p)
    var list=VBoxContainer.new();list.add_theme_constant_override("separation",14);p.add_child(list);return list
