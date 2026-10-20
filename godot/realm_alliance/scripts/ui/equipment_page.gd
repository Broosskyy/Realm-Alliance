extends "res://scripts/ui/modal_dialog.gd"
signal changed(message:String)
const Inventory=preload("res://scripts/systems/inventory_view.gd")
const Card=preload("res://scripts/ui/inventory_card.gd")
const Wardrobe=preload("res://scripts/systems/wardrobe711.gd")
const Preview=preload("res://scripts/systems/equipment_preview707.gd")
var model
var category="weapon"
var selected=""
var scroll:ScrollContainer
func configure(value,slot:String="weapon") -> void:
    model=value;category=slot;game_page=true;title="Ausrüstung";get_cancel_button().hide();confirmed.connect(queue_free);canceled.connect(queue_free);_build()
func _label(parent:Control,text:String,color:Color=Kit.INK,px:int=22) -> void:
    var label=Label.new();label.text=text;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_color_override("font_color",color);label.add_theme_font_size_override("font_size",px);parent.add_child(label)
func _button(parent:Control,text:String,enabled:bool,fn:Callable,primary:bool=false) -> Button:
    var b=Button.new();b.text=text;b.custom_minimum_size=Vector2(0,108);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.add_theme_font_size_override("font_size",20);b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.disabled=not enabled or model.read_only
    if primary:b.add_theme_stylebox_override("normal",Kit.box("secondary"))
    parent.add_child(b);b.pressed.connect(fn);return b
