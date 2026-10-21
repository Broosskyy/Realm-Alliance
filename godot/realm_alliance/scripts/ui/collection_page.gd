extends "res://scripts/ui/touch_scroll.gd"
signal action(id:String)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Card=preload("res://scripts/ui/collection_card.gd")
const Art=preload("res://scripts/ui/item_illustration.gd")
var model
var content:VBoxContainer
var category="Helden"
var detail=""
var _key=""
var _height=1280.0
var _sticky:Button
func _ready() -> void:
    super._ready();theme=Kit.native_theme();content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",16);add_child(content)
    _sticky=Button.new();_sticky.name="CollectionStickyBack";_sticky.theme=Kit.native_theme();_sticky.z_index=44;_sticky.hide();_sticky.custom_minimum_size=Vector2(0,100)
    _sticky.add_theme_stylebox_override("normal",Kit.box("panel"));_sticky.pressed.connect(func():detail="";scroll_vertical=0;_reload())
    get_parent().call_deferred("add_child",_sticky)
func _process(delta:float) -> void:
    super._process(delta)
    if not is_instance_valid(_sticky):return
    _sticky.visible=is_visible_in_tree() and detail!="" and scroll_vertical>80
    _sticky.text="< Monsterbuch" if category=="Monster" else "< Sammlung · "+str(model.Roster.playable_catalog().get(detail,model.Companions.catalog().get(detail,{})).get("name",""));_sticky.position=position;_sticky.size=Vector2(size.x,100)
func _exit_tree() -> void:
    if is_instance_valid(_sticky):_sticky.queue_free()
func refresh(tab:String,value,height:float) -> void:
    model=value;visible=tab=="Wesen";position=Vector2(22,154);size=Vector2(676,height-274);_height=height
    if not visible:return
    var key=category+detail+JSON.stringify(model.profile)+str(height)
    if key==_key:return
    _key=key
    for child in content.get_children():content.remove_child(child);child.queue_free()
    if detail=="":_collection()
    else:_detail()
func _reload() -> void:
    _key="";refresh("Wesen",model,_height)
func _label(parent:Control,value:String,px:int=22,tint:Color=Kit.INK) -> Label:
    var l=Label.new();l.text=value;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",px);l.add_theme_color_override("font_color",tint);parent.add_child(l);return l
func _button(parent:Control,value:String,fn:Callable,selected:bool=false) -> Button:
    var b=Button.new();b.text=value;b.custom_minimum_size=Vector2(0,100);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.add_theme_font_size_override("font_size",19);b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    if selected:b.add_theme_stylebox_override("normal",Kit.box("primary"))
    parent.add_child(b);b.pressed.connect(fn);return b
func _portrait(id:String,hero:bool) -> Texture2D:
    if not hero:return load("res://assets/roster67/"+id+("/evolved_idle.png" if int(model.profile.companions.owned.get(id,{}).get("evolution",0))>0 else "/base_idle.png"))
    if id=="schattenjager":return preload("res://scripts/ui/item_art.gd").thumbnail("res://assets/expansion702/schattenjager/portrait.png")
    if id=="runenpaladin":return load("res://assets/roster68/runenpaladin/portrait.png")
    var art=AtlasTexture.new();art.atlas=load("res://assets/production/hero/idle.png");art.region=Rect2(300,90,260,245);return art
