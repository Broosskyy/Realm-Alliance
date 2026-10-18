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

func _texture(path: String) -> Texture2D:
    if not _textures.has(path):_textures[path]=load(path)
    return _textures[path]

func _ready() -> void:
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
    for id in ["mail", "settings", "auto", "skill0", "skill1", "locked", "skill2", "Kampf", "Abenteuer", "Wesen", "Beute", "Mehr", "weapon", "upgrade", "return", "quests", "events", "restart", "look", "aura", "sound", "effects", "save_export", "save_import", "equip_steel", "equip_crystal", "equip_ember", "equip_rune_gold", "equip_shadow_violet", "gear_astral_plate", "gear_eclipse_plate", "gear_sentinel_circlet", "gear_sky_wings", "evolve", "hero_skill_0", "hero_skill_1", "hero_skill_2", "hero_skill_3", "talents", "hit_mode", "ultimate", "combat_options", "roster", "admin"]:
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
    if hero_texture:
        preview = HeroPreview.new()
        preview.name = "EquippedHeroPreview"
        preview.z_index = 20
        preview.position = Vector2(280,589)
        preview.scale = Vector2.ONE * 0.62
        preview.visible = false
        add_child(preview)
    companion_preview=preload("res://scripts/presentation/companion_visual.gd").new();companion_preview.position=Vector2(485,589);companion_preview.scale=Vector2.ONE*.22;companion_preview.z_index=21;add_child(companion_preview)
    rpg_pages=preload("res://scripts/ui/rpg_pages.gd").new();rpg_pages.name="RPGPages";rpg_pages.z_index=40;add_child(rpg_pages);rpg_pages.action.connect(func(id):action.emit(id))
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
    controls_top = height - 330.0
    size = Vector2(720, height)
    if buttons.is_empty():
        return
    _place("hit_mode",Rect2(18,controls_top-100,160,88))
    _place("ultimate",Rect2(538,controls_top-100,160,88))
    _place("combat_options",Rect2(38,943,644,88))
    _place("admin",Rect2(368,631,314,61))
    _place("mail", Rect2(612, 18, 44, 52))
    _place("settings", Rect2(664, 18, 44, 52))
    _place("auto", Rect2(628, controls_top + 3, 70, 70))
    for i in 4:
        var ids = ["skill0", "skill1", "locked", "skill2"]
        _place(ids[i], Rect2(34 + i * 174, controls_top + 82, 130, 142))
    for i in 5:
        _place(["Kampf", "Abenteuer", "Wesen", "Beute", "Mehr"][i], Rect2(i * 144 + 4, height - 94, 136, 88))
    _place("sound",Rect2(38,845,312,62))
    _place("effects",Rect2(370,845,312,62))
    _place("save_export",Rect2(38,715,312,62))
    _place("save_import",Rect2(370,715,312,62))
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
    buttons.combat_options.visible=active_tab=="Mehr"
    buttons.admin.visible=OS.is_debug_build() and active_tab=="Mehr"
    buttons.ultimate.disabled=not model.Tap.ultimate_unlocked(model.profile) or model.tap.charge<100 or model.clock<model.tap.ultimate_at or model.outcome!="fighting"
    buttons.ultimate.tooltip_text="Sternenfall · 4,8× Schaden · 100 Ladung · 16 s Abklingzeit"
    buttons.hit_mode.tooltip_text="x2: Level 3 + Elite · x4: Level 6 + Gartenkoloss · mehrere echte Treffer"
    if _last_tab!=active_tab:
        if _menu_transition:_menu_transition.kill()
        if _veil:
            _veil.modulate.a=.18 if effect_level==0 and _last_tab!="" else 0
            if _veil.modulate.a>0:
                _menu_transition=create_tween();_menu_transition.tween_property(_veil,"modulate:a",0.0,.18)
        _last_tab=active_tab
    if rpg_pages:rpg_pages.refresh(active_tab,model,logical_height)
    if toast:
        toast.visible=toast_until>Time.get_ticks_msec()
        toast.position=Vector2(176,286) if in_combat else Vector2(38,maxf(1040,logical_height-265) if active_tab=="Wesen" else logical_height-265)
        toast.size=Vector2(368,54) if in_combat else Vector2(644,40)
        toast.display(toast_title,toast_detail,in_combat)
    buttons.roster.visible=active_tab=="Wesen";buttons.roster.tooltip_text="Helden & Begleiter öffnen";_place("roster",Rect2(38,171,644,100))
    portrait=_texture("res://assets/roster67/kaela/portrait.png") if model.hero_id=="kaela" else guardian_portrait
    if companion_preview:
        companion_preview.sync(model.profile,Time.get_ticks_msec()/1000.0);companion_preview.visible=active_tab=="Wesen" and str(model.profile.companions.active)!=""
    if preview:
        preview.visible = active_tab == "Wesen"
        var visual_key=model.hero_id+str(model.weapon_index)+str(model.upgrade_level)+str(model.profile.look)+str(model.profile.aura)+str(model.level)+JSON.stringify(model.profile.hero_equipment)+JSON.stringify(model.profile.hero_evolution)
        if preview.visible and visual_key!=_preview_key:
            _preview_key=visual_key
            preview.set_hero(model.hero_id)
            preview.equip_weapon(model.weapon_index)
            preview.set_upgrade_tier(model.upgrade_level)
            preview.set_look(model.profile.look,bool(model.profile.aura) and model.level>=3)
            preview.set_gear(model.profile)
    for index in 4:
        var id=HeroEquipment.IDS[index]
        var b=buttons["gear_"+id]
        b.visible=active_tab=="Wesen";b.compact=true
        b.z_index=30
        var d:Dictionary=HeroEquipment.CATALOG[id]
        var data=model.profile.hero_equipment if HeroEquipment.ensure(model.profile) else {"owned":{},"equipped":{}}
        var owned=data.owned.has(id)
        b.set_item(["Stern","Eklipse","Diadem","Flügel"][index],"",PURPLE if d.rarity=="epic" else CYAN,str(data.equipped.get(d.slot,""))==id,owned,_texture("res://assets/equipment/"+id+".png"))
        b.tooltip_text=d.name+" · Details / anlegen / aufwerten"
        b.position=Vector2(62,300+index*104) if index<2 else Vector2(566,300+(index-2)*104)
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
        preview.fx_intensity=[1.0,.4,0.0][effect_level];preview.set_upgrade_tier(model.upgrade_level)
    for id in ["auto", "skill0", "skill1", "locked", "skill2"]:
        buttons[id].visible = in_combat
    buttons.look.disabled=model.hero_id!="realmwachter"
    for id in ["weapon", "upgrade", "look", "aura"]:
        buttons[id].visible = active_tab == "Wesen"
    for id in ["quests", "events", "save_export", "save_import", "sound", "effects"]:
        buttons[id].visible = active_tab == "Mehr"
    buttons["return"].visible = not in_combat
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

