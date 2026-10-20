extends "res://scripts/ui/modal_dialog.gd"
class_name RAQuestDialog
signal claim_requested(id: String)
func configure(model,achievements: bool=false) -> void:
    game_page=true
    title="Erfolge" if achievements else "Aufgaben";ok_button_text="Schließen";get_cancel_button().hide()
    var scroll=preload("res://scripts/ui/touch_scroll.gd").new();scroll.custom_minimum_size=Vector2(560,480);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
    var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",16);scroll.add_child(list)
    for d in model.Quests.CATALOG:
        if bool(d.achievement)!=achievements:continue
        var card=preload("res://scripts/ui/progress_card.gd").new()
        card.configure(d.name,"%s\n+%d Gold · +%d Splitter"%[d.description,d.gold,d.shards],"res://assets/work704/ui/"+("achievements" if achievements else "quests")+".png",model.Quests.progress(model.profile,d.id),int(d.goal));list.add_child(card)
        var b=Button.new();b.custom_minimum_size.y=100;b.text="Abgeholt" if model.profile.quests.claimed.has(d.id) else "Belohnung abholen";b.disabled=model.read_only or model.profile.quests.claimed.has(d.id) or model.Quests.progress(model.profile,d.id)<int(d.goal);card.body.add_child(b)
        b.pressed.connect(func():claim_requested.emit(d.id);queue_free())
    confirmed.connect(queue_free);canceled.connect(queue_free)
