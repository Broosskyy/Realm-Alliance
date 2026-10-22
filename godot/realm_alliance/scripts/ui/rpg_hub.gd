extends "res://scripts/ui/modal_dialog.gd"
class_name RARPGHub
const RemoteArt=preload("res://scripts/launcher/content_cache714.gd")
const ExtraContent=preload("res://scripts/launcher/content_cache715.gd")
signal changed(message:String)
signal activity_requested(id:String)
signal leave_requested
signal hero_development_requested
var model
var tabs:TabContainer
var current=0

func configure(value,start:int=0) -> void:
    game_page=true
    model=value;current=start;title=["Shop","Schmiede","Dungeons","Reise & Erfolge"][start];ok_button_text="Schließen";get_cancel_button().hide()
    confirmed.connect(queue_free);canceled.connect(queue_free);_build()
func _label(parent:Control,text:String,color:Color=Kit.INK) -> void:
    var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_font_size_override("font_size",21);l.add_theme_color_override("font_color",color);parent.add_child(l)
func _button(parent:Control,text:String,enabled:bool,callback:Callable) -> Button:
    var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.custom_minimum_size.y=100;b.disabled=not enabled or model.read_only;b.pressed.connect(callback);parent.add_child(b);return b
func _card(parent:Control,name:String,detail:String,icon:String="") -> VBoxContainer:
    var panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",Kit.box("slot"));parent.add_child(panel)
    var col=VBoxContainer.new();col.add_theme_constant_override("separation",12);panel.add_child(col)
    if not icon.is_empty():
        var row=HBoxContainer.new();row.add_theme_constant_override("separation",18);col.add_child(row)
        var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(icon);art.custom_minimum_size=Vector2(156,164);row.add_child(art)
        var text=VBoxContainer.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(text);_label(text,name,Color("#ffd16b"));_label(text,detail)
    else:_label(col,name,Color("#ffd16b"));_label(col,detail)
    return col
func _icon(d:Dictionary) -> String:
    if d.kind=="weapon":return "res://assets/production/weapons/"+d.item+".png"
    if d.kind=="gear":return "res://assets/equipment/"+d.item+".png"
    if d.kind=="pet":return "res://assets/roster67/"+d.item+"/base_idle.png"
    return model.Economy.MATERIALS[d.item].icon
func _build() -> void:
    if tabs:current=tabs.current_tab;tabs.get_parent().remove_child(tabs);tabs.queue_free()
    tabs=TabContainer.new();tabs.custom_minimum_size=Vector2(540,700);add_child(tabs)
    for name in ["Shop","Schmiede","Dungeons","Reise"]:
        var scroll=preload("res://scripts/ui/touch_scroll.gd").new();scroll.name=name;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;tabs.add_child(scroll)
        var list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",18);scroll.add_child(list)
        _label(list,"%d Gold · %d Splitter"%[model.gold,model.profile.shards],Color("#ffd16b"))
        _label(list,"Staub %d · Glutkerne %d · Erntezeichen %d"%[model.profile.economy.materials.forge_dust,model.profile.economy.materials.ember_core,model.profile.economy.materials.harvest_token])
        if name in ["Shop","Schmiede"]:
            var table=model.Economy.OFFERS if name=="Shop" else model.Economy.RECIPES
            var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",14);grid.add_theme_constant_override("v_separation",18);list.add_child(grid)
            for id in table:
                var d:Dictionary=table[id];var owned=model.Economy.owned(model.profile,d)
                var panel=PanelContainer.new();panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL;panel.add_theme_stylebox_override("panel",Kit.box("slot"));grid.add_child(panel)
                var card=VBoxContainer.new();card.add_theme_constant_override("separation",12);card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;panel.add_child(card)
                var art=preload("res://scripts/ui/item_illustration.gd").new();art.configure(_icon(d));art.custom_minimum_size=Vector2(220,188);card.add_child(art)
                _label(card,d.name,Color("#ffd16b"));_label(card,"Ab Lv. %d"%d.level,Color("#a9bed7"));_label(card,model.Economy.cost_text(d))
                var kind="shop" if name=="Shop" else "craft"
                var buy=_button(card,"Im Besitz" if owned else "Kaufen" if kind=="shop" else "Herstellen",not owned and model.Economy.affordable(model.profile,d),func():_confirm_command(kind,id,d));buy.add_theme_stylebox_override("normal",Kit.box("secondary"))
        elif name=="Dungeons":_activities(list)
        else:_journey(list)
    tabs.current_tab=current
    if visible:call_deferred("_prepare_body")

