extends PanelContainer
func configure(title:String,detail:String,icon:String,intensity:float) -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE;z_index=49;position=Vector2(76,200);size=Vector2(568,164)
    add_theme_stylebox_override("panel",preload("res://scripts/ui/fantasy_theme.gd").box("hero"))
    var row=HBoxContainer.new();row.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_theme_constant_override("separation",14);add_child(row)
    var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(icon);art.custom_minimum_size=Vector2(112,112);art.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(art)
    var words=VBoxContainer.new();words.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(words)
    for value in [title,detail]:
        var l=Label.new();l.text=value;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.add_theme_font_size_override("font_size",27 if value==title else 21);l.add_theme_color_override("font_color",Color("#ffd16b") if value==title else Color("#eaf3ff"));words.add_child(l)
    if intensity>0:modulate.a=0;create_tween().tween_property(self,"modulate:a",1,.18)
    get_tree().create_timer(2.8).timeout.connect(func():
        if intensity>0:
            var tween=create_tween();tween.tween_property(self,"modulate:a",0,.2);tween.tween_callback(queue_free)
        else:queue_free()
    )