func _collection() -> void:
    var tabs=HBoxContainer.new();tabs.add_theme_constant_override("separation",12);content.add_child(tabs)
    for name in ["Helden","Monster","Begleiter"]:_button(tabs,name,func():category=name;scroll_vertical=0;_reload(),category==name)
    if category=="Monster":_monsters();return
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",16);content.add_child(row)
    var tools=VBoxContainer.new();tools.custom_minimum_size.x=96;tools.add_theme_constant_override("separation",14);row.add_child(tools)
    var labels=["Ausrüst.","Skills","Talente","Evolution","Kostüme"]
    var actions=["equipment","hero_skill_0","talents","evolve","equipment:costume"]
    for i in 5:
        var b=_button(tools,"",func():action.emit(actions[i]));b.custom_minimum_size=Vector2(104,120)
        var icon=TextureRect.new();icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.texture=load("res://assets/ui/work61/"+["swords","flame","star","crown","shield"][i]+".svg");icon.position=Vector2(28,12);icon.size=Vector2(40,40);icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;b.add_child(icon)
        var l=_label(b,labels[i],17);l.autowrap_mode=TextServer.AUTOWRAP_OFF;l.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;l.position=Vector2(0,74);l.size=Vector2(104,30);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var grid=GridContainer.new();grid.columns=2;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",14);grid.add_theme_constant_override("v_separation",16);row.add_child(grid)
    var hero=category=="Helden";var catalog=model.Roster.playable_catalog() if hero else model.Companions.catalog()
    for id in catalog:
        var card=Card.new();card.name="HeroCard_"+id;card.tooltip_text=catalog[id].name;card.display_name=catalog[id].name;card.illustration=_portrait(id,hero);card.owned=model.profile.hero_roster.owned.has(id) if hero else model.profile.companions.owned.has(id);card.active=id==model.hero_id if hero else id==str(model.profile.companions.active)
        var level=model.Roster.level(model.profile,id) if hero else model.Companions.level(model.profile,id)
        if hero:card.rarity=model.Mastery.rarity(model.profile,id);card.rank=model.Mastery.rank(model.profile,id);card.hero_card=true
        card.detail="Lv. %d · %s"%[level,catalog[id].role.split(" · ")[0]] if card.owned else "Freischaltung ansehen";card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(card);card.pressed.connect(func():detail=id;scroll_vertical=0;_reload())
    if hero:
        var coming=HBoxContainer.new();coming.add_theme_constant_override("separation",12);content.add_child(coming)
        for pair in [["Bogenklasse","Waldläufer"],["Magieklasse","Sternmagier"]]:
            var panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",Kit.box("slot"));panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL;coming.add_child(panel)
            _label(panel,pair[1]+"\n"+pair[0]+"\nIn Vorbereitung",21,Color("#9fb8cc"))
    if hero and model.Roster.can_adopt_starter(model.profile):
        _button(content,"Runenpaladin als Startheld übernehmen",func():action.emit("adopt_starter")).name="AdoptStarter709"
        _label(content,"Kostenfrei für frühere Teststände. Bisherige Helden und Fortschritte bleiben erhalten.",21,Color("#a9c1dc"))
    var active_id=model.hero_id if hero else str(model.profile.companions.active)
    _label(content,("Aktiver Held: "+catalog[active_id].name if hero else "Aktiver Begleiter: "+catalog[active_id].name if active_id!="" else "Kein Begleiter aktiv"),22,Color("#ffd16b"))
    _label(content,"Wähle eine Karte für Werte, Ausrüstung und Freischaltung. Dein laufender Kampf bleibt erhalten.",21,Color("#a9c1dc"))
