extends "res://scripts/ui/modal_dialog.gd"
class_name RAQuestDialog
signal claim_requested(id: String)
func configure(model,achievements: bool=false) -> void:
    title="Erfolge" if achievements else "Aufgaben";ok_button_text="Schließen";get_cancel_button().hide()
    var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(560,480);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
    var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",16);scroll.add_child(list)
    for d in model.Quests.CATALOG:
        if bool(d.achievement)!=achievements:continue
        var l=Label.new();l.add_theme_font_size_override("font_size",22);l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
        l.text="%s · %d / %d\n%s\n+%d Gold · +%d Splitter"%[d.name,mini(model.Quests.progress(model.profile,d.id),int(d.goal)),d.goal,d.description,d.gold,d.shards];list.add_child(l)
        var b=Button.new();b.custom_minimum_size.y=88;b.text="Abgeholt" if model.profile.quests.claimed.has(d.id) else "Belohnung abholen";b.disabled=model.read_only or model.profile.quests.claimed.has(d.id) or model.Quests.progress(model.profile,d.id)<int(d.goal);list.add_child(b)
        b.pressed.connect(func():claim_requested.emit(d.id);queue_free())
    confirmed.connect(queue_free);canceled.connect(queue_free)
