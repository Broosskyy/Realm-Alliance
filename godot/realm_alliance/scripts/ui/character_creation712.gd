extends "res://scripts/ui/modal_dialog.gd"
signal created(body:String,hair:String)
const Character=preload("res://scripts/systems/character_progress712.gd")
var body="male"
var hair="brown"
var required=false
var model
var rig
var options:Dictionary={}
func configure(value,must_create:bool=false) -> void:
    model=value;required=must_create;title="Dein Abenteurer";name="CharacterCreation712"
    dialog_text="Wähle Körper und Haarfarbe. Aus dieser Figur wird später deine Klasse. Natürliche Haarfarben sind kostenlos."
    get_ok_button().text="Abenteuer beginnen";get_cancel_button().text="Später"
    var scroll=preload("res://scripts/ui/touch_scroll.gd").new();add_child(scroll)
    var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",14);scroll.add_child(list)
    var preview=Control.new();preview.name="CreationPreview";preview.custom_minimum_size=Vector2(0,340);preview.clip_contents=true;list.add_child(preview)
    var bg=TextureRect.new();bg.texture=load("res://assets/work705/ruins_courtyard.webp");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);preview.add_child(bg)
    rig=preload("res://scripts/production_hero.gd").new();rig.preview_mode=true;rig.z_index=4;preview.add_child(rig)
    preview.resized.connect(func():if is_instance_valid(rig):preload("res://scripts/presentation/hero_preview_frame711.gd").fit(rig,Rect2(14,10,preview.size.x-28,preview.size.y-20)))
    var sexes=HBoxContainer.new();sexes.add_theme_constant_override("separation",12);list.add_child(sexes)
    for pair in [["male","Männlich"],["female","Weiblich"]]:
        var b=_choice(sexes,pair[1],"Body_"+pair[0]);options[pair[0]]=b;b.pressed.connect(func():body=pair[0];_update())
    var colors=GridContainer.new();colors.columns=2;colors.add_theme_constant_override("h_separation",12);colors.add_theme_constant_override("v_separation",12);list.add_child(colors)
    for pair in [["blond","Blond"],["black","Schwarz"],["brown","Braun"],["copper","Kupfer"]]:
        var b=_choice(colors,pair[1],"Hair_"+pair[0]);options[pair[0]]=b;b.pressed.connect(func():hair=pair[0];_update())
    var info=Label.new();info.text="Schlichte Kleidung · Rucksack · separate Anfängerwaffe\nWeiß, Silber und bunte Haare bleiben spätere Kosmetik.\nDeine vorhandenen Helden und Gegenstände bleiben erhalten.";info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;info.add_theme_font_size_override("font_size",20);list.add_child(info)
    confirmed.connect(func():created.emit(body,hair))
    about_to_popup.connect(func():
        get_cancel_button().visible=not required
        if required:
            for button in find_children("SheetBack","Button",true,false):button.hide())
    _update()
func _choice(parent:Control,text:String,id:String) -> Button:
    var b=Button.new();b.name=id;b.text=text;b.custom_minimum_size=Vector2(0,88);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.toggle_mode=true;b.add_theme_stylebox_override("pressed",Kit.box("primary"));parent.add_child(b);return b
func _update() -> void:
    for id in options:options[id].button_pressed=id==body or id==hair
    rig.set_hero("adventurer_"+body)
    var p=model.profile.duplicate(true);p.erase("character712");Character.create(p,body,hair)
    p.hero_equipment.equipped={};p.hero_equipment.cosmetics={};p.wardrobe.active=""
    rig.set_gear(p);rig.set_look("canonical",false)
    var preview=rig.get_parent()
    if preview.size.x>30:preload("res://scripts/presentation/hero_preview_frame711.gd").fit(rig,Rect2(14,10,preview.size.x-28,preview.size.y-20))
func _close_sheet() -> void:
    if not required:super._close_sheet()