func _detail() -> void:
    if category=="Monster":_monster_detail();return
    var hero=category=="Helden";var catalog=model.Roster.playable_catalog() if hero else model.Companions.catalog();var id=detail
    if not catalog.has(id):detail="";_reload();return
    var d=catalog[id];var owned=model.profile.hero_roster.owned.has(id) if hero else model.profile.companions.owned.has(id);var active=id==model.hero_id if hero else id==str(model.profile.companions.active)
    var header=HBoxContainer.new();content.add_child(header)
    var back=_button(header,"< Sammlung",func():detail="";scroll_vertical=0;_reload());back.custom_minimum_size.x=190;back.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
    var name=_label(header,d.name,28);name.custom_minimum_size.x=0;name.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    var level=model.Roster.level(model.profile,id) if hero else model.Companions.level(model.profile,id)
    if hero:_label(content,model.Economy.RARITIES[model.Mastery.rarity(model.profile,id)].name+" · "+model.Mastery.NAMES[model.Mastery.rank(model.profile,id)],23,Color(model.Economy.RARITIES[model.Mastery.rarity(model.profile,id)].color))
    var role=_label(content,d.role+" · Lv. %d"%level,22,Color("#a9c1dc"));role.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var showcase=Control.new();showcase.custom_minimum_size=Vector2(644,490);showcase.clip_contents=true;content.add_child(showcase)
    var bg=TextureRect.new();bg.texture=load("res://assets/work705/ruins_courtyard.webp");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;bg.size=Vector2(644,490);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;showcase.add_child(bg)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    if hero:
        var rig=preload("res://scripts/production_hero.gd").new();rig.name="CollectionHeroRig";rig.preview_mode=true;rig.z_index=4;showcase.add_child(rig);rig.set_hero(id);rig.equip_weapon(model.weapon_index);rig.set_gear(model.profile);rig.set_look(model.profile.look,false);rig.scale=Vector2.ONE*.76;rig.position=Vector2(270,432)
        preload("res://scripts/presentation/hero_preview_frame711.gd").fit(rig,Rect2(18,18,608,448))
        showcase.resized.connect(func():
            if is_instance_valid(rig):preload("res://scripts/presentation/hero_preview_frame711.gd").fit(rig,Rect2(18,18,showcase.size.x-36,showcase.size.y-42)))
        var preview=_button(content,"Angriff ansehen",func():rig.play_action("chain_0_1"));preview.name="HeroPreviewAttack"
        var slot_row=HBoxContainer.new();slot_row.name="CollectionEquipmentSlots";slot_row.add_theme_constant_override("separation",12);content.add_child(slot_row)
        var slots=["weapon","chest","head","wings"]
        for i in 4:
            var slot=slots[i];var item=str(model.profile.equipped) if slot=="weapon" else str(model.profile.hero_equipment.equipped.get(slot,""))
            var b=_button(slot_row,"",func():action.emit("equipment:"+slot));b.name="EquippedSlot_"+slot;b.set_meta("equipped_item",item);b.custom_minimum_size=Vector2(0,126);b.z_index=30
            if item!="":
                var path="res://assets/production/weapons/"+item+".png" if slot=="weapon" else "res://assets/equipment/"+item+".png"
                var icon=Art.new();icon.configure(path);icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);icon.offset_left=14;icon.offset_right=-14;icon.offset_top=6;icon.offset_bottom=-39;icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;b.add_child(icon)
                b.tooltip_text=model.Equipment.definition(item).name if slot=="weapon" else model.HeroEquipment.CATALOG[item].name
            else:
                var empty=_label(b,"Leer",18,Color("#a9c1dc"));empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);empty.offset_top=22;empty.offset_bottom=-40;empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;empty.mouse_filter=Control.MOUSE_FILTER_IGNORE
            var label=_label(b,["Waffe","Rüstung","Kopf","Flügel"][i],18);label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);label.offset_top=-34;label.offset_bottom=-6;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
    else:
        var pet=preload("res://scripts/presentation/companion_visual.gd").new();pet.name="CompanionPreview";showcase.add_child(pet);pet.position=Vector2(322,465);pet.scale=Vector2.ONE*.90
        var evolved=int(model.profile.companions.owned.get(id,{}).get("evolution",0))>0
        pet.configure_preview(id,evolved)
        var previews=HBoxContainer.new();previews.add_theme_constant_override("separation",12);content.add_child(previews)
        var cast=_button(previews,"Fähigkeit ansehen",func():pet.cast(1.1));cast.name="CompanionPreviewCast"
        var form=_button(previews,"Basisform ansehen" if evolved else "Entwicklung ansehen",func():pass);form.name="CompanionPreviewForm"
        var caption=_label(content,"Vorschau · "+("Entwickelte Form" if evolved else "Basisform"),20,Color("#a9c1dc"));caption.name="CompanionPreviewCaption"
        form.pressed.connect(func():
            pet.configure_preview(id,not pet.preview_evolved)
            form.text="Basisform ansehen" if pet.preview_evolved else "Entwicklung ansehen"
            caption.text="Vorschau · "+("Entwickelte Form" if pet.preview_evolved else "Basisform")
        )
    if hero:
        var develop=_button(content,"Level & Aufstiegsrang",func():action.emit("develop:"+id),true);develop.name="HeroDevelopment"
        var values=model.hero_preview_stats(id)
        var power=_label(content,"Kraft %d%s"%[values.power," · Vorschau" if not active else ""],28,Color("#ffd16b"));power.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        var stats=HBoxContainer.new();stats.add_theme_constant_override("separation",12);content.add_child(stats)
        for pair in [["HP",values.hp],["Angriff",values.attack],["DEF",values.defense]]:
            var panel=PanelContainer.new();panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL;panel.add_theme_stylebox_override("panel",Kit.box("slot"));stats.add_child(panel)
            var value=_label(panel,"%s\n%d"%[pair[0],pair[1]],24);value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    else:
        var strength=model.Companions.strength(model.profile,id)
        var effect="Salve: %d Schaden"%maxi(1,roundi(model.hero_damage()*float(d.attack_scale)*strength)) if float(d.attack_scale)>0 else "Heilung: bis zu %d HP"%roundi(model.player_max_hp*float(d.heal_fraction)*strength)
        _label(content,"%s · alle %.1f s"%[effect,d.interval],24,Color("#ffd16b"))
        var evolution=int(model.profile.companions.owned.get(id,{}).get("evolution",0))
        _label(content,"Entwickelt" if evolution>0 else "Basisform · Entwicklung ab Begleiterlevel 3",21,Color("#a9c1dc"))
    _label(content,d.description,21,Color("#a9c1dc"))
    if owned:
        var switch=_button(content,"Aktiv" if active else "Held wechseln" if hero else "Begleiter wechseln",func():action.emit(("hero_select:" if hero else "pet_select:")+id),true);switch.disabled=active or model.read_only
        if not hero:
            var evolve=_button(content,"Entwickeln · Lv.3 + Gartenkoloss · 100 G / 6 Splitter",func():action.emit("pet_evolve:"+id));evolve.disabled=not model.Companions.can_evolve(model.profile,id) or model.read_only
            if active:_button(content,"Begleiter ablegen",func():action.emit("pet_select:"))
    else:
        var gate="Ab Level %d · %d Gold / %d Splitter"%[d.unlock_level,d.gold,d.shards]
        if d.stage!="":var parts=str(d.stage).split(":");gate+=" · "+model.World.NAMES[parts[0]]+" %d"%(int(parts[1])+1)
        _label(content,gate,21,Color("#ffd16b"))
        var unlock=_button(content,"Im Eventshop erhältlich" if bool(d.get("event",false)) else "Freischalten",func():action.emit(("hero_unlock:" if hero else "pet_unlock:")+id),true);unlock.disabled=model.read_only or (not model.Roster.can_unlock(model.profile,id) if hero else not model.Companions.can_acquire(model.profile,id))
    var tools=GridContainer.new();tools.columns=3;tools.add_theme_constant_override("h_separation",12);tools.add_theme_constant_override("v_separation",12);content.add_child(tools)
    if hero:
        for pair in [["Skills","hero_skill_0"],["Ausrüstung","equipment"],["Entwicklung","develop:"+id],["Kostüme","equipment:costume"],["Farbstil","look"]]:_button(tools,pair[0],func():action.emit(pair[1]))

