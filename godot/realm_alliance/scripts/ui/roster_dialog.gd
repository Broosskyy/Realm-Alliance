extends "res://scripts/ui/modal_dialog.gd"
class_name RARosterDialog
signal progression_changed(message:String)
signal run_started
var model
var tabs:TabContainer
func configure(value) -> void:
    model=value;title="Helden & Begleiter";ok_button_text="Schließen";get_cancel_button().hide()
    confirmed.connect(queue_free);canceled.connect(queue_free);_build(0)
func _label(parent:Control,text:String,small:bool=false) -> void:
    var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",18 if small else 22);l.size_flags_horizontal=Control.SIZE_EXPAND_FILL;parent.add_child(l)
func _button(parent:Control,text:String,enabled:bool,callback:Callable) -> void:
    var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.custom_minimum_size=Vector2(0,88);b.disabled=not enabled or model.read_only;parent.add_child(b);b.pressed.connect(callback)
func _build(selected:int) -> void:
    if tabs:remove_child(tabs);tabs.queue_free()
    tabs=TabContainer.new();tabs.custom_minimum_size=Vector2(540,660);add_child(tabs)
    for kind in ["Helden","Begleiter"]:
        var scroll=ScrollContainer.new();scroll.name=kind;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;tabs.add_child(scroll)
        var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",18);scroll.add_child(list)
        _label(list,"Ein Wechsel beginnt die aktuelle Region neu.\nWaffen, Ausrüstung und Kontofortschritt bleiben erhalten.",true)
        var catalog:Dictionary=model.Roster.catalog() if kind=="Helden" else model.Companions.catalog()
        for id in catalog:
            var d:Dictionary=catalog[id];var owned=model.profile.hero_roster.owned.has(id) if kind=="Helden" else model.profile.companions.owned.has(id)
            var card=PanelContainer.new();list.add_child(card);var content=VBoxContainer.new();content.add_theme_constant_override("separation",8);card.add_child(content)
            var row=HBoxContainer.new();content.add_child(row)
            var icon=TextureRect.new();icon.custom_minimum_size=Vector2(100,100);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;row.add_child(icon)
            if kind=="Helden":
                if id=="kaela":icon.texture=load("res://assets/roster67/kaela/portrait.png")
                else:
                    var portrait=AtlasTexture.new();portrait.atlas=load("res://assets/production/hero/idle.png");portrait.region=Rect2(310,25,230,220);icon.texture=portrait
            else:icon.texture=load("res://assets/roster67/"+id+("/evolved_idle.png" if owned and int(model.profile.companions.owned[id].evolution)>0 else "/base_idle.png"))
            var info=VBoxContainer.new();info.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(info)
            var rank=model.Roster.level(model.profile,id) if kind=="Helden" else model.Companions.level(model.profile,id)
            _label(info,d.name+(" · Lv. %d"%rank if owned else " · Gesperrt"));_label(info,d.role,true);_label(content,d.description,true)
            if owned:
                var xp=model.Roster.xp(model.profile,id) if kind=="Helden" else int(model.profile.companions.owned[id].xp)
                _label(content,"%d Kampf-XP · %s"%[xp,"★ ★ · Entwickelt" if kind=="Begleiter" and int(model.profile.companions.owned[id].evolution)>0 else "★"],true)
                var active=id==model.hero_id if kind=="Helden" else id==str(model.profile.companions.active)
                _button(content,"Aktiv" if active else "Mit "+str(d.name)+" starten",not active,func():_confirm_start(kind,id))
                if kind=="Begleiter":
                    var done=int(model.profile.companions.owned[id].evolution)>0
                    _button(content,"Entwickelt" if done else "Evolution · Lv.3 + Gartenkoloss\n100 G / 6 Splitter",model.Companions.can_evolve(model.profile,id),func():
                        if model.evolve_companion(id):progression_changed.emit(d.name+" entwickelt");_build(1))
            else:
                _label(content,"Kontolevel %d%s"%[d.unlock_level," · "+str(d.stage) if d.stage!="" else ""],true)
                var can=model.Roster.can_unlock(model.profile,id) if kind=="Helden" else model.Companions.can_acquire(model.profile,id)
                _button(content,"Freischalten · %d G / %d Splitter"%[d.gold,d.shards],can,func():
                    var ok=model.unlock_hero(id) if kind=="Helden" else model.acquire_companion(id)
                    if ok:progression_changed.emit(d.name+" freigeschaltet");_build(0 if kind=="Helden" else 1))
        if kind=="Begleiter":_button(list,"Ohne Begleiter starten",str(model.profile.companions.active)!="",func():_confirm_start("Begleiter",""))
    tabs.current_tab=selected
func _confirm_start(kind:String,id:String) -> void:
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new();add_child(dialog)
    dialog.title="Neuen Run beginnen?";dialog.dialog_text="Die Region beginnt bei Stage 1.\nDer laufende Kampf wird beendet. Fortschritt und Beute bleiben erhalten.";dialog.ok_button_text="Starten"
    dialog.confirmed.connect(func():
        var ok=model.select_hero(id) if kind=="Helden" else model.select_companion(id)
        if ok:progression_changed.emit("Neuer Run gestartet");run_started.emit();queue_free()
        dialog.queue_free())
    dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(560,260))
