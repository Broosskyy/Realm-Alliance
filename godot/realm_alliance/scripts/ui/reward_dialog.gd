extends "res://scripts/ui/modal_dialog.gd"
class_name RARewardDialog
func configure(reward:Dictionary,intensity:float=1) -> void:
    title="Wächtertruhe geöffnet";ok_button_text="Einsammeln";get_cancel_button().hide()
    var list=VBoxContainer.new();list.custom_minimum_size=Vector2(520,0);list.add_theme_constant_override("separation",16);add_child(list)
    var item:Dictionary=reward.item;var rarity=preload("res://scripts/systems/economy68.gd").RARITIES.get(item.rarity,{"name":item.rarity,"color":"#ffd16b"});var tint=Color(rarity.color)
    var stage=preload("res://scripts/ui/reward_stage708.gd").new();stage.name="ChestRevealStage";stage.intensity=intensity;stage.tint=tint;list.add_child(stage)
    var path="res://assets/work706/items/sky_shard.tres"
    if item.kind=="gear":path="res://assets/equipment/"+str(item.id)+".png"
    elif item.kind=="weapon":path="res://assets/production/weapons/"+str(item.id)+".png";stage.weapon=true
    elif model_material(item.id)!="":path=model_material(item.id)
    stage.item_texture=preload("res://scripts/ui/item_art.gd").thumbnail(path)
    for text in [str(rarity.name).to_upper(),str(item.name),"+%d Gold · +%d Himmelssplitter"%[reward.gold,reward.shards]]:
        var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.add_theme_font_size_override("font_size",26);l.add_theme_color_override("font_color",tint if text!=item.name else Kit.INK);list.add_child(l)
    if intensity>0:
        var skip=Button.new();skip.text="Sofort anzeigen";skip.custom_minimum_size.y=100;skip.pressed.connect(stage.skip);list.add_child(skip)
    confirmed.connect(queue_free);canceled.connect(queue_free)
func model_material(id:String) -> String:
    var materials=preload("res://scripts/systems/economy68.gd").MATERIALS
    return materials[id].icon if materials.has(id) else ""