func notify(title: String, detail: String, seconds: float = 3.0) -> void:
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

func _panel(r: Rect2, _color: Color=Color.WHITE, _edge: Color=Color.WHITE, _radius: int=16, role: String="panel") -> void:
    draw_style_box(Kit.box(role),r)

func _text(value: String, p: Vector2, sz: int = 20, color: Color = INK, heavy: bool = false, width: float = -1) -> void:
    draw_string(bold if heavy else font, p + Vector2(0, 1), value, HORIZONTAL_ALIGNMENT_LEFT, width, sz, Color(0,0,0,0.8))
    draw_string(bold if heavy else font, p, value, HORIZONTAL_ALIGNMENT_LEFT, width, sz, color)

func _center(value: String, r: Rect2, sz: int = 20, color: Color = INK, heavy: bool = false) -> void:
    var f: Font = bold if heavy else font
    var w = f.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
    _text(value, Vector2(r.get_center().x - w / 2, r.position.y + (r.size.y + sz * 0.72) / 2), sz, color, heavy)

func _icon(id: String, r: Rect2, color: Color = Color.WHITE) -> void:
    if icons.has(id):
        draw_texture_rect(icons[id], r, false, color)

func _bar(r: Rect2, ratio: float, color: Color) -> void:
    ResourceBar.paint(self,r,ratio,color)

