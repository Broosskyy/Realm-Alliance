extends Control
class_name RACombatHUD

# Authored at 720 logical pixels; main.gd scales this native Godot UI once.
# All input regions are real Buttons, kept separate from paint and arena input.
signal action(id: String)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const FantasyButton=preload("res://scripts/ui/fantasy_button.gd")
const SkillOrb=preload("res://scripts/ui/skill_orb.gd")
const EquipmentSlot=preload("res://scripts/ui/equipment_slot.gd")
const ResourceBar=preload("res://scripts/ui/resource_bar.gd")
const ROOT = "res://assets/ui/work61/"
const INK = Color("#eaf3ff")
const MUTED = Color("#9fbbd8")
const CYAN = Color("#31d9ff")
const PURPLE = Color("#b65cff")
const GOLD = Color("#ffd16b")
var font: Font = preload("res://assets/ui/work61/fonts/DejaVuSans.ttf")
var bold: Font = preload("res://assets/ui/work61/fonts/DejaVuSans-Bold.ttf")
var icons: Dictionary = {}
var orbs: Array[Texture2D] = []
var buttons: Dictionary = {}
const Progress = preload("res://scripts/systems/player_progress.gd")
const Equipment = preload("res://scripts/systems/equipment.gd")
const HeroEquipment=preload("res://scripts/systems/hero_equipment.gd")
const Evolution=preload("res://scripts/systems/hero_evolution.gd")
const HeroPreview = preload("res://scripts/production_hero.gd")
var preview
var collection_page
var rpg_pages
var toast
var sound_enabled: bool = true
var effect_level: int = 0
var hit_flash: float = 0.0
var model
var auto_enabled = true
var qa_mode:bool=false
var active_tab = "Kampf"
var logical_height = 1280.0
var controls_top = 1000.0
var toast_title = "Wolkgarten entdeckt"
var toast_detail = "Tippe in die Arena zum Angriff"
var toast_until = 0
var toast_tab = "Kampf"
var cooldowns: Array = [0, 0, 0]
var durations: Array = [5.5, 8.0, 15.0]
var momentum = 0.0
var rage = 0.0
var hero_texture: Texture2D
var weapon_texture: Texture2D
var portrait: Texture2D
var guardian_portrait:Texture2D
var companion_preview
var _top_fade: GradientTexture2D
var _bottom_fade: GradientTexture2D
var _redraw_clock = 0.0
var _preview_key=""
var _textures: Dictionary={}
var _last_tab=""
var _menu_transition: Tween
var _veil: ColorRect
var shell_scroll: ScrollContainer
var shell_canvas: Control
var _paint_target: Control
var _shell_offsets: Dictionary = {}
const SHELL_ACTIONS = ["community","roster", "weapon", "upgrade", "look", "aura", "talents", "evolve", "journey", "admin", "quests", "events", "save_export", "save_import", "sound", "effects", "combat_options", "economy", "activities", "more_forge", "more_heroes", "more_pets", "more_talents"]

func _texture(path: String) -> Texture2D:
    if not _textures.has(path):_textures[path]=load(path)
    return _textures[path]