func _confirm_command(kind:String,id:String,d:Dictionary) -> void:
    var receipt=model.Economy.nonce(model.profile)
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new();add_child(dialog)
    dialog.title=d.name;dialog.dialog_text="%s\n\nKosten: %s\nEin garantierter Gegenstand wird direkt gutgeschrieben."%["Kaufen" if kind=="shop" else "Herstellen",model.Economy.cost_text(d)];dialog.ok_button_text="Bestätigen";dialog.cancel_button_text="Zurück"
    dialog.confirmed.connect(func():
        if model.economy_command(kind,id,receipt):changed.emit(d.name+" erhalten");_build()
        dialog.queue_free())
    dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(570,350))

func _activities(list:Control) -> void:
    _label(list,"Dein Hauptkampf wird beim Betreten angehalten und bei Rückkehr exakt fortgesetzt.")
    if not model.activity.is_empty():_button(list,"Zum Hauptabenteuer zurückkehren",true,func():leave_requested.emit();queue_free())
    for id in model.Activities.CATALOG:
        var d:Dictionary=model.Activities.CATALOG[id]
        var artwork={"gold_vault":"res://assets/work704/ui/shop.png","ember_forge":"res://assets/world65/glutkern.webp","colossus_trial":"res://assets/work704/ui/dungeons.png"}
        var card=_card(list,d.name,d.description,"res://assets/events69/harvest_world.webp" if d.has("event") else artwork[id])
        _label(card,"Bonus: %d Gold · %d Staub · Wächtertruhe\nAbschluss: %d×"%[d.gold,d.forge_dust,model.profile.activities.clears.get(id,0)])
        if model.profile.activities.best_seconds.has(id):_label(card,"Bestzeit: %.1f s"%model.profile.activities.best_seconds[id])
        var parts=str(d.unlock).split(":")
        _button(card,"Betreten" if model.Activities.unlocked(model.profile,id) else "%s · Stage %d benötigt"%[model.World.NAMES[parts[0]],int(parts[1])+1],model.activity.is_empty() and model.Activities.unlocked(model.profile,id),func():activity_requested.emit(id);queue_free())

    var event_id="harvest_2026"
    var pack=model.Events.pack(model.profile.duplicate(true),event_id)
    _label(list,model.Events.catalog()[event_id].name,Color("#ffd16b"))
    for quest in model.Events.catalog()[event_id].quests:
        var card=_card(list,quest.name,"%d/%d · %d Erntezeichen + Eventtruhe"%[mini(int(quest.goal),int(pack[quest.metric])),quest.goal,quest.tokens])
        _button(card,"Erhalten" if pack.claimed.has(quest.id) else "Questbelohnung",model.Events.can_claim(model.profile.duplicate(true),event_id,quest.id),func():
            if not model.read_only and model.Events.claim(model.profile,event_id,quest.id):changed.emit("Eventbelohnung erhalten");_build())

