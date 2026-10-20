extends ConfirmationDialog
class_name RAFantasyModal
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Scroll=preload("res://scripts/ui/touch_scroll.gd")
var _body:Control
var _frame:VBoxContainer
var _heading:Label
var _intro:Label
var _body_list:VBoxContainer
var _details:Label
var _large=false
var expand_sheet=true
var game_page=false
var _preferred_size=Vector2i(620,650)
var _opening:Tween
func _ready() -> void:
    borderless=true
    dialog_autowrap=true
    theme=Kit.native_theme()
    get_ok_button().custom_minimum_size=Vector2(190,100)
    get_cancel_button().custom_minimum_size=Vector2(160,100)
    about_to_popup.connect(_prepare_body)
    close_requested.connect(_close_sheet)
    var viewport=get_parent().get_viewport() if get_parent() else null
    if viewport:viewport.size_changed.connect(func():
        if visible:_fit_body())
func _close_sheet() -> void:
    canceled.emit()
    hide()
func _make_frame() -> void:
    _frame=VBoxContainer.new();_frame.name="GameSheet";_frame.add_theme_constant_override("separation",16);add_child(_frame)
    var header=HBoxContainer.new();header.add_theme_constant_override("separation",14);_frame.add_child(header)
    var back=Button.new();back.name="SheetBack";back.text="<";back.tooltip_text="Zurück";back.custom_minimum_size=Vector2(104,100);back.pressed.connect(_close_sheet);header.add_child(back)
    var ambience=preload("res://scripts/ui/ambient708.gd").new();ambience.show_behind_parent=true;_frame.add_child(ambience)
    _heading=Label.new();_heading.add_theme_font_override("font",Kit.BOLD);_heading.add_theme_font_size_override("font_size",26);_heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;_heading.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(_heading)
    _intro=Label.new();_intro.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;_intro.add_theme_font_size_override("font_size",20);_frame.add_child(_intro)
func _prepare_body() -> void:
    var first=not is_instance_valid(_frame)
    var content=[]
    for child in get_children():
        if child is Control and child!=_frame:content.append(child)
    if first:_preferred_size=size;_make_frame()
    var actions=[]
    for child in get_ok_button().get_parent().get_children():
        if child is Button and child!=get_ok_button() and child!=get_cancel_button():actions.append(child)
    if first or not content.is_empty():
        if is_instance_valid(_body) and _body.get_parent():_body.get_parent().remove_child(_body);_body.queue_free()
        _details=null;_body_list=null
        _large=content.size()==1 and (content[0] is TabContainer or content[0] is ScrollContainer)
        if _large and actions.is_empty():
            _body=content[0];_body.reparent(_frame,false)
            _intro.text=dialog_text;_intro.visible=not dialog_text.is_empty()
        else:
            var scroll=Scroll.new();scroll.name="ModalScroll";_frame.add_child(scroll);_body=scroll
            _body_list=VBoxContainer.new();_body_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;_body_list.add_theme_constant_override("separation",18);scroll.add_child(_body_list)
            _details=Label.new();_details.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;_details.size_flags_horizontal=Control.SIZE_EXPAND_FILL;_details.add_theme_font_size_override("font_size",23);_body_list.add_child(_details)
            for child in content:
                child.custom_minimum_size.x=0;child.reparent(_body_list,false)
            for button in actions:
                button.custom_minimum_size=Vector2(0,100);button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;button.reparent(_body_list,false)
            _intro.hide()
    if _details:_details.text=dialog_text;_details.visible=not dialog_text.is_empty()
    _heading.text=title
    get_label().hide()
    _fit_body();call_deferred("_fit_body")
    if first and int(get_tree().root.get_meta("realm_effect_level",0))==0:
        _frame.modulate.a=0
        _opening=create_tween();_opening.tween_property(_frame,"modulate:a",1.0,.14)
func _fit_body() -> void:
    if not is_instance_valid(_body):return
    var area=get_parent().get_viewport().get_visible_rect().size
    if game_page:
        get_ok_button().hide();get_cancel_button().hide()
        _body.custom_minimum_size=Vector2.ZERO;_body.size_flags_vertical=Control.SIZE_EXPAND_FILL
        _frame.custom_minimum_size=Vector2(0,maxf(300,area.y-238))
        min_size=Vector2i.ZERO;size=Vector2i(int(area.x)-24,int(area.y)-208);position=Vector2i(12,96)
        return
    var available=Vector2i(maxi(280,int(area.x)-32),maxi(240,int(area.y)-64))
    var body_height=0.0
    if is_instance_valid(_body_list):body_height=_body_list.get_combined_minimum_size().y
    elif _body is ScrollContainer and _body.get_child_count()>0:body_height=_body.get_child(0).get_combined_minimum_size().y
    var target_height=clampi(ceili(body_height)+240,360,maxi(360,int(area.y)-224))
    if _large and expand_sheet:target_height=maxi(320,int(area.y)-224)
    _body.custom_minimum_size=Vector2.ZERO
    _body.size_flags_vertical=Control.SIZE_EXPAND_FILL
    _frame.custom_minimum_size=Vector2(0,maxi(140,target_height-128))
    min_size=Vector2i.ZERO
    size=Vector2i(mini(688,available.x),target_height)
    position=Vector2i((area-Vector2(size))*.5)
