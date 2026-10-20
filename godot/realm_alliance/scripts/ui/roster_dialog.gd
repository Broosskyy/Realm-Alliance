extends "res://scripts/ui/modal_dialog.gd"
class_name RARosterDialog
signal progression_changed(message:String)
signal selection_changed
var model
var tabs:TabContainer
var selected_hero=""
var selected_pet=""
func configure(value) -> void:
    game_page=true
    model=value;selected_hero=model.hero_id;selected_pet=str(model.profile.companions.active)
    if selected_pet=="":selected_pet="skyfox"
    title="Wesen";ok_button_text="Zurück zu Wesen";get_cancel_button().hide()
    confirmed.connect(queue_free);canceled.connect(queue_free);_build(0)
func _label(parent:Control,text:String,small:bool=false) -> void:
    var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",19 if small else 25);l.size_flags_horizontal=Control.SIZE_EXPAND_FILL;parent.add_child(l)
func _button(parent:Control,text:String,enabled:bool,callback:Callable) -> Button:
    var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.custom_minimum_size=Vector2(0,100);b.disabled=not enabled or model.read_only;parent.add_child(b);b.pressed.connect(callback);return b
func _portrait(id:String,hero:bool) -> Texture2D:
    if not hero:
        var owned=model.profile.companions.owned.get(id,{})
        return load("res://assets/roster67/"+id+("/evolved_idle.png" if int(owned.get("evolution",0))>0 else "/base_idle.png"))
    if id=="schattenjager":return preload("res://scripts/ui/item_art.gd").thumbnail("res://assets/expansion702/schattenjager/portrait.png")
    if id=="runenpaladin":return load("res://assets/roster68/runenpaladin/portrait.png")
    var portrait=AtlasTexture.new();portrait.atlas=load("res://assets/production/hero/idle.png");portrait.region=Rect2(310,25,230,220);return portrait
func _build(selected:int) -> void:
    if tabs:tabs.get_parent().remove_child(tabs);tabs.queue_free()
    tabs=TabContainer.new();tabs.custom_minimum_size=Vector2(540,710);add_child(tabs)
    for kind in ["Helden","Begleiter"]:
        var is_hero=kind=="Helden"
        var scroll=preload("res://scripts/ui/touch_scroll.gd").new();scroll.name=kind;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;tabs.add_child(scroll)
        var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",16);scroll.add_child(list)
        var catalog:Dictionary=model.Roster.playable_catalog() if is_hero else model.Companions.catalog()
        var selected_id=selected_hero if is_hero else selected_pet
        var d:Dictionary=catalog[selected_id]
        var owned=model.profile.hero_roster.owned.has(selected_id) if is_hero else model.profile.companions.owned.has(selected_id)
        var active=selected_id==model.hero_id if is_hero else selected_id==str(model.profile.companions.active)
        var rank=model.Roster.level(model.profile,selected_id) if is_hero else model.Companions.level(model.profile,selected_id)
        _label(list,d.name+" · "+("Lv. %d"%rank if owned else "Noch nicht freigeschaltet"))
        _label(list,d.role,true)
        var frame=PanelContainer.new();frame.add_theme_stylebox_override("panel",Kit.box("panel"));list.add_child(frame)
        var showcase=Control.new();showcase.custom_minimum_size=Vector2(0,335);frame.add_child(showcase)
        if is_hero:
            var rig=preload("res://scripts/production_hero.gd").new();showcase.add_child(rig);rig.preview_mode=true;rig.set_hero(selected_id);rig.equip_weapon(model.weapon_index);rig.set_gear(model.profile);rig.set_look(model.profile.look,false);rig.scale=Vector2.ONE*.70;rig.position=Vector2(185,325)
        else:
            var art=TextureRect.new();art.texture=_portrait(selected_id,false);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);showcase.add_child(art)
        _label(list,d.description,true)
        if owned:
            var xp=model.Roster.xp(model.profile,selected_id) if is_hero else int(model.profile.companions.owned[selected_id].xp)
            _label(list,"%d Kampf-XP · %s"%[xp,"Aktiv" if active else "In deiner Sammlung"],true)
            _button(list,"Aktiv" if active else ("Held wechseln" if is_hero else "Begleiter wechseln"),not active,func():_switch(kind,selected_id))
            if not is_hero:
                _button(list,"Entwickelt" if int(model.profile.companions.owned[selected_id].evolution)>0 else "Entwickeln · Lv.3 + Gartenkoloss\n100 Gold / 6 Splitter",model.Companions.can_evolve(model.profile,selected_id),func():
                    if model.evolve_companion(selected_id):progression_changed.emit(d.name+" entwickelt");_build(1))
        else:
            var gate="Level %d"%d.unlock_level
            if d.stage!="":
                var parts=str(d.stage).split(":");gate+=" · %s Stage %d"%[model.World.NAMES[parts[0]],int(parts[1])+1]
            _label(list,("30 Erntezeichen · im Eventshop" if bool(d.get("event",false)) else gate+" · %d Gold / %d Splitter"%[d.gold,d.shards]),true)
            _button(list,"Im Eventshop erhältlich" if bool(d.get("event",false)) else "Freischalten",model.Roster.can_unlock(model.profile,selected_id) if is_hero else model.Companions.can_acquire(model.profile,selected_id),func():
                var ok=model.unlock_hero(selected_id) if is_hero else model.acquire_companion(selected_id)
                if ok:progression_changed.emit(d.name+" freigeschaltet");_build(0 if is_hero else 1))
        _label(list,"Deine Helden" if is_hero else "Deine Begleiter")
        var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12);list.add_child(grid)
        for id in catalog:
            var data:Dictionary=catalog[id]
            var card=PanelContainer.new();card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;card.add_theme_stylebox_override("panel",Kit.box("hero" if id==selected_id else "slot"));grid.add_child(card)
            var col=VBoxContainer.new();card.add_child(col)
            var art=TextureRect.new();art.texture=_portrait(id,is_hero);art.custom_minimum_size=Vector2(0,145);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;col.add_child(art)
            var choose=_button(col,data.name,true,func():
                if is_hero:selected_hero=id
                else:selected_pet=id
                _build(0 if is_hero else 1))
            choose.add_theme_font_size_override("font_size",20)
        _label(list,"Du kannst jederzeit wechseln. Gegner-HP, Stage und Belohnungen bleiben erhalten.",true)
        if not is_hero:_button(list,"Begleiter ablegen",str(model.profile.companions.active)!="",func():_switch("Begleiter",""))
    tabs.current_tab=selected
    if visible:call_deferred("_prepare_body")
func _switch(kind:String,id:String) -> void:
    if model.read_only:return
    var ok=model.select_hero(id) if kind=="Helden" else model.select_companion(id)
    if not ok:return
    selection_changed.emit();_build(0 if kind=="Helden" else 1)