func _journey(list:Control) -> void:
    var catalog=ExtraContent.catalog()
    if not catalog.is_empty():
        for item in catalog.items:
            var card=_card(list,"Live-Inhalt · "+str(item.name),str(item.description))
            var texture=ExtraContent.texture(str(item.art))
            if texture!=null:
                var preview=TextureRect.new()
                preview.name="LiveContentImage715"
                preview.texture=texture
                preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
                preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                preview.custom_minimum_size=Vector2(0,176)
                card.add_child(preview)
    # Rein kosmetische 2D-Ankündigung aus nachgeladenem, SHA-geprüftem Inhalt.
    var remote=RemoteArt.last()
    if not remote.is_empty():
        var card=_card(list,"Neuigkeiten · "+str(remote.title),str(remote.message))
        var tex=RemoteArt.preview_texture()
        if tex!=null:
            var banner=TextureRect.new()
            banner.name="LiveContentBanner714"
            banner.texture=tex
            banner.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
            banner.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            banner.custom_minimum_size=Vector2(0,142)
            banner.size_flags_horizontal=Control.SIZE_EXPAND_FILL
            card.add_child(banner)
    var now=int(Time.get_unix_time_from_system())
    if not model.read_only:model.Journey.refresh(model.profile,now)
    _card(list,"Dein nächstes Ziel",model.Journey.next_goal(model.profile))
    _label(list,"Lokale Aktivitäten · Tageswechsel 00:00 UTC, Woche ab Montag. Die Uhr wird rückwärts nicht zurückgesetzt.")
    for id in ["login","daily","weekly"]:
        var detail={"login":"Tägliche Anmeldung · 25 Gold / 1 Splitter","daily":"10 Gegner heute · 80 Gold / 3 Splitter","weekly":"5 Bosse diese Woche · 250 Gold / 8 Splitter"}[id]
        var value={"login":"","daily":"%d/10"%mini(10,int(model.profile.journey.daily_kills)),"weekly":"%d/5"%mini(5,int(model.profile.journey.weekly_bosses))}[id]
        var card=_card(list,detail,value)
        _button(card,"Erhalten" if model.profile.journey.claimed.has(id) else "Abholen",model.Journey.can_claim(model.profile,id,now),func():
            if model.journey_command("claim",id):changed.emit("Reisebelohnung erhalten");_build())
    var rank=model.Mastery.rank(model.profile,model.hero_id)
    var evolution_card=_card(list,"Heldenaufstieg",model.hero_name+" · "+model.Mastery.NAMES[rank])
    _label(evolution_card,"Eigene XP und fünf Aufstiegsränge je Held.")
    _button(evolution_card,"Heldenentwicklung öffnen",true,func():hero_development_requested.emit())
    if model.Evolution.highest(model.profile)>0:
        _label(list,"Vermächtnisformen · Freischaltungen früherer Versionen",Color("#a9c1dc"))
        for form in model.profile.hero_evolution.unlocked:
            _button(list,model.Evolution.NAMES[model.Evolution.FORMS.find(form)],model.profile.hero_evolution.active!=form,func():
                if model.journey_command("form",form):changed.emit("Vermächtnisform gewechselt");_build())
    _label(list,"Spezialisierung · ab Level 8. Erste Wahl frei, Wechsel 100 Gold.",Color("#ffd16b"))
    for id in model.Journey.SPECIALIZATIONS:
        var d:Dictionary=model.Journey.SPECIALIZATIONS[id]
        var card=_card(list,d.name,d.description)
        _button(card,"Aktiv" if model.profile.journey.specialization==id else "Wählen",model.level>=8 and model.profile.journey.specialization!=id,func():
            if model.journey_command("specialize",id):changed.emit("Spezialisierung: "+d.name);_build())
    _label(list,"Titel · durch echte Erfolge verdienen",Color("#ffd16b"))
    for id in model.Journey.TITLES:
        var d:Dictionary=model.Journey.TITLES[id]
        var card=_card(list,d.name,"%d / %d %s"%[mini(int(d.goal),int(model.profile.journey.metrics[d.metric])),d.goal,{"crafts":"Herstellungen","dungeons":"Dungeon-Siege","boss_trials":"Bossprüfungen"}[d.metric]])
        _button(card,"Ausgewählt" if model.profile.journey.title==id else "Anzeigen",model.Journey.earned(model.profile,id) and model.profile.journey.title!=id,func():
            if model.journey_command("title",id):changed.emit("Titel: "+d.name);_build())