func _build(restore_scroll:bool=false) -> void:
    var offset=scroll.scroll_vertical if restore_scroll and is_instance_valid(scroll) else 0
    if is_instance_valid(scroll):scroll.get_parent().remove_child(scroll);scroll.queue_free()
    scroll=Scroll.new();scroll.name="EquipmentScroll";add_child(scroll)
    var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",18);scroll.add_child(list)
    var tabs=GridContainer.new();tabs.columns=5 if get_tree().root.get_visible_rect().size.x>=1100 else 3;tabs.add_theme_constant_override("h_separation",10);tabs.add_theme_constant_override("v_separation",10);list.add_child(tabs)
    for pair in [["weapon","Waffe"],["chest","Rüstung"],["head","Kopf"],["wings","Flügel"],["costume","Kostüm"]]:
        var b=_button(tabs,pair[1],true,func():category=pair[0];selected="";_build());b.name="EquipmentTab_"+pair[0];b.add_theme_stylebox_override("normal",Kit.box("primary" if category==pair[0] else "panel"))
    if category=="costume":
        _build_costumes(list)
        if visible:call_deferred("_prepare_body")
        _restore_scroll(scroll,offset)
        return
    var items=[]
    if category=="weapon":items=Inventory.items(model.profile,"weapon")
    else:
        for id in model.HeroEquipment.IDS:
            var d:Dictionary=model.HeroEquipment.CATALOG[id]
            if d.slot!=category:continue
            items.append({"id":id,"kind":"gear","name":d.name,"rarity":d.rarity,"level":model.profile.hero_equipment.owned.get(id,{}).get("level",1),"progress_label":model.HeroEquipment.display_level(model.profile,id),"active":model.profile.hero_equipment.equipped.get(category,"")==id,"icon":"res://assets/equipment/"+id+".png"})
    if selected=="" and not items.is_empty():
        selected=items[0].id
        for item in items:
            if item.active:selected=item.id
    for item in items:
        if item.id!=selected:continue
        var panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",Kit.box("slot"));list.add_child(panel)
        var body=VBoxContainer.new();body.add_theme_constant_override("separation",16);panel.add_child(body)
        var row=HBoxContainer.new();row.add_theme_constant_override("separation",22);body.add_child(row)
        var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(item.icon);art.custom_minimum_size=Vector2(210,230);row.add_child(art)
        var info=VBoxContainer.new();info.size_flags_horizontal=Control.SIZE_EXPAND_FILL;info.add_theme_constant_override("separation",12);row.add_child(info)
        var rarity=model.Economy.RARITIES[item.rarity];_label(info,item.name,Color(rarity.color),26);_label(info,rarity.name+" · "+str(item.get("progress_label","Lv. %d"%item.level)),Color(rarity.color))
        var actions=HBoxContainer.new();actions.add_theme_constant_override("separation",12);body.add_child(actions)
        if category=="weapon":
            _label(info,"Angriff %d (%+d)"%[model.Equipment.item_damage(model.profile,item.id),model.Equipment.item_damage(model.profile,item.id)-model.Equipment.damage(model.profile)])
            var preview=Preview.weapon(model.profile,item.id);var cost=preview.cost
            _label(body,"Maximalstufe erreicht" if preview.maximum else "Nächste Stufe: Angriff %d → %d (+%d)"%[preview.current,preview.next,preview.next-preview.current],Color("#ffd16b"),22)
            _upgrade_status(body,cost,preview.maximum)
            _button(actions,"Maximalstufe" if preview.maximum else "Verbessern\n%d G / %d Splitter"%[cost.gold,cost.shards],preview.affordable,func():_change(model.upgrade_weapon(item.id),"Waffe verbessert"),true)
            _button(actions,"Ausgerüstet" if item.active else "Ausrüsten",not item.active,func():_change(model.equip(item.id),"Waffe angelegt"))
        else:
            if category=="chest" and Wardrobe.active(model.profile)!="":
                _label(body,"Dein Kostüm überdeckt die getragene Rüstung. Ihre Werte bleiben aktiv.",Color("#a9c1dc"),20)
                _button(body,"Kostüm ablegen",true,func():_change(model.equip_costume(""),"Rüstung wieder sichtbar"))
            var values=model.HeroEquipment.item_stats(model.profile,item.id);var current=model.HeroEquipment.item_stats(model.profile,str(model.profile.hero_equipment.equipped.get(category,"")))
            _label(info,"HP +%d (%+d)\nDEF +%d (%+d)"%[values.hp,values.hp-current.hp,values.defense,values.defense-current.defense])
            if model.profile.hero_equipment.owned.has(item.id):
                var preview=Preview.gear(model.profile,item.id);var cost=preview.cost
                _label(body,"Maximalstufe erreicht" if preview.maximum else "Nächste Stufe: HP +%d → +%d · DEF +%d → +%d"%[preview.current.hp,preview.next.hp,preview.current.defense,preview.next.defense],Color("#ffd16b"),22)
                _upgrade_status(body,cost,preview.maximum)
                _button(actions,"Maximalstufe" if preview.maximum else "Verbessern\n%d G / %d Splitter"%[cost.gold,cost.shards],preview.affordable,func():_change(model.change_gear(item.id,"upgrade"),"Ausrüstung verbessert"),true)
                _button(actions,"Ablegen" if item.active else "Ausrüsten",true,func():_change(model.change_gear(category,"unequip") if item.active else model.change_gear(item.id),"Ausrüstung aktualisiert"))
            else:
                var d=model.HeroEquipment.CATALOG[item.id];_label(body,"Ab Level %d · %d G / %d Splitter"%[d.unlock,d.gold,d.shards],Color("#ffd16b"))
                _button(actions,"Eventbelohnung" if bool(d.get("event",false)) else "Freischalten",model.HeroEquipment.can_acquire(model.profile,item.id),func():_change(model.change_gear(item.id,"acquire"),"Ausrüstung freigeschaltet"),true)
        body.move_child(actions,body.get_child_count()-1)
        var comparison:BoxContainer=HBoxContainer.new() if get_tree().root.get_visible_rect().size.x>=1100 else VBoxContainer.new();comparison.add_theme_constant_override("separation",12);body.add_child(comparison)
        _preview_hero(comparison,"Aktuell",model.profile)
        var candidate=model.profile.duplicate(true)
        if category=="weapon":candidate.equipped=item.id
        else:
            if not candidate.hero_equipment.owned.has(item.id):candidate.hero_equipment.owned[item.id]={"id":item.id,"level":1,"source":"preview_only"}
            candidate.hero_equipment.equipped[category]=item.id
            candidate.hero_equipment.cosmetics.erase(category)
            if category=="chest":candidate.wardrobe.active=""
        var caption=("Rüstung ohne Kostüm: " if category=="chest" and Wardrobe.active(model.profile)!="" else "Mit ")+item.name
        if category=="wings" and model.profile.hero_equipment.owned.has(item.id):
            var next_level=mini(model.HeroEquipment.max_level(item.id),int(candidate.hero_equipment.owned[item.id].level)+1)
            candidate.hero_equipment.owned[item.id].level=next_level
            caption=("Endform" if next_level==16 and int(item.level)==16 else "Nächste Aufwertung")+" +%d"%(next_level-1)
        _preview_hero(comparison,caption,candidate)
        if category=="wings":_label(body,"Flügel +0 bis +15 · Jede Stufe wächst sichtbar. Seltenheit bleibt unverändert.",Color("#ffd16b"),20)
        _label(body,"Aussehen-Vorschau · Werte und Besitz ändern sich erst durch deine Aktion.",Color("#a9c1dc"),20)
    var grid=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12);list.add_child(grid)
    for item in items:
        var card=Card.new();card.configure(item);card.custom_minimum_size.x=140;grid.add_child(card);card.pressed.connect(func():selected=item.id;_build())
    if visible:call_deferred("_prepare_body")
    _restore_scroll(scroll,offset)