func _ready() -> void:
    _paint_target = self
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    for id in ["gold", "gem", "shard", "mountain", "swords", "map", "paw", "chest", "grid", "gear", "mail", "flame", "shield", "rock", "lock", "star", "arrow", "heart", "eye", "crown"]:
        icons[id] = load(ROOT + id + ".svg")
    for id in ["slash", "eye", "locked", "rage"]:
        orbs.append(load(ROOT + "skill_" + id + ".png"))
    if ResourceLoader.exists("res://assets/production/hero/idle.png"):
        hero_texture = load("res://assets/production/hero/idle.png")
        portrait = AtlasTexture.new()
        portrait.atlas = hero_texture
        portrait.region = Rect2(310, 25, 230, 220)
        guardian_portrait=portrait
    _top_fade = _fade(Color(0.015, 0.055, 0.12, 0.92), Color(0.015, 0.055, 0.12, 0.0))
    _bottom_fade = _fade(Color(0.015, 0.035, 0.07, 0.0), Color(0.015, 0.035, 0.07, 0.99))
    for id in ["mail", "settings", "auto", "skill0", "skill1", "locked", "skill2", "Kampf", "Abenteuer", "Wesen", "Beute", "Mehr", "weapon", "upgrade", "return", "quests", "events", "restart", "look", "aura", "sound", "effects", "save_export", "save_import", "equip_steel", "equip_crystal", "equip_ember", "equip_rune_gold", "equip_shadow_violet", "gear_astral_plate", "gear_eclipse_plate", "gear_sentinel_circlet", "gear_sky_wings", "evolve", "hero_skill_0", "hero_skill_1", "hero_skill_2", "hero_skill_3", "talents", "hit_mode", "ultimate", "combat_options", "roster", "admin", "journey"]:
        var b = SkillOrb.new() if id in ["skill0","skill1","skill2","locked"] else (EquipmentSlot.new() if id.begins_with("equip_") or id.begins_with("gear_") or id in ["evolve","talents"] else FantasyButton.new())
        b.name = "Action_" + id
        b.text = ""
        b.tooltip_text = _tooltip(id)
        b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        for state in ["normal", "hover", "pressed", "disabled"]:
            b.add_theme_stylebox_override(state, StyleBoxEmpty.new())
        var focus = StyleBoxFlat.new()
        focus.bg_color = Color(0.05, 0.5, 0.8, 0.08)
        focus.border_color = CYAN
        focus.set_border_width_all(2)
        focus.set_corner_radius_all(12)
        b.add_theme_stylebox_override("focus", focus)
        b.pressed.connect(func(): action.emit(id))
        buttons[id] = b
        add_child(b)
    for id in ["community","economy","activities","more_forge","more_heroes","more_pets","more_talents"]:
        if buttons.has(id):continue
        var button=FantasyButton.new();button.name="Action_"+id;button.pressed.connect(func():action.emit(id));buttons[id]=button;add_child(button)
    shell_scroll=preload("res://scripts/ui/touch_scroll.gd").new();shell_scroll.name="ShellScroll"
    shell_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    shell_scroll.follow_focus=true;shell_scroll.scroll_deadzone=2147483647
    add_child(shell_scroll)
    var page=Control.new();page.custom_minimum_size=Vector2(700,1584);page.size_flags_horizontal=Control.SIZE_EXPAND_FILL;page.mouse_filter=Control.MOUSE_FILTER_IGNORE;shell_scroll.add_child(page)
    shell_canvas=Control.new();shell_canvas.position=Vector2(0,-96);shell_canvas.size=Vector2(720,1680);shell_canvas.mouse_filter=Control.MOUSE_FILTER_IGNORE;page.add_child(shell_canvas)
    shell_canvas.draw.connect(_paint_shell)
    for id in buttons:
        if id in SHELL_ACTIONS or id.begins_with("gear_") or id.begins_with("equip_") or id.begins_with("hero_skill_"):
            buttons[id].reparent(shell_canvas,false)
    if hero_texture:
        preview = HeroPreview.new()
        preview.name = "EquippedHeroPreview"
        preview.preview_mode=true
        preview.z_index = 20
        preview.position = Vector2(280,589)
        preview.scale = Vector2.ONE * 0.62
        preview.visible = false
        shell_canvas.add_child(preview)
    companion_preview=preload("res://scripts/presentation/companion_visual.gd").new();companion_preview.position=Vector2(485,589);companion_preview.scale=Vector2.ONE*.22;companion_preview.z_index=21;shell_canvas.add_child(companion_preview)
    rpg_pages=preload("res://scripts/ui/rpg_pages.gd").new();rpg_pages.name="RPGPages";rpg_pages.z_index=40;add_child(rpg_pages);rpg_pages.action.connect(func(id):action.emit(id))
    collection_page=preload("res://scripts/ui/collection_page.gd").new();collection_page.name="HeroCollection";collection_page.z_index=40;add_child(collection_page);collection_page.action.connect(func(id):action.emit(id))
    toast=preload("res://scripts/ui/notification_toast.gd").new()
    toast.name="NotificationToast"
    add_child(toast)
    _veil=ColorRect.new();_veil.name="MenuTransition";_veil.color=Color("#06213d");_veil.mouse_filter=Control.MOUSE_FILTER_IGNORE;_veil.z_index=90;_veil.modulate.a=0;add_child(_veil)
    configure(1280.0)
    toast_until = Time.get_ticks_msec()+3500

func _tooltip(id: String) -> String:
    return {"auto":"Automatischen Standardangriff umschalten", "skill0":"Himmelsklinge · 2,8× Schaden", "skill1":"Arkanblick · 25 Momentum · 5s Markierung (+35% Schaden)", "skill2":"Zornesflamme · 40 Zorn · 4s Brennen", "locked":"Wächterwall · Ab Level 2 · 20 Momentum", "weapon":"Separates Schwert wechseln", "upgrade":"Angriff mit Gold aufwerten", "return":"Zurück zum Kampf", "mail":"Aufgaben und Belohnungen", "settings":"Einstellungen", "quests":"Aufgaben", "events":"Events"}.get(id, id)

func _fade(a: Color, b: Color) -> GradientTexture2D:
    var g = Gradient.new()
    g.set_color(0, a)
    g.set_color(1, b)
    var t = GradientTexture2D.new()
    t.gradient = g
    t.fill_from = Vector2(0, 0)
    t.fill_to = Vector2(0, 1)
    return t

func configure(height: float) -> void:
    logical_height = height
    controls_top = height - 356.0
    size = Vector2(720, height)
    if buttons.is_empty():
        return
    _place("hit_mode",Rect2(18,controls_top-106,140,100))
    _place("ultimate",Rect2(538,controls_top-106,160,100))
    _place("combat_options",Rect2(38,1035,644,88))
    _place("admin",Rect2(368,622,314,88))
    _place("mail", Rect2(526, 6, 88, 88))
    _place("settings", Rect2(622, 6, 88, 88))
    _place("auto", Rect2(614, controls_top - 6, 100, 100))
    for i in 4:
        var ids = ["skill0", "skill1", "locked", "skill2"]
        _place(ids[i], Rect2(34 + i * 174, controls_top + 94, 130, 142))
    for i in 5:
        _place(["Kampf", "Abenteuer", "Wesen", "Beute", "Mehr"][i], Rect2(i * 144 + 4, height - 106, 136, 100))
    _place("sound",Rect2(38,910,312,62))
    _place("effects",Rect2(370,910,312,62))
    _place("save_export",Rect2(38,760,312,62))
    _place("save_import",Rect2(370,760,312,62))
    _place("restart", Rect2(170, 570, 380, 62))
    _place("look", Rect2(38, 733, 310, 58))
    _place("aura", Rect2(368, 733, 314, 58))
    for i in 5:
        _place("equip_"+Equipment.IDS[i], Rect2(38+(i%2)*332, 813+floori(i/2.0)*76, 312, 66))
    _place("weapon", Rect2(38, 644, 310, 64))
    _place("upgrade", Rect2(368, 644, 314, 64))
    _place("return", Rect2(38, height - 188, 644, 62))
    _place("quests", Rect2(38, 204, 312, 88))
    _place("events", Rect2(370, 204, 312, 88))
    if _veil:_veil.position=Vector2(0,96);_veil.size=Vector2(720,height-192)
    shell_scroll.position=Vector2(0,96);shell_scroll.size=Vector2(720,maxf(200,height-214))
    update_buttons()
    queue_redraw()

