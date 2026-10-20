extends PanelContainer
# Shared illustrated card. All progress values come from the current profile.
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
var body:VBoxContainer
func configure(heading:String,description:String,icon:String,current:int=-1,goal:int=1) -> void:
    size_flags_horizontal=Control.SIZE_EXPAND_FILL
    add_theme_stylebox_override("panel",Kit.box("slot"))
    body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",12);add_child(body)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",18);body.add_child(row)
    if not icon.is_empty():
        var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(icon);art.custom_minimum_size=Vector2(112,126);art.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(art)
    var text=VBoxContainer.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;text.add_theme_constant_override("separation",10);row.add_child(text)
    _label(text,heading,25,Color("#ffd16b"));_label(text,description,21,Kit.INK)
    if current>=0:
        var bar=ProgressBar.new();bar.name="Progress";bar.max_value=maxi(1,goal);bar.value=mini(current,goal);bar.show_percentage=false;bar.custom_minimum_size.y=16;bar.mouse_filter=Control.MOUSE_FILTER_IGNORE;body.add_child(bar)
        _label(body,"%d / %d"%[mini(current,goal),goal],20,Color("#a9c1dc"))
func _label(parent:Control,value:String,px:int,tint:Color) -> void:
    var l=Label.new();l.text=value;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",px);l.add_theme_color_override("font_color",tint);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(l)