func _draw() -> void:
    if model == null or _top_fade == null:
        return
    var h = logical_height
    if active_tab != "Kampf":
        draw_rect(Rect2(0, 0, 720, h), Color(0.015,0.035,0.075,0.45 if active_tab=="Wesen" else .91))
    draw_texture_rect(_top_fade, Rect2(0, 0, 720, 190), false)
    _draw_header()
    if qa_mode:_center("QA TEST · NICHT GESPEICHERT",Rect2(168,75,385,23),15,GOLD,true)
    if active_tab == "Kampf":
        _draw_combat()
    else:
        _draw_shell()
    _draw_nav()
    if hit_flash>0 and active_tab=="Kampf":
        draw_rect(Rect2(0,0,7,logical_height-96),Color(1,0.12,0.1,hit_flash*2))
        draw_rect(Rect2(713,0,7,logical_height-96),Color(1,0.12,0.1,hit_flash*2))
    if model.outcome in ["victory","defeat"] and active_tab=="Kampf":
        _draw_result()

func _draw_header() -> void:
    _panel(Rect2(12, 12, 225, 68), Color(0.015,0.055,0.12,0.91))
    _panel(Rect2(15, 14, 64, 64), Color("#142840"), GOLD.darkened(0.3), 17)
    if portrait:
        draw_texture_rect(portrait, Rect2(16, 13, 63, 63), false)
    var level = model.level
    _text("Lv. %d" % level, Vector2(89, 40), 22, INK, true)
    _bar(Rect2(89, 51, 101, 11), float(Progress.xp_in_level(int(model.profile.xp))) / Progress.required(level), CYAN)
    _text("%d%%" % int(100.0*Progress.xp_in_level(int(model.profile.xp))/Progress.required(level)), Vector2(195, 61), 13, MUTED)
    for i in 3:
        var x = 249 + i * 118
        _panel(Rect2(x, 24, 110, 43), Color(0.01,0.035,0.08,0.94), Color(0.2,0.44,0.63,0.7), 22)
        _icon(["gold", "shard", "star"][i], Rect2(x + 6, 31, 28, 28))
        _text(_amount(model.gold) if i == 0 else (_amount(model.profile.shards) if i==1 else str(_world_stars())), Vector2(x + 39, 53), 19, INK, true)
    for i in 2:
        _panel(Rect2(612 + i * 52, 18, 44, 52), Color(0.01,0.035,0.08,0.91))
        _icon("map" if i == 0 else "gear", Rect2(621 + i * 52, 30, 26, 26))

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
    _text("%s %d-%d" % [model.World.NAMES[model.region], chapter, node + 1], Vector2(174, 128), 21, INK, true)
    for i in 5:
        var p = Vector2(423 + i * 28, 122)
        if i < 4:
            draw_line(p, p + Vector2(28, 0), Color("#39516d"), 3, true)
        draw_circle(p, 6 if i != node else 8, CYAN if i <= node else Color("#536680"))
    _icon("crown", Rect2(554, 108, 29, 29), GOLD if node == 4 else MUTED)
    var boss = model.enemy_definition.kind == "boss"
    var elite = model.enemy_definition.kind == "elite"
    _panel(Rect2(120, 166, 480, 106), Color(0.01,0.035,0.075,0.94), Color.WHITE,16,"boss" if boss else "panel")
    _icon("crown" if boss else "rock", Rect2(137, 178, 33, 33), GOLD if boss else Color.WHITE)
    _text(model.enemy_definition.name, Vector2(181, 202), 23, INK, true)
    _text("Lv. %d" % model.wave, Vector2(516, 201), 18, MUTED)
    _bar(Rect2(137, 217, 446, 24), float(model.enemy_hp) / model.enemy_max_hp, Color("#f23754"))
    _center("%d / %d" % [model.enemy_hp, model.enemy_max_hp], Rect2(137, 216, 446, 24), 16, INK, true)
    _text("BOSS" if boss else ("ELITE" if elite else "NORMAL"), Vector2(139, 261), 12, GOLD if boss else (PURPLE if elite else MUTED), true)
    var statuses=[]
    if model.enemy_status.has("mark",model.clock): statuses.append(["eye","%.1fs"%model.enemy_status.remaining("mark",model.clock)])
    if model.enemy_status.has("burn",model.clock): statuses.append(["flame","%.1fs"%model.enemy_status.remaining("burn",model.clock)])
    if statuses.is_empty():
        _text("%d / 5 · Streifzug"%(model.encounter+1),Vector2(288,263),14,MUTED)
    else:
        for i in statuses.size():
            _icon(statuses[i][0],Rect2(285+i*120,247,21,21))
            _text(statuses[i][1],Vector2(311+i*120,263),13,INK)
    if model.behavior.state=="windup" and model.outcome=="fighting":
        _panel(Rect2(183,346,355,38),Color(0.22,0.035,0.035,0.92),Color("#e98f65"),12)
        var cue=enemy_attack_cue()
        _center("%s in %.1fs"%[cue,maxf(0,model.behavior.deadline-model.clock)],Rect2(183,346,355,38),16,Color("#ffca9b"),true)
    draw_texture_rect(_bottom_fade, Rect2(0, controls_top - 90, 720, 330 + 90), false)
    var y = controls_top + 8
    _resource(Rect2(18, y, 248, 58), "heart", "%d / %d"%[model.player_hp,model.player_max_hp], float(model.player_hp)/model.player_max_hp, Color("#36df73"))
    _resource(Rect2(278, y, 165, 58), "eye", "%d" % model.momentum, model.momentum / 100.0, PURPLE)
    _resource(Rect2(455, y, 155, 58), "flame", "%d" % model.rage, model.rage / 100.0, Color("#ff8a22"))
    var ac = Vector2(663, controls_top + 37)
    draw_circle(ac, 36, Color(0.05,0.6,1,0.12) if auto_enabled else Color(0.1,0.15,0.2,0.8))
    draw_circle(ac, 32, Color("#061528"))
    draw_arc(ac, 33, 0, TAU, 64, CYAN if auto_enabled else MUTED, 3, true)
    _icon("swords", Rect2(ac.x - 14, ac.y - 23, 28, 28), CYAN if auto_enabled else MUTED)
    _center("AUTO" if auto_enabled else "AUS", Rect2(ac.x - 30, ac.y + 5, 60, 20), 13, INK, true)
    for i in 4:
        _skill(i, Vector2(99 + i * 174, controls_top + 143))
    _panel(Rect2(18,controls_top-100,160,88),Color.WHITE,Color.WHITE,16,"secondary")
    _center("x%d TREFFER"%model.Tap.mode(model.profile),Rect2(18,controls_top-97,160,42),19,CYAN,true)
    _center("Wechseln",Rect2(18,controls_top-57,160,30),15,MUTED)
    var combo=model.tap.combo if model.clock<=model.tap.combo_until else 0
    _center("%d COMBO"%combo if combo>1 else "TAP · KOMBOKETTE",Rect2(188,controls_top-96,340,38),22,GOLD if combo>1 else INK,true)
    _center("Schnitt · Aufwärtshieb · Finisher",Rect2(188,controls_top-53,340,25),14,MUTED)
    _panel(Rect2(538,controls_top-100,160,88),Color.WHITE,Color.WHITE,16,"hero")
    var unlocked=model.Tap.ultimate_unlocked(model.profile)
    _center("ULTIMATE",Rect2(538,controls_top-96,160,36),18,INK,true)
    _bar(Rect2(552,controls_top-52,132,10),model.tap.charge/100.0,GOLD)
    _center(("%d%%"%model.tap.charge if model.clock>=model.tap.ultimate_at else "%.1fs"%(model.tap.ultimate_at-model.clock)) if unlocked else "Lv.4 + Boss",Rect2(538,controls_top-40,160,25),14,GOLD)
    if boss:
        _bar(Rect2(250,250,180,9),float(model.boss.meter)/model.boss.LIMIT,CYAN)
        _text("BRUCH" if model.clock<model.boss.break_until else ("RASEREI" if model.boss.enraged else "RÜSTUNG"),Vector2(444,261),12,CYAN if not model.boss.enraged else GOLD,true)