func _place(id: String, r: Rect2) -> void:
    buttons[id].position = r.position
    buttons[id].size = r.size

func update_buttons() -> void:
    if buttons.is_empty() or model == null:
        return
    var in_combat = active_tab == "Kampf"
    buttons.hit_mode.visible=in_combat;buttons.ultimate.visible=in_combat
    buttons.journey.visible=active_tab=="Mehr"
    _place("journey",Rect2(38,622,312,88))
    buttons.combat_options.visible=active_tab=="Mehr"
    buttons.admin.visible=OS.is_debug_build() and active_tab=="Mehr"
    buttons.ultimate.disabled=not model.Tap.ultimate_unlocked(model.profile) or model.tap.charge<100 or model.clock<model.tap.ultimate_at or model.outcome!="fighting"
    buttons.ultimate.tooltip_text="Sternenfall · 4,8× Schaden · 100 Ladung · 16 s Abklingzeit"
    buttons.hit_mode.tooltip_text="x2: Level 3 + Elite · x4: Level 6 + Gartenkoloss · mehrere echte Treffer"
    shell_scroll.visible=active_tab=="Mehr"
    if _last_tab!=active_tab:
        if _last_tab in ["Wesen","Mehr"]:_shell_offsets[_last_tab]=shell_scroll.scroll_vertical
        shell_scroll.set_deferred("scroll_vertical",int(_shell_offsets.get(active_tab,0)))
        if _menu_transition:_menu_transition.kill()
        if _veil:
            _veil.modulate.a=.18 if effect_level==0 and _last_tab!="" else 0
            if _veil.modulate.a>0:
                _menu_transition=create_tween();_menu_transition.tween_property(_veil,"modulate:a",0.0,.18)
        _last_tab=active_tab
    if rpg_pages:rpg_pages.refresh(active_tab,model,logical_height)
    if collection_page:collection_page.refresh(active_tab,model,logical_height)
    if toast:
        toast.visible=toast_until>Time.get_ticks_msec() and (in_combat or toast_tab==active_tab)
        toast.position=Vector2(176,286) if in_combat else Vector2(38,logical_height-250)
        toast.size=Vector2(368,54) if in_combat else Vector2(644,40)
        toast.display(toast_title,toast_detail,in_combat)
    buttons.roster.visible=active_tab=="Wesen";buttons.roster.tooltip_text="Helden & Begleiter anzeigen und ohne Neustart wechseln";_place("roster",Rect2(38,155,644,100))
    portrait=_texture("res://assets/expansion702/schattenjager/portrait.png") if model.hero_id=="schattenjager" else (_texture("res://assets/roster68/runenpaladin/portrait.png") if model.hero_id=="runenpaladin" else guardian_portrait)
    if companion_preview:
        companion_preview.sync(model.profile,Time.get_ticks_msec()/1000.0);companion_preview.visible=active_tab=="Wesen" and str(model.profile.companions.active)!=""
    if preview:
        preview.visible = active_tab == "Wesen"
        var visual_key=model.hero_id+str(model.weapon_index)+str(model.upgrade_level)+str(model.profile.look)+str(model.profile.aura)+str(model.level)+JSON.stringify(model.profile.hero_equipment)+JSON.stringify(model.profile.hero_evolution)
        visual_key+=str(model.Economy.enchant_bonus(model.profile,model.profile.equipped))+JSON.stringify(model.profile.hero_mastery)
        if preview.visible and visual_key!=_preview_key:
            _preview_key=visual_key
            preview.set_hero(model.hero_id)
            preview.equip_weapon(model.weapon_index)
            preview.set_upgrade_tier(model.upgrade_level+int(model.Economy.enchant_bonus(model.profile,model.profile.equipped)/2))
            preview.set_look(model.profile.look,bool(model.profile.aura) and model.level>=3)
            preview.set_gear(model.profile)
    buttons.gear_eclipse_plate.hide()
    var slots=["chest","head","wings"]
    var representatives=["astral_plate","sentinel_circlet","sky_wings"]
    for index in 3:
        var slot=slots[index]
        var id=representatives[index]
        var b=buttons["gear_"+id]
        b.visible=active_tab=="Wesen";b.compact=true;b.z_index=30
        var data=model.profile.hero_equipment if HeroEquipment.ensure(model.profile) else {"owned":{},"equipped":{}}
        var equipped=str(data.equipped.get(slot,""))
        var art_id=equipped if equipped!="" else id
        var d:Dictionary=HeroEquipment.CATALOG[art_id]
        b.set_item(["Rüstung","Kopf","Flügel"][index],"",PURPLE if d.rarity=="epic" else CYAN,equipped!="",equipped!="",_texture("res://assets/equipment/"+art_id+".png"))
        b.tooltip_text=["Rüstung auswählen","Kopfschmuck auswählen","Flügel auswählen"][index]
        b.position=[Vector2(62,300),Vector2(566,300),Vector2(62,404)][index]
        b.size=Vector2(92,92)
    buttons.talents.visible=active_tab=="Wesen"
    _place("talents",Rect2(62,508,92,92))
    buttons.talents.tooltip_text="Talente · %d Punkte"%model.Advancement.available_points(model.profile)
    buttons.talents.compact=true;buttons.talents.z_index=30
    buttons.talents.set_item("Talent","",CYAN,model.Advancement.available_points(model.profile)>0,true,icons.star)
    var evolution_button=buttons.evolve
    evolution_button.visible=active_tab=="Wesen";evolution_button.compact=true
    evolution_button.z_index=30
    evolution_button.position=Vector2(566,508);evolution_button.size=Vector2(92,92)
    evolution_button.set_item("Erwacht" if Evolution.active(model.profile) else "Evolution","",GOLD,Evolution.active(model.profile),Evolution.unlocked(model.profile),icons.crown)
    for i in 4:
        buttons["hero_skill_"+str(i)].visible=active_tab=="Wesen"
        _place("hero_skill_"+str(i),Rect2(38+i*166,947,146,88))
    if preview:
        preview.aura.fx_intensity=[1.0,.4,0.0][effect_level]
        preview.fx_intensity=[1.0,.4,0.0][effect_level];preview.set_upgrade_tier(model.upgrade_level+int(model.Economy.enchant_bonus(model.profile,model.profile.equipped)/2))
    for id in ["auto", "skill0", "skill1", "locked", "skill2"]:
        buttons[id].visible = in_combat
    buttons.look.disabled=model.hero_id!="realmwachter"
    for id in ["weapon", "upgrade", "look", "aura"]:
        buttons[id].visible = active_tab == "Wesen"
    for id in ["quests", "events", "save_export", "save_import", "sound", "effects"]:
        buttons[id].visible = active_tab == "Mehr"
    for i in 2:_place("quests" if i==0 else "events",Rect2(38+i*332,440,312,176))
    buttons["return"].visible = false
    buttons["restart"].visible = in_combat and model.outcome in ["victory","defeat"]
    var ids=["sky_blade","arcane_eye","rage_flame","guardian_wall"]
    var controls=["skill0","skill1","skill2","locked"]
    for i in 4:
        var definition:Dictionary=model.skills.definitions[ids[i]]
        var rank=model.Advancement.rank(model.profile,ids[i])
        buttons[controls[i]].tooltip_text="%s · Stufe %d · %.1f s Abklingzeit"%[definition.name,rank,definition.cooldown]
        buttons[controls[i]].disabled = model.outcome!="fighting" or not model.skills.can_cast(ids[i],model.clock,model.hero_level,{"momentum":model.momentum,"rage":model.rage})
    # Locked defense remains tappable to explain the actual level requirement.
    if model.hero_level<2: buttons["locked"].disabled=false
    buttons["upgrade"].disabled = model.gold < model.upgrade_cost() or model.upgrade_level>=19 or (model.upgrade_level>=2 and model.profile.shards<1)
    for id in Equipment.IDS:
        var b: Button=buttons["equip_"+id]
        b.paint_card=active_tab=="Wesen"
        b.compact=active_tab=="Wesen"
        b.icon_rotation=-.65
        b.visible=active_tab=="Wesen"
        b.disabled=not model.profile.inventory.has(id)
        b.tooltip_text=Equipment.definition(id).description
        if active_tab=="Wesen":
            var i=Equipment.IDS.find(id)
            _place("equip_"+id,Rect2(38+i*130,813,124,100))
            var d=Equipment.definition(id)
            var owned=model.profile.inventory.has(id)
            var tint=GOLD if id==model.profile.equipped else (PURPLE if d.rarity=="epic" else CYAN)
            var icon=_texture("res://assets/production/weapons/"+id+".png") if ResourceLoader.exists("res://assets/production/weapons/"+id+".png") else null
            b.set_item(["Stahl","Kristall","Glut","Rune","Schatten"][i],"Lv. %d · %s"%[model.profile.inventory[id].level,_rarity(d.rarity)] if owned else "Im Streifzug finden",tint,id==model.profile.equipped,owned,icon)

    var extra=["community","more_forge","more_heroes","more_pets","more_talents"]
    for id in extra:buttons[id].visible=active_tab=="Mehr"
    if active_tab=="Mehr":
        var menu=["quests","events","journey","economy","more_forge","activities","more_heroes","more_pets","more_talents"]
        for i in 9:buttons[menu[i]].show();_place(menu[i],Rect2(30+(i%3)*224,526+floori(i/3.0)*184,212,170))
        for i in 2:
            _place(["sound","effects"][i],Rect2(30+i*336,1138,324,88));_place(["save_export","save_import"][i],Rect2(30+i*336,1340,324,88))
        _place("combat_options",Rect2(30,1240,660,88));_place("admin",Rect2(30,1454,660,88))

        buttons.community.text="Gemeinschaft\nFamilie · Arena · Titel · Ranglisten";buttons.community.framed=true
        buttons.community.add_theme_font_size_override("font_size",23)
        for state in ["normal","hover","pressed","focus","disabled"]:buttons.community.add_theme_stylebox_override(state,Kit.box("secondary" if state=="normal" else "hero"))
        if buttons.community.get_child_count()==0:
            var badge=TextureRect.new();badge.texture=load("res://assets/work708/ui/guild_banner.tres");badge.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;badge.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;badge.size=Vector2(84,84);badge.position=Vector2(10,10);badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;buttons.community.add_child(badge)
        _place("community",Rect2(30,398,660,108))

