extends "res://scripts/ui/modal_dialog.gd"
class_name RARewardDialog
func configure(reward: Dictionary,intensity: float=1) -> void:
    title="Wächtertruhe geöffnet";ok_button_text="Einsammeln";get_cancel_button().hide()
    var list=VBoxContainer.new();list.custom_minimum_size=Vector2(520,330);list.add_theme_constant_override("separation",16);add_child(list)
    var item:Dictionary=reward.item
    var art=TextureRect.new();art.custom_minimum_size.y=156;art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.texture=load("res://assets/equipment/"+str(item.id)+".png") if item.kind=="gear" else preload("res://assets/ui/work61/shard.svg");list.add_child(art)
    for value in [str(item.name),"%s\n+%d Gold · +%d Himmelssplitter"%[{"common":"Gewöhnlich","rare":"Selten","epic":"Episch"}.get(item.rarity,item.rarity),reward.gold,reward.shards]]:
        var label=Label.new();label.text=value;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_font_size_override("font_size",24);list.add_child(label)
    if intensity>0:
        art.modulate.a=0;create_tween().tween_property(art,"modulate:a",1.0,.25)
    confirmed.connect(queue_free);canceled.connect(queue_free)