func _resource(r: Rect2, icon: String, value: String, ratio: float, color: Color) -> void:
    _panel(r, Color(0.015,0.025,0.04,0.9), Color(0.4,0.5,0.6,0.45), 15)
    _icon(icon, Rect2(r.position + Vector2(9, 12), Vector2(31, 34)))
    _center(value, Rect2(r.position + Vector2(46, 4), Vector2(r.size.x - 57, 23)), 16, INK, true)
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
    button.configure(orbs[i],d,model.skills.remaining(id,model.clock),model.hero_level<int(d.unlock_level),d.cost_type=="none" or resource>=float(d.cost),(["Runenstoß","Siegel","Bastion","Esse"] if model.hero_id=="kaela" else ["Klinge","Arkanblick","Wächterwall","Zornesflamme"])[i])

func _draw_result() -> void:
    draw_rect(Rect2(0,96,720,logical_height-192),Color(0.01,0.025,0.055,0.68))
    _panel(Rect2(112,365,496,300),Color("#091a30"),GOLD if model.outcome=="victory" else Color("#ff6b72"),22,"boss_ornate")
    _icon("crown" if model.outcome=="victory" else "heart",Rect2(327,385,66,66))
    _center("STREIFZUG GESCHAFFT" if model.outcome=="victory" else "BESIEGT",Rect2(120,461,480,42),25,GOLD if model.outcome=="victory" else INK,true)
    _center("Gold, XP und Beute bleiben erhalten.",Rect2(120,512,480,32),17,MUTED)
    _panel(Rect2(170,570,380,62),Color.WHITE,CYAN,16,"primary")
    _center("Nächster Streifzug" if model.outcome=="victory" else "Erneut versuchen",Rect2(170,570,380,62),20,INK,true)