func notify(title: String, detail: String, seconds: float = 3.0) -> void:
    toast_tab=active_tab
    toast_title = title
    toast_detail = detail
    toast_until = Time.get_ticks_msec() + int(seconds * 1000.0)
    queue_redraw()

func _process(delta: float) -> void:
    hit_flash=maxf(0,hit_flash-delta)
    _redraw_clock += delta
    if _redraw_clock >= 0.1:
        _redraw_clock = 0.0
        update_buttons()
        queue_redraw()
        if shell_canvas:shell_canvas.queue_redraw()

func _panel(r: Rect2, _color: Color=Color.WHITE, _edge: Color=Color.WHITE, _radius: int=16, role: String="panel") -> void:
    _paint_target.draw_style_box(Kit.box(role),r)

func _text(value: String, p: Vector2, sz: int = 20, color: Color = INK, heavy: bool = false, width: float = -1) -> void:
    _paint_target.draw_string(bold if heavy else font, p + Vector2(0, 1), value, HORIZONTAL_ALIGNMENT_LEFT, width, sz, Color(0,0,0,0.8))
    _paint_target.draw_string(bold if heavy else font, p, value, HORIZONTAL_ALIGNMENT_LEFT, width, sz, color)

func _center(value: String, r: Rect2, sz: int = 20, color: Color = INK, heavy: bool = false) -> void:
    var f: Font = bold if heavy else font
    var w = f.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
    _text(value, Vector2(r.get_center().x - w / 2, r.position.y + (r.size.y + sz * 0.72) / 2), sz, color, heavy)