func _restore_scroll(target:ScrollContainer,offset:int) -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    if is_instance_valid(target) and target==scroll:target.scroll_vertical=offset
func _upgrade_status(parent:Control,cost:Dictionary,maximum:bool) -> void:
    if maximum:return
    var missing=[]
    if model.gold<int(cost.gold):missing.append("%d Gold"%(int(cost.gold)-model.gold))
    if int(model.profile.shards)<int(cost.shards):missing.append("%d Splitter"%(int(cost.shards)-int(model.profile.shards)))
    _label(parent,"Du besitzt %d G · %d Splitter"%[model.gold,model.profile.shards] if missing.is_empty() else "Es fehlen: "+" und ".join(missing),Kit.INK if missing.is_empty() else Color("#ffab91"),20)
func _change(ok:bool,message:String) -> void:
    if ok:changed.emit(message);_build(true)

func _preview_hero(parent:Control,caption:String,profile:Dictionary) -> void:
    var col=VBoxContainer.new();col.size_flags_horizontal=Control.SIZE_EXPAND_FILL;parent.add_child(col)
    _label(col,caption,Color("#ffd16b"),20)
    var stage=Control.new();stage.custom_minimum_size=Vector2(0,300);stage.clip_contents=true;col.add_child(stage)
    var bg=Panel.new();bg.add_theme_stylebox_override("panel",Kit.box("hero"));bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;stage.add_child(bg)
    var rig=preload("res://scripts/production_hero.gd").new();rig.name="EquipmentComparisonHero";rig.preview_mode=true;rig.z_index=4;stage.add_child(rig);rig.set_hero(model.hero_id);rig.equip_weapon(model.Equipment.IDS.find(str(profile.equipped)));rig.set_gear(profile);rig.scale=Vector2.ONE*(.48 if get_tree().root.get_visible_rect().size.x>=1100 else .64);rig.position=Vector2(110,280)
    stage.resized.connect(func():
        if is_instance_valid(rig):rig.position=Vector2(stage.size.x*.5-35,280))

func _build_costumes(list:VBoxContainer) -> void:
    if selected not in Wardrobe.IDS:selected=Wardrobe.IDS[0]
    var id=selected
    var d:Dictionary=Wardrobe.CATALOG[id]
    var owned=model.profile.wardrobe.owned.has(id)
    var active=Wardrobe.active(model.profile)
    var box=PanelContainer.new();box.add_theme_stylebox_override("panel",Kit.box("slot"));list.add_child(box)
    var body=VBoxContainer.new();body.add_theme_constant_override("separation",16);box.add_child(body)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",18);body.add_child(row)
    var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(Wardrobe.icon(id));art.custom_minimum_size=Vector2(160,190);row.add_child(art)
    var info=VBoxContainer.new();info.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(info)
    _label(info,d.name,Color(model.Economy.RARITIES[d.rarity].color),28)
    _label(info,d.description,Kit.INK,21)
    _label(body,"Rein kosmetisch · Keine Kampfboni · Deine Rüstung und ihre Aufwertungen bleiben angelegt.",Color("#a9c1dc"),21)
    if owned:
        var wear=_button(body,"Kostüm ablegen" if active==id else "Kostüm anlegen",true,func():_change(model.equip_costume("" if active==id else id),"Kostüm aktualisiert"),true)
        wear.name="CostumeEquip_"+id
    else:
        _label(body,"Dauerhaft kostenlos freispielen: "+d.requirement,Color("#ffd16b"),22)
        var progress="Gegner: %d / %d"%[mini(int(model.profile.kills),int(d.kills)),d.kills] if int(d.kills)>0 else "Kampfstufe: %d / %d"%[mini(int(model.profile.best_wave),int(d.wave)),d.wave]
        _label(body,progress,Kit.INK,21)
        var claim=_button(body,"Belohnung abholen",Wardrobe.ready(model.profile,id),func():_change(model.claim_costume(id),"Kostüm dauerhaft freigeschaltet"),true)
        claim.name="CostumeClaim_"+id
    var comparison:BoxContainer=HBoxContainer.new() if get_tree().root.get_visible_rect().size.x>=1100 else VBoxContainer.new();comparison.add_theme_constant_override("separation",12);body.add_child(comparison)
    _preview_hero(comparison,"Aktuell",model.profile)
    var candidate=model.profile.duplicate(true)
    candidate.wardrobe.owned[id]={"source":"preview_only"};candidate.wardrobe.active=id
    _preview_hero(comparison,"Vorschau: "+str(d.name),candidate)
    _label(body,"Die Vorschau ist kostenlos und verändert weder Besitz noch Fortschritt.",Color("#a9c1dc"),20)
    var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",14);list.add_child(grid)
    for costume in Wardrobe.IDS:
        var item=Wardrobe.CATALOG[costume]
        var card=Card.new();card.name="CostumeCard_"+costume
        card.configure({"id":costume,"name":item.name,"kind":"costume","rarity":item.rarity,"level":1,"progress_label":"Angelegt" if active==costume else ("Freigeschaltet" if model.profile.wardrobe.owned.has(costume) else "Vorschau"),"active":active==costume,"icon":Wardrobe.icon(costume)})
        card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(card)
        card.pressed.connect(func():selected=costume;_build())