func _draw_nav() -> void:
    var y = logical_height - 96
    draw_rect(Rect2(0, y, 720, 96), Color("#040e1c"))
    draw_line(Vector2(0,y), Vector2(720,y), Color("#30536b"), 1, true)
    for i in 5:
        var tab = ["Kampf", "Abenteuer", "Wesen", "Beute", "Mehr"][i]
        var active = tab == active_tab
        var x = i * 144
        if active:
            _panel(Rect2(x + 6, y + 1, 132, 89), Color(0.30,0.075,0.55,0.48), Color(0.65,0.3,1,0.95), 14,"hero")
            draw_line(Vector2(x + 28,y + 1), Vector2(x + 116,y + 1), PURPLE, 3, true)
        _icon(["swords", "map", "paw", "chest", "grid"][i], Rect2(x + 53, y + 13, 38, 38), INK if active else MUTED)
        _center(tab, Rect2(x, y + 57, 144, 26), 17, INK if active else MUTED, active)

func _rarity(id: String) -> String:
    return {"common":"Gewöhnlich","rare":"Selten","epic":"Episch"}.get(id,id)

func _draw_shell() -> void:
    _center(active_tab, Rect2(0, 105, 720, 48), 31, INK, true)
    match active_tab:
        "Abenteuer":
            pass
        "Wesen":
            draw_ellipse_platform()
            _panel(Rect2(170,589,380,38))
            _center("%s · Lv. %d · Sammlung"%[model.hero_name,model.hero_level],Rect2(38,191,644,38),25,INK,true)
            _center("%s · Waffenlevel %d"%[Equipment.definition(model.profile.equipped).name,model.upgrade_level+1],Rect2(38,231,644,28),18,GOLD)
            _center(Equipment.definition(model.profile.equipped).description,Rect2(50,249,620,25),15,MUTED)
            _center("Kraft %d · %s"%[model.power,"Erwacht" if Evolution.active(model.profile) else "Basisform"],Rect2(180,278,360,24),16,GOLD)
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
                draw_texture_rect(texture,Rect2(r.position+Vector2(51,5),Vector2(44,44)),false)
                var d:Dictionary=model.skills.definitions[model.SKILL_IDS[i]]
                _center(str(d.name),Rect2(r.position+Vector2(0,49),Vector2(146,20)),14,INK,true)
                var cost="frei" if d.cost_type=="none" else "%d %s"%[d.cost,{"momentum":"M","rage":"Z"}[d.cost_type]]
                _center("%.1f s · %s"%[d.cooldown,cost],Rect2(r.position+Vector2(0,68),Vector2(146,18)),13,MUTED)
            if logical_height>=1450:
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
            _panel(Rect2(38,177,644,235))
            if portrait:draw_texture_rect(portrait,Rect2(60,199,140,140),false)
            _text(model.hero_name,Vector2(226,225),28,INK,true)
            _text("Level %d · Kraft %d"%[model.level,model.power],Vector2(226,264),22,GOLD)
            _bar(Rect2(226,283,424,18),float(Progress.xp_in_level(model.profile.xp))/Progress.required(model.level),CYAN)
            _text("%d / %d XP"%[Progress.xp_in_level(model.profile.xp),Progress.required(model.level)],Vector2(226,330),18,MUTED)
            _text("Lokales Profil · Fortschritt automatisch gespeichert",Vector2(60,384),19,MUTED)
            for i in 2:
                var x=38+i*332
                _place("quests" if i==0 else "events",Rect2(x,440,312,176))
                _panel(Rect2(x,440,312,176))
                _icon("map" if i==0 else "crown",Rect2(x+126,459,60,60),GOLD)
                _center("Aufgaben" if i==0 else "Erfolge",Rect2(x,529,312,32),24,INK,true)
                _center("Ziele & Belohnungen" if i==0 else "Deine Meilensteine",Rect2(x,568,312,26),18,MUTED)
            if OS.is_debug_build():
                _panel(Rect2(368,631,314,61),Color.WHITE,Color.WHITE,16,"primary")
                _center("QA-Testlabor öffnen",Rect2(368,631,314,61),19,GOLD,true)
            _text("SPIELSTAND",Vector2(40,699),18,MUTED,true)
            for i in 2:
                var r=Rect2(38+i*332,715,312,62)
                _panel(r,Color.WHITE,Color.WHITE,16,"secondary")
                _center("Stand exportieren" if i==0 else "Stand importieren",r,18,INK,true)
            _text("EINSTELLUNGEN",Vector2(40,823),18,MUTED,true)
            for i in 2:
                var r=Rect2(38+i*332,845,312,62)
                _panel(r)
                _center(("Klang: "+("An" if sound_enabled else "Aus")) if i==0 else ("Effekte: "+["Voll","Reduziert","Aus"][effect_level]),r,18,INK,true)
            _panel(Rect2(38,943,644,88))
            _center("AUTO-Skills konfigurieren",Rect2(38,943,644,88),22,INK,true)
            _center("REALM ALLIANCE · 0.6.7 · Offline-Abenteuer",Rect2(38,1045,644,30),17,MUTED)
            if qa_mode:_center("TEMPORÄRES TESTPROFIL · KEINE SPEICHERUNG",Rect2(38,1069,644,27),15,GOLD,true)
            if model.read_only:
                _center("Spielstand geschützt · Diese Sitzung wird nicht gespeichert",Rect2(38,986,644,34),18,GOLD,true)
    _panel(Rect2(38, logical_height - 188, 644, 62), Color("#13314c"), CYAN.darkened(0.4))
    _center("Zurück zum Kampf", Rect2(38, logical_height - 188, 644, 62), 20, INK, true)

func draw_ellipse_platform() -> void:
    # Open showcase; a native geometric pedestal keeps body/equipment independent.
    draw_set_transform(Vector2(360,570),0,Vector2(1,.20))
    draw_circle(Vector2.ZERO,175,Color(.01,.05,.12,.7))
    draw_arc(Vector2.ZERO,171,0,TAU,80,Color(.35,.62,.8,.8),3,true)
    draw_arc(Vector2.ZERO,150,0,TAU,80,Color(.2,.7,1,.35),2,true)
    draw_set_transform(Vector2.ZERO)