func _icon(id: String, r: Rect2, color: Color = Color.WHITE) -> void:
    if icons.has(id):
        _paint_target.draw_texture_rect(icons[id], r, false, color)

func _bar(r: Rect2, ratio: float, color: Color) -> void:
    ResourceBar.paint(_paint_target,r,ratio,color)

func _draw() -> void:
    if model == null or _top_fade == null:
        return
    _paint_target=self
    var h = logical_height
    if active_tab != "Kampf":
        _paint_target.draw_rect(Rect2(0, 0, 720, h), Color(0.015,0.035,0.075,0.82 if active_tab=="Wesen" else .94))
    _paint_target.draw_texture_rect(_top_fade, Rect2(0, 0, 720, 190), false)
    _draw_header()
    if qa_mode:_center("QA TEST · NICHT GESPEICHERT",Rect2(168,75,385,23),15,GOLD,true)
    if active_tab == "Kampf":
        _draw_combat()
    else:
        if active_tab!="Mehr":_center(active_tab,Rect2(0,105,720,48),31,INK,true)
    _draw_nav()
    if hit_flash>0 and active_tab=="Kampf":
        _paint_target.draw_rect(Rect2(0,0,7,logical_height-96),Color(1,0.12,0.1,hit_flash*2))
        _paint_target.draw_rect(Rect2(713,0,7,logical_height-96),Color(1,0.12,0.1,hit_flash*2))
    if model.outcome in ["victory","defeat"] and active_tab=="Kampf":
        _draw_result()

func _draw_header() -> void:
    _panel(Rect2(12, 12, 211, 68), Color(0.015,0.055,0.12,0.91))
    _panel(Rect2(15, 14, 64, 64), Color("#142840"), GOLD.darkened(0.3), 17)
    if portrait:
        _paint_target.draw_texture_rect(portrait, Rect2(16, 13, 63, 63), false)
    var level = model.level
    _text("Lv. %d" % level, Vector2(89, 40), 22, INK, true)
    _bar(Rect2(89, 51, 101, 11), float(Progress.xp_in_level(int(model.profile.xp))) / Progress.required(level), CYAN)
    _text("%d%%" % int(100.0*Progress.xp_in_level(int(model.profile.xp))/Progress.required(level)), Vector2(195, 61), 13, MUTED)
    for i in 3:
        var x = 231 + i * 98
        _panel(Rect2(x, 24, 92, 43), Color(0.01,0.035,0.08,0.94), Color(0.2,0.44,0.63,0.7), 22)
        _icon(["gold", "shard", "star"][i], Rect2(x + 6, 33, 24, 24))
        _text(_amount(model.gold) if i == 0 else (_amount(model.profile.shards) if i==1 else str(_world_stars())), Vector2(x + 34, 53), 18, INK, true)
    for i in 2:
        _panel(Rect2(542 + i * 96, 24, 56, 52), Color(0.01,0.035,0.08,0.91))
        _icon("map" if i == 0 else "gear", Rect2(554 + i * 96, 34, 32, 32))

func _world_stars() -> int:
    var total=0
    for region in model.World.IDS:
        for i in 5:total+=model.World.stars(model.profile,region,i)
    return total

func _amount(n: int) -> String:
    if n >= 1000000:
        return "%.1fM" % (n / 1000000.0)
    if n >= 10000:
        return "%.1fK" % (n / 1000.0)
    return str(n)

