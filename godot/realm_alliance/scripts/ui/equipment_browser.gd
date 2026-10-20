extends "res://scripts/ui/modal_dialog.gd"
signal item_selected(id:String)
const Gear=preload("res://scripts/systems/hero_equipment.gd")
func configure(model,slot:String) -> void:
    expand_sheet=false
    title={"chest":"Rüstung","head":"Kopfschmuck","wings":"Flügel"}[slot]
    ok_button_text="Schließen";get_cancel_button().hide()
    confirmed.connect(queue_free);canceled.connect(queue_free)
    var scroll=Scroll.new();add_child(scroll)
    var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",18);scroll.add_child(list)
    for id in Gear.IDS:
        var d:Dictionary=Gear.CATALOG[id]
        if d.slot!=slot:continue
        var card=Button.new();card.custom_minimum_size.y=190;list.add_child(card)
        var row=HBoxContainer.new();row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);row.offset_left=18;row.offset_right=-18;row.offset_top=14;row.offset_bottom=-14;row.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(row)
        var art=TextureRect.new();art.texture=load("res://assets/equipment/"+id+".png");art.custom_minimum_size=Vector2(140,150);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(art)
        var text=Label.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.mouse_filter=Control.MOUSE_FILTER_IGNORE
        var owned=model.profile.hero_equipment.owned.has(id)
        var active=model.profile.hero_equipment.equipped.get(slot,"")==id
        text.text=d.name+"\n"+("Angelegt" if active else ("Im Besitz" if owned else ("Eventbelohnung" if d.get("event",false) else "Ab Level %d"%d.unlock)))+"\n+%d HP · +%d DEF"%[Gear.item_stats(model.profile,id).hp,Gear.item_stats(model.profile,id).defense]
        text.add_theme_font_size_override("font_size",22);row.add_child(text)
        card.pressed.connect(func():item_selected.emit(id);queue_free())