func _monsters() -> void:
    var bestiary=model.Bestiary
    _label(content,"Monsterbuch · %d / %d entdeckt"%[bestiary.discovered(model.profile),bestiary.catalog().size()],25,Color("#ffd16b"))
    _label(content,"Besiege Gegner und meistere ihre Einträge. Für 5, 15 und 30 Siege warten einmalige Belohnungen.",21,Color("#a9c1dc"))
    var grid=GridContainer.new();grid.columns=2;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",14);grid.add_theme_constant_override("v_separation",16);content.add_child(grid)
    for id in bestiary.catalog():
        var d=bestiary.catalog()[id];var kills=bestiary.count(model.profile,id)
        var card=Card.new();card.name="MonsterCard_"+id;card.display_name=d.name if kills>0 else "Unentdeckt";card.illustration=load(bestiary.art(id));card.owned=kills>0;card.active=bestiary.can_claim(model.profile,id)
        card.detail="%d Siege · Rang %d/3"%[kills,bestiary.rank(model.profile,id)] if kills>0 else d.location
        card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(card);card.pressed.connect(func():detail=id;scroll_vertical=0;_reload())

func _monster_detail() -> void:
    var bestiary=model.Bestiary
    if not bestiary.catalog().has(detail):detail="";_reload();return
    var id=detail;var d=bestiary.catalog()[id];var kills=bestiary.count(model.profile,id);var rank=bestiary.rank(model.profile,id)
    _button(content,"< Monsterbuch",func():detail="";scroll_vertical=0;_reload())
    _label(content,d.name,30,Color("#ffd16b"));_label(content,d.location+" · "+{"normal":"Normal","elite":"Elite","boss":"Boss"}[d.kind],22)
    var illustration=Art.new();illustration.name="MonsterPortrait";illustration.configure(bestiary.art(id));illustration.custom_minimum_size=Vector2(0,360);illustration.mouse_filter=Control.MOUSE_FILTER_IGNORE
    if kills==0:illustration.modulate=Color(.25,.3,.4)
    content.add_child(illustration)
    _label(content,"%d Siege · Meisterschaft %d/3"%[kills,rank],25,Color("#ffd16b"))
    if kills>0:_label(content,"Basiswerte · %d HP · %d Angriff\nAngriff alle %.1f s · %s"%[d.hp,d.damage,d.interval,{"single":"Einzelhieb","double":"Doppelhieb","heavy":"Schwerer Hieb","eruption":"Eruption"}.get(d.pattern,d.pattern)],22)
    else:_label(content,"Besiege diesen Gegner, um seinen Eintrag zu entdecken.",22,Color("#a9c1dc"))
    var goal=int(bestiary.GOALS[mini(rank,2)])
    var card=preload("res://scripts/ui/progress_card.gd").new()
    card.configure("Meisterschaft vollständig" if rank==3 else "Nächste Meisterschaft","Alle Belohnungen erhalten." if rank==3 else "%d Gold + %d Himmelssplitter"%[bestiary.GOLD[rank],bestiary.SHARDS[rank]],"res://assets/work706/items/mastery_medallion.tres",kills,goal);content.add_child(card)
    var claim=_button(card.body,"Alle Ränge erhalten" if rank==3 else "Belohnung abholen",func():action.emit("bestiary_claim:"+id),true);claim.name="BestiaryClaim";claim.disabled=model.read_only or not bestiary.can_claim(model.profile,id)
    _button(content,"Dungeon ansehen" if d.region=="event" else "Zur Weltkarte",func():action.emit("activities" if d.region=="event" else "Abenteuer"))