func _draw_combat() -> void:
    _panel(Rect2(115, 98, 490, 48), Color(0.015,0.05,0.105,0.94), Color(0.23,0.51,0.72,0.65), 24)
    _icon("mountain", Rect2(131, 107, 31, 30))
    var chapter = model.World.IDS.find(model.region)+1
    var node = (model.wave - 1) % 5
    var route="%s %d-%d"%[model.World.NAMES[model.region],chapter,node+1]
    if not model.activity.is_empty():route=model.Activities.CATALOG[model.activity.id].name+" · %d/%d"%[model.encounter+1,model.encounter_count()]
    _text(route,Vector2(174,128),18 if not model.activity.is_empty() else 21,INK,true,235)
    for i in 5:
        var p = Vector2(423 + i * 28, 122)
        if i < 4:
            _paint_target.draw_line(p, p + Vector2(28, 0), Color("#39516d"), 3, true)
        _paint_target.draw_circle(p, 6 if i != node else 8, CYAN if i <= node else Color("#536680"))
    _icon("crown", Rect2(554, 108, 29, 29), GOLD if node == 4 else MUTED)
    var boss = model.enemy_definition.kind == "boss"
    var elite = model.enemy_definition.kind == "elite"
    _panel(Rect2(120, 166, 480, 106), Color(0.01,0.035,0.075,0.94), Color.WHITE,16,"boss" if boss else "panel")
    _icon("crown" if boss else "rock", Rect2(137, 178, 33, 33), GOLD if boss else Color.WHITE)
    _text(model.enemy_definition.name, Vector2(181, 202), 23, INK, true)
    _text("Lv. %d" % model.wave, Vector2(516, 201), 18, MUTED)
    _bar(Rect2(137, 217, 446, 24), float(model.enemy_hp) / model.enemy_max_hp, Color("#f23754"))
    _center("%d / %d" % [model.enemy_hp, model.enemy_max_hp], Rect2(137, 216, 446, 24), 20, INK, true)
    _text("BOSS" if boss else ("ELITE" if elite else "NORMAL"), Vector2(139, 261), 12, GOLD if boss else (PURPLE if elite else MUTED), true)
    var statuses=[]
    if model.enemy_status.has("mark",model.clock): statuses.append(["eye","%.1fs"%model.enemy_status.remaining("mark",model.clock)])
    if model.enemy_status.has("burn",model.clock): statuses.append(["flame","%.1fs"%model.enemy_status.remaining("burn",model.clock)])
    if statuses.is_empty() and not boss:
        _text("%d / %d · %s"%[model.encounter+1,model.encounter_count(),("%.0f s"%maxf(0,float(model.Activities.CATALOG[model.activity.id].timer)-model.clock) if not model.activity.is_empty() and float(model.Activities.CATALOG[model.activity.id].timer)>0 else "Streifzug")],Vector2(288,263),14,MUTED)
    else:
        for i in statuses.size():
            _icon(statuses[i][0],Rect2(285+i*120,247,21,21))
            _text(statuses[i][1],Vector2(311+i*120,263),13,INK)
    if model.behavior.state=="windup" and model.outcome=="fighting":
        _panel(Rect2(183,346,355,38),Color(0.22,0.035,0.035,0.92),Color("#e98f65"),12)
        var cue=enemy_attack_cue()
        _center("%s in %.1fs"%[cue,maxf(0,model.behavior.deadline-model.clock)],Rect2(183,346,355,38),16,Color("#ffca9b"),true)
    _paint_target.draw_texture_rect(_bottom_fade, Rect2(0, controls_top - 90, 720, 356 + 90), false)
    var y = controls_top + 8
    _resource(Rect2(18, y, 248, 58), "heart", "%d / %d"%[model.player_hp,model.player_max_hp], float(model.player_hp)/model.player_max_hp, Color("#36df73"))
    _resource(Rect2(278, y, 165, 58), "eye", "%d" % model.momentum, model.momentum / 100.0, PURPLE)
    _resource(Rect2(455, y, 155, 58), "flame", "%d" % model.rage, model.rage / 100.0, Color("#ff8a22"))
    var ac = Vector2(663, controls_top + 37)
    _paint_target.draw_circle(ac, 36, Color(0.05,0.6,1,0.12) if auto_enabled else Color(0.1,0.15,0.2,0.8))
    _paint_target.draw_circle(ac, 32, Color("#061528"))
    _paint_target.draw_arc(ac, 33, 0, TAU, 64, CYAN if auto_enabled else MUTED, 3, true)
    _icon("swords", Rect2(ac.x - 14, ac.y - 23, 28, 28), CYAN if auto_enabled else MUTED)
    _center("AUTO" if auto_enabled else "AUS", Rect2(ac.x - 30, ac.y + 5, 60, 20), 13, INK, true)
    for i in 4:
        _skill(i, Vector2(99 + i * 174, controls_top + 143))
    _panel(Rect2(18,controls_top-70,140,60),Color.WHITE,Color.WHITE,16,"secondary")
    _center("x%d TREFFER"%model.Tap.mode(model.profile),Rect2(18,controls_top-70,140,60),18,CYAN,true)
    var combo=model.tap.combo if model.clock<=model.tap.combo_until else 0
    if combo>1:_center("%d COMBO"%combo,Rect2(188,controls_top-55,340,38),24,GOLD,true)
    _panel(Rect2(538,controls_top-70,160,60),Color.WHITE,Color.WHITE,16,"hero")
    var unlocked=model.Tap.ultimate_unlocked(model.profile)
    _center(("ULT · %d%%"%model.tap.charge if model.clock>=model.tap.ultimate_at else "ULT · %.1fs"%(model.tap.ultimate_at-model.clock)) if unlocked else "ULT · Lv.4",Rect2(538,controls_top-68,160,40),17,GOLD,true)
    _bar(Rect2(552,controls_top-24,132,6),model.tap.charge/100.0,GOLD)
    if boss:
        _bar(Rect2(250,250,180,9),float(model.boss.meter)/model.boss.LIMIT,CYAN)
        _text("BRUCH" if model.clock<model.boss.break_until else ("RASEREI" if model.boss.enraged else "RÜSTUNG"),Vector2(444,261),12,CYAN if not model.boss.enraged else GOLD,true)

func _resource(r: Rect2, icon: String, value: String, ratio: float, color: Color) -> void:
    _panel(r, Color(0.015,0.025,0.04,0.9), Color(0.4,0.5,0.6,0.45), 15)
    _icon(icon, Rect2(r.position + Vector2(9, 12), Vector2(31, 34)))
    _center(value, Rect2(r.position + Vector2(46, 4), Vector2(r.size.x - 57, 23)), 24, INK, true)
    _bar(Rect2(r.position + Vector2(46, 32), Vector2(r.size.x - 58, 14)), ratio, color)

func enemy_attack_cue() -> String:
    if model.enemy_definition.pattern=="eruption":return "Nachbeben" if model.behavior.second else "Eruption"
    if model.enemy_definition.pattern=="double":return "Folgetreffer" if model.behavior.second else "Doppelschlag"
    if model.enemy_definition.pattern=="heavy":return "Wuchtschlag" if (model.behavior.strikes+1)%2==0 else "Angriff"
    return "Angriff"

func _skill(i: int, _center: Vector2) -> void:
    var id=["sky_blade","arcane_eye","guardian_wall","rage_flame"][i]
    var d:Dictionary=model.skills.definitions[id]
    var button=buttons[["skill0","skill1","locked","skill2"][i]]
    var resource=model.momentum if d.cost_type=="momentum" else model.rage
    button.configure(orbs[i],d,model.skills.remaining(id,model.clock),model.hero_level<int(d.unlock_level),d.cost_type=="none" or resource>=float(d.cost),(["Runenstoß","Siegel","Bastion","Esse"] if model.hero_id=="runenpaladin" else (["Nachtschnitt","Nachtsiegel","Nebelwall","Schattenbrand"] if model.hero_id=="schattenjager" else ["Klinge","Arkanblick","Wächterwall","Zornesflamme"]))[i])

func _draw_result() -> void:
    _paint_target.draw_rect(Rect2(0,96,720,logical_height-192),Color(0.01,0.025,0.055,0.68))
    _panel(Rect2(112,365,496,300),Color("#091a30"),GOLD if model.outcome=="victory" else Color("#ff6b72"),22,"boss_ornate")
    _icon("crown" if model.outcome=="victory" else "heart",Rect2(327,385,66,66))
    _center("STREIFZUG GESCHAFFT" if model.outcome=="victory" else "BESIEGT",Rect2(120,461,480,42),25,GOLD if model.outcome=="victory" else INK,true)
    _center("Wächtertruhe in Beute · Fortschritt gespeichert" if model.outcome=="victory" else "Deine Ausrüstung und Beute bleiben erhalten.",Rect2(120,512,480,32),17,MUTED)
    _panel(Rect2(170,570,380,62),Color.WHITE,CYAN,16,"primary")
    _center(("Weiter nach "+model.World.NAMES[model.onward_region()] if model.onward_region()!="" else "Erneut spielen") if model.outcome=="victory" else "Erneut versuchen",Rect2(170,570,380,62),20,INK,true)

func _draw_nav() -> void:
    var y = logical_height - 108
    _paint_target.draw_rect(Rect2(0, y, 720, 108), Color("#040e1c"))
    _paint_target.draw_line(Vector2(0,y), Vector2(720,y), Color("#30536b"), 1, true)
    for i in 5:
        var tab = ["Kampf", "Abenteuer", "Wesen", "Beute", "Mehr"][i]
        var active = tab == active_tab
        var x = i * 144
        if active:
            _panel(Rect2(x + 6, y + 1, 132, 101), Color(0.30,0.075,0.55,0.48), Color(0.65,0.3,1,0.95), 14,"hero")
            _paint_target.draw_line(Vector2(x + 28,y + 1), Vector2(x + 116,y + 1), PURPLE, 3, true)
        _icon(["swords", "map", "paw", "chest", "grid"][i], Rect2(x + 53, y + 13, 38, 38), INK if active else MUTED)
        _center(tab, Rect2(x, y + 57, 144, 26), 21, INK if active else MUTED, active)

func _rarity(id: String) -> String:
    return {"common":"Gewöhnlich","rare":"Selten","epic":"Episch"}.get(id,id)

func _paint_shell() -> void:
    if model==null or not shell_scroll.visible:return
    _paint_target=shell_canvas
    _draw_shell()
    _paint_target=self

func _draw_shell() -> void:
    _center(active_tab, Rect2(0, 105, 720, 48), 31, INK, true)
    match active_tab:
        "Abenteuer":
            pass
        "Wesen":
            draw_ellipse_platform()
            _panel(Rect2(170,589,380,38))
            # This is a real Button hit area in update_buttons, not an invisible
            # region covering the hero heading as in the earlier APK.
            _panel(Rect2(38,155,644,100),Color.WHITE,Color.WHITE,16,"primary")
            _icon("paw",Rect2(60,178,39,44),CYAN)
            _center("HELDEN & BEGLEITER",Rect2(115,168,530,38),24,INK,true)
            _center("Sammlung öffnen · jederzeit wechseln",Rect2(115,211,530,26),17,MUTED)
            _center("%s · Lv. %d"%[model.hero_name,model.hero_level],Rect2(38,257,644,32),24,INK,true)
            _center("%s · Waffenlevel %d"%[Equipment.definition(model.profile.equipped).name,model.upgrade_level+1],Rect2(38,285,644,26),17,GOLD)
            _center("Kraft %d · %s"%[model.power,"Erwacht" if Evolution.active(model.profile) else "Basisform"],Rect2(180,312,360,23),16,GOLD)
            _center("Angriff %d · HP %d · DEF %d"%[model.hero_damage(),model.player_max_hp,model.defense],Rect2(170,590,380,36),17,GOLD,true)
            _panel(Rect2(38,644,310,64),Color("#11334f"),CYAN.darkened(0.3))
            _panel(Rect2(368,644,314,64),Color("#3c2851"),PURPLE.darkened(0.2))
            _center("Waffe wechseln",Rect2(38,644,310,64),20,INK,true)
            _center("Aufwerten · %d G%s"%[model.upgrade_cost()," +1 Splitter" if model.upgrade_level>=2 else ""],Rect2(368,644,314,64),15,MUTED if buttons.upgrade.disabled else GOLD,true)
            _panel(Rect2(38,733,310,58),Color("#123b3a"),CYAN.darkened(0.3))
            _panel(Rect2(368,733,314,58),Color("#18233b"),PURPLE.darkened(0.4))
            _center("Outfit: Runenhüterin" if model.hero_id=="kaela" else "Umhang: %s"%{"canonical":"Original","emerald":"Smaragd","astral":"Astral"}.get(model.profile.look,"Original"),Rect2(38,733,310,58),17,INK,true)
            _center("Aura: %s"%("Lv. 3" if model.level<3 else ("An" if model.profile.aura else "Aus")),Rect2(368,733,314,58),17,MUTED if model.level<3 else CYAN,true)
            for i in 4:
                var r=Rect2(38+i*166,947,146,88)
                _panel(r)
                var texture=icons.shield if i==3 and model.hero_level>=2 else orbs[[0,1,3,2][i]]
                _paint_target.draw_texture_rect(texture,Rect2(r.position+Vector2(51,5),Vector2(44,44)),false)
                var d:Dictionary=model.skills.definitions[model.SKILL_IDS[i]]
                _center(str(d.name),Rect2(r.position+Vector2(0,49),Vector2(146,20)),14,INK,true)
                var cost="frei" if d.cost_type=="none" else "%d %s"%[d.cost,{"momentum":"M","rage":"Z"}[d.cost_type]]
                _center("%.1f s · %s"%[d.cooldown,cost],Rect2(r.position+Vector2(0,68),Vector2(146,18)),13,MUTED)
            # Always reachable by scrolling, including short landscape windows.
            if active_tab=="Wesen":
                var progress_rect=Rect2(38,1055,644,194)
                _panel(progress_rect)
                _text("Heldenfortschritt",Vector2(60,1088),21,INK,true)
                var within=Progress.xp_in_level(model.Roster.xp(model.profile))
                var needed=Progress.required(model.hero_level)
                _text("%d / %d XP"%[within,needed] if model.level<100 else "Maximallevel",Vector2(473,1088),16,CYAN)
                _bar(Rect2(60,1108,600,16),float(within)/needed if model.level<100 else 1.0,CYAN)
                var bonuses=HeroEquipment.stats(model.profile)
                _text("Ausrüstung: +%d HP · +%d Verteidigung"%[bonuses.hp,bonuses.defense],Vector2(60,1160),17,MUTED)
                _text(model.Tap.next_goal(model.profile),Vector2(60,1201),17,GOLD)
        "Beute":
            pass
        "Mehr":
            _panel(Rect2(30,168,660,210))
            if portrait:_paint_target.draw_texture_rect(portrait,Rect2(48,187,144,144),false)
            _text(model.hero_name,Vector2(218,216),29,INK,true);_text("Level %d · Kraft %d"%[model.level,model.power],Vector2(218,254),22,GOLD)
            _bar(Rect2(218,274,442,16),float(Progress.xp_in_level(model.profile.xp))/Progress.required(model.level),CYAN)
            _text("%d / %d XP"%[Progress.xp_in_level(model.profile.xp),Progress.required(model.level)],Vector2(218,318),18,MUTED)
            _text(model.Titles.CATALOG[model.profile.titles.active].name+" · Abenteuer gespeichert",Vector2(50,354),18,GOLD)
            var labels=["Quests","Events","Erfolge","Shop","Schmiede","Dungeons","Helden","Begleiter","Talente"]
            var artwork=["quests","events","achievements","shop","journey","dungeons","hero","pet","talents"]
            for i in 9:
                var rect=Rect2(30+(i%3)*224,526+floori(i/3.0)*184,212,170);_panel(rect,Color.WHITE,Color.WHITE,12,"slot")
                var path="res://assets/work704/ui/"+artwork[i]+".png"
                if ResourceLoader.exists(path):_paint_target.draw_texture_rect(_texture(path),Rect2(rect.position+Vector2(53,5),Vector2(106,106)),false)
                elif i==6 and portrait:_paint_target.draw_texture_rect(portrait,Rect2(rect.position+Vector2(57,10),Vector2(98,98)),false)
                elif i==7:_paint_target.draw_texture_rect(_texture("res://assets/roster67/skyfox/base_idle.png"),Rect2(rect.position+Vector2(53,5),Vector2(106,106)),false)
                else:_icon("star",Rect2(rect.position+Vector2(72,25),Vector2(68,68)),GOLD)
                _center(labels[i],Rect2(rect.position+Vector2(0,121),Vector2(212,35)),23,INK,true)
            _text("EINSTELLUNGEN",Vector2(32,1122),20,MUTED,true)
            for i in 2:
                var rect=Rect2(30+i*336,1138,324,88);_panel(rect);_center(("Klang: "+("An" if sound_enabled else "Aus")) if i==0 else "Effekte: "+["Voll","Reduziert","Aus"][effect_level],rect,22,INK,true)
            _panel(Rect2(30,1240,660,88));_center("AUTO-Skills konfigurieren",Rect2(30,1240,660,88),23,INK,true)
            for i in 2:
                var rect=Rect2(30+i*336,1340,324,88);_panel(rect);_center("Stand exportieren" if i==0 else "Stand importieren",rect,20,INK,true)
            if OS.is_debug_build():_panel(Rect2(30,1454,660,88));_center("QA-Testlabor",Rect2(30,1454,660,88),22,GOLD,true)

func draw_ellipse_platform() -> void:
    # Open showcase; a native geometric pedestal keeps body/equipment independent.
    _paint_target.draw_set_transform(Vector2(360,570),0,Vector2(1,.20))
    _paint_target.draw_circle(Vector2.ZERO,175,Color(.01,.05,.12,.7))
    _paint_target.draw_arc(Vector2.ZERO,171,0,TAU,80,Color(.35,.62,.8,.8),3,true)
    _paint_target.draw_arc(Vector2.ZERO,150,0,TAU,80,Color(.2,.7,1,.35),2,true)
    _paint_target.draw_set_transform(Vector2.ZERO)
