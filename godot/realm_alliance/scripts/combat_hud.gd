extends Control
class_name RACombatHUD

# Authored at 720 logical pixels; main.gd scales this native Godot UI once.
# All input regions are real Buttons, kept separate from paint and arena input.
signal action(id: String)
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
const HeroPreview = preload("res://scripts/production_hero.gd")
var preview
var hit_flash: float = 0.0
var model
var auto_enabled = true
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
var portrait: AtlasTexture
var _top_fade: GradientTexture2D
var _bottom_fade: GradientTexture2D
var _redraw_clock = 0.0

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
    _top_fade = _fade(Color(0.015, 0.055, 0.12, 0.92), Color(0.015, 0.055, 0.12, 0.0))
    _bottom_fade = _fade(Color(0.015, 0.035, 0.07, 0.0), Color(0.015, 0.035, 0.07, 0.99))
    for id in ["mail", "settings", "auto", "skill0", "skill1", "locked", "skill2", "Kampf", "Abenteuer", "Wesen", "Beute", "Mehr", "weapon", "upgrade", "return", "quests", "events", "restart", "look", "aura", "save_export", "save_import", "equip_steel", "equip_crystal", "equip_ember", "equip_rune_gold", "equip_shadow_violet"]:
        var b = Button.new()
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
        preview.position = Vector2(300,589)
        preview.scale = Vector2.ONE * 0.66
        preview.visible = false
        add_child(preview)
    configure(1280.0)
    toast_until = Time.get_ticks_msec()+3500

func _tooltip(id: String) -> String:
    return {"auto":"Automatischen Standardangriff umschalten", "skill0":"Himmelsklinge · 2,8× Schaden", "skill1":"Arkanblick · 25 Momentum · 5s Markierung (+35% Schaden)", "skill2":"Zornesflamme · 40 Zorn · 4s Brennen", "locked":"Wächterwall · Ab Level 2 · 20 Momentum", "weapon":"Separates Schwert wechseln", "upgrade":"Angriff mit Gold aufwerten", "return":"Zurück zum Kampf", "mail":"Posteingang", "settings":"Einstellungen", "quests":"Aufgaben", "events":"Events"}.get(id, id)

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
    _place("mail", Rect2(612, 18, 44, 52))
    _place("settings", Rect2(664, 18, 44, 52))
    _place("auto", Rect2(628, controls_top + 3, 70, 70))
    for i in 4:
        var ids = ["skill0", "skill1", "locked", "skill2"]
        _place(ids[i], Rect2(34 + i * 174, controls_top + 82, 130, 142))
    for i in 5:
        _place(["Kampf", "Abenteuer", "Wesen", "Beute", "Mehr"][i], Rect2(i * 144 + 4, height - 94, 136, 88))
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
    update_buttons()
    queue_redraw()

func _place(id: String, r: Rect2) -> void:
    buttons[id].position = r.position
    buttons[id].size = r.size

func update_buttons() -> void:
    if buttons.is_empty() or model == null:
        return
    var in_combat = active_tab == "Kampf"
    if preview:
        preview.visible = active_tab == "Wesen"
        preview.equip_weapon(model.weapon_index)
        preview.set_look(model.profile.look,bool(model.profile.aura) and model.level>=3)
    for id in ["auto", "skill0", "skill1", "locked", "skill2"]:
        buttons[id].visible = in_combat
    for id in ["weapon", "upgrade", "look", "aura"]:
        buttons[id].visible = active_tab == "Wesen"
    for id in ["quests", "events", "save_export", "save_import"]:
        buttons[id].visible = active_tab == "Mehr"
    buttons["return"].visible = not in_combat
    buttons["restart"].visible = in_combat and model.outcome in ["victory","defeat"]
    var ids=["sky_blade","arcane_eye","rage_flame","guardian_wall"]
    var controls=["skill0","skill1","skill2","locked"]
    for i in 4:
        buttons[controls[i]].disabled = model.outcome!="fighting" or not model.skills.can_cast(ids[i],model.clock,model.level,{"momentum":model.momentum,"rage":model.rage})
    # Locked defense remains tappable to explain the actual level requirement.
    if model.level<2: buttons["locked"].disabled=false
    buttons["upgrade"].disabled = model.gold < model.upgrade_cost() or model.upgrade_level>=19 or (model.upgrade_level>=2 and model.profile.shards<1)
    for id in Equipment.IDS:
        var b: Button=buttons["equip_"+id]
        b.visible=active_tab=="Wesen"
        b.disabled=not model.profile.inventory.has(id)
        b.tooltip_text=Equipment.definition(id).description
        if active_tab=="Wesen":
            var i=Equipment.IDS.find(id)
            _place("equip_"+id,Rect2(38+(i%2)*332,813+floori(i/2.0)*76,312,66))
        elif active_tab=="Beute":
            for i in mini(7,model.profile.loot.size()):
                var item:Dictionary=model.profile.loot[i]
                if item.kind=="weapon" and item.id==id:
                    b.visible=true
                    b.disabled=false
                    _place("equip_"+id,Rect2(38,270+i*86,644,74))

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

func _panel(r: Rect2, color: Color = Color(0.015, 0.045, 0.09, 0.9), edge: Color = Color(0.28, 0.52, 0.71, 0.45), radius: int = 16) -> void:
    var s = StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = edge
    s.set_border_width_all(1)
    s.set_corner_radius_all(radius)
    s.anti_aliasing = true
    draw_style_box(s, r)

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
    _panel(r, Color("#050c17"), Color(0.37,0.52,0.65,0.35), 7)
    var fill = r.grow(-3)
    fill.size.x *= clampf(ratio, 0, 1)
    if fill.size.x > 1:
        _panel(fill, color.darkened(0.15), color.lightened(0.15), 5)
        draw_line(fill.position + Vector2(5, 3), fill.position + Vector2(maxf(5, fill.size.x - 5), 3), Color(1,1,1,0.25), 2, true)

func _draw() -> void:
    if model == null or _top_fade == null:
        return
    var h = logical_height
    if active_tab != "Kampf":
        draw_rect(Rect2(0, 0, 720, h), Color(0.015,0.035,0.075,0.91))
    draw_texture_rect(_top_fade, Rect2(0, 0, 720, 190), false)
    _draw_header()
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
        _icon(["gold", "gem", "shard"][i], Rect2(x + 6, 31, 28, 28))
        _text(_amount(model.gold) if i == 0 else "—", Vector2(x + 39, 53), 19, INK, true)
    for i in 2:
        _panel(Rect2(612 + i * 52, 18, 44, 52), Color(0.01,0.035,0.08,0.91))
        _icon("mail" if i == 0 else "gear", Rect2(621 + i * 52, 30, 26, 26))

func _amount(n: int) -> String:
    if n >= 1000000:
        return "%.1fM" % (n / 1000000.0)
    if n >= 10000:
        return "%.1fK" % (n / 1000.0)
    return str(n)

func _draw_combat() -> void:
    _panel(Rect2(115, 98, 490, 48), Color(0.015,0.05,0.105,0.94), Color(0.23,0.51,0.72,0.65), 24)
    _icon("mountain", Rect2(131, 107, 31, 30))
    var chapter = 1 + (model.wave - 1) / 5
    var node = (model.wave - 1) % 5
    _text("Wolkgarten %d-%d" % [chapter, node + 1], Vector2(174, 128), 21, INK, true)
    for i in 5:
        var p = Vector2(423 + i * 28, 122)
        if i < 4:
            draw_line(p, p + Vector2(28, 0), Color("#39516d"), 3, true)
        draw_circle(p, 6 if i != node else 8, CYAN if i <= node else Color("#536680"))
    _icon("crown", Rect2(554, 108, 29, 29), GOLD if node == 4 else MUTED)
    var boss = model.enemy_definition.kind == "boss"
    var elite = model.enemy_definition.kind == "elite"
    _panel(Rect2(240, 168, 458, 106), Color(0.01,0.035,0.075,0.94), Color(0.55,0.25,0.3,0.8) if boss else Color(0.28,0.52,0.71,0.55))
    _icon("crown" if boss else "rock", Rect2(254, 180, 33, 33), GOLD if boss else Color.WHITE)
    _text(model.enemy_definition.name, Vector2(296, 202), 23, INK, true)
    _text("Lv. %d" % model.wave, Vector2(615, 201), 18, MUTED)
    _bar(Rect2(255, 217, 428, 24), float(model.enemy_hp) / model.enemy_max_hp, Color("#f23754"))
    _center("%d / %d" % [model.enemy_hp, model.enemy_max_hp], Rect2(255, 216, 428, 24), 16, INK, true)
    _text("BOSS" if boss else ("ELITE" if elite else "NORMAL"), Vector2(257, 261), 12, GOLD if boss else (PURPLE if elite else MUTED), true)
    var statuses=[]
    if model.enemy_status.has("mark",model.clock): statuses.append(["eye","%.1fs"%model.enemy_status.remaining("mark",model.clock)])
    if model.enemy_status.has("burn",model.clock): statuses.append(["flame","%.1fs"%model.enemy_status.remaining("burn",model.clock)])
    if statuses.is_empty():
        _text("%d / 5 · Streifzug"%(model.encounter+1),Vector2(375,263),14,MUTED)
    else:
        for i in statuses.size():
            _icon(statuses[i][0],Rect2(363+i*105,247,21,21))
            _text(statuses[i][1],Vector2(389+i*105,263),13,INK)
    if model.behavior.state=="windup" and model.outcome=="fighting":
        _panel(Rect2(293,282,355,32),Color(0.22,0.035,0.035,0.92),Color("#e98f65"),12)
        var cue="Doppelschlag" if model.enemy_definition.pattern=="double" else ("Wuchtschlag" if boss else "Angriff")
        _center("%s in %.1fs"%[cue,maxf(0,model.behavior.deadline-model.clock)],Rect2(293,282,355,32),16,Color("#ffca9b"),true)
    if toast_until > Time.get_ticks_msec() or toast_until == 0:
        _panel(Rect2(18, 169, 207, 91), Color(0.02,0.04,0.07,0.87), Color(0.66,0.46,0.15,0.62))
        _icon("flame", Rect2(28, 184, 20, 27))
        var title = toast_title if toast_until != 0 else "Wolkgarten"
        _text(title, Vector2(54, 196), 13, GOLD, true, 166)
        _text(toast_detail if toast_until != 0 else "Tippen zum Angriff", Vector2(30, 242), 12, MUTED, false, 186)
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
    _center("Arena antippen zum Angreifen", Rect2(0, controls_top - 22, 720, 20), 13, Color(0.88,0.96,1,0.7))

func _resource(r: Rect2, icon: String, value: String, ratio: float, color: Color) -> void:
    _panel(r, Color(0.015,0.025,0.04,0.9), Color(0.4,0.5,0.6,0.45), 15)
    _icon(icon, Rect2(r.position + Vector2(9, 12), Vector2(31, 34)))
    _center(value, Rect2(r.position + Vector2(46, 4), Vector2(r.size.x - 57, 23)), 16, INK, true)
    _bar(Rect2(r.position + Vector2(46, 32), Vector2(r.size.x - 58, 14)), ratio, color)

func _skill(i: int, center: Vector2) -> void:
    var skill_index=[0,1,3,2][i]
    var id=["sky_blade","arcane_eye","guardian_wall","rage_flame"][i]
    var d:Dictionary=model.skills.definitions[id]
    var locked=model.level<int(d.unlock_level)
    var cd=model.skills.remaining(id,model.clock)
    var cost_resource=model.momentum if d.cost_type=="momentum" else model.rage
    var unaffordable=d.cost_type!="none" and cost_resource<float(d.cost)
    var r=Rect2(center-Vector2(66,66),Vector2(132,132))
    draw_texture_rect(orbs[i],r,false,Color(0.57,0.63,0.73) if locked or unaffordable else Color.WHITE)
    if i==2 and not locked:
        draw_circle(center,37,Color("#112b50"))
        _icon("shield",Rect2(center-Vector2(26,29),Vector2(52,58)))
    if cd>0:
        var polygon=PackedVector2Array([center])
        var ratio=clampf(cd/float(d.cooldown),0,1)
        for j in range(33):
            var angle=-PI/2+TAU*ratio*j/32.0
            polygon.append(center+Vector2(cos(angle),sin(angle))*55)
        draw_colored_polygon(polygon,Color(0,0.015,0.06,0.72))
        draw_arc(center,58,-PI/2,-PI/2+TAU*ratio,64,Color(0.8,0.94,1,0.8),2,true)
        _center("%.1f"%cd,Rect2(center-Vector2(45,20),Vector2(90,40)),28,INK,true)
    _center(["Klinge","Arkanblick","Wächterwall","Zornesflamme"][i],Rect2(center.x-80,center.y+66,160,22),14,MUTED if locked else INK,true)
    if cd<=0:
        _panel(Rect2(center.x-43,center.y+39,86,23),Color("#061122"),Color(0.4,0.55,0.7,0.7),10)
        var label="Lv. %d"%d.unlock_level if locked else ("BEREIT" if d.cost_type=="none" else "%d %s"%[d.cost,"M" if d.cost_type=="momentum" else "Z"])
        _center(label,Rect2(center.x-43,center.y+39,86,23),12,MUTED if locked or unaffordable else CYAN,true)

func _draw_result() -> void:
    draw_rect(Rect2(0,96,720,logical_height-192),Color(0.01,0.025,0.055,0.68))
    _panel(Rect2(112,365,496,300),Color("#091a30"),GOLD if model.outcome=="victory" else Color("#ff6b72"),22)
    _icon("crown" if model.outcome=="victory" else "heart",Rect2(327,385,66,66))
    _center("STREIFZUG GESCHAFFT" if model.outcome=="victory" else "BESIEGT",Rect2(120,461,480,42),25,GOLD if model.outcome=="victory" else INK,true)
    _center("Gold, XP und Beute bleiben erhalten.",Rect2(120,512,480,32),17,MUTED)
    _panel(Rect2(170,570,380,62),Color("#133d5c"),CYAN)
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
            _panel(Rect2(x + 6, y + 1, 132, 89), Color(0.30,0.075,0.55,0.48), Color(0.65,0.3,1,0.95), 14)
            draw_line(Vector2(x + 28,y + 1), Vector2(x + 116,y + 1), PURPLE, 3, true)
        _icon(["swords", "map", "paw", "chest", "grid"][i], Rect2(x + 53, y + 13, 38, 38), INK if active else MUTED)
        _center(tab, Rect2(x, y + 57, 144, 26), 17, INK if active else MUTED, active)

func _rarity(id: String) -> String:
    return {"common":"Gewöhnlich","rare":"Selten","epic":"Episch"}.get(id,id)

func _draw_shell() -> void:
    _center(active_tab, Rect2(0, 105, 720, 48), 31, INK, true)
    match active_tab:
        "Abenteuer":
            var names = ["Wolkgarten", "Glutkern", "Frosthain", "Kristallhöhlen", "Sonnenruinen"]
            for i in 5:
                var y = 192 + i * 98
                _panel(Rect2(38, y, 644, 80), Color(0.02,0.07,0.13,0.9))
                _icon("mountain" if i == 0 else "lock", Rect2(57, y + 20, 38, 38), CYAN if i == 0 else MUTED)
                _text(names[i], Vector2(117, y + 34), 22, INK if i == 0 else MUTED, true)
                _text("Aktuell · Welle %d" % model.wave if i == 0 else "Noch nicht verfügbar", Vector2(117, y + 59), 16, MUTED)
                if i == 0:
                    _icon("star", Rect2(615, y + 24, 29, 29), GOLD)
        "Wesen":
            _panel(Rect2(38,177,644,440),Color(0.015,0.055,0.11,0.92))
            _center("Realmwächter · Lv. %d"%model.level,Rect2(38,191,644,38),25,INK,true)
            _center("%s · Waffenlevel %d"%[Equipment.definition(model.profile.equipped).name,model.upgrade_level+1],Rect2(38,231,644,28),18,GOLD)
            _center(Equipment.definition(model.profile.equipped).description,Rect2(50,269,620,30),15,MUTED)
            _text("Angriff %d"%model.hero_damage(),Vector2(61,595),19,GOLD,true)
            _text("HP %d · Kraft %d"%[model.player_max_hp,model.hero_damage()*10+model.player_max_hp],Vector2(426,595),16,MUTED)
            _panel(Rect2(38,644,310,64),Color("#11334f"),CYAN.darkened(0.3))
            _panel(Rect2(368,644,314,64),Color("#3c2851"),PURPLE.darkened(0.2))
            _center("Waffe wechseln",Rect2(38,644,310,64),20,INK,true)
            _center("Aufwerten · %d G%s"%[model.upgrade_cost()," +1 Splitter" if model.upgrade_level>=2 else ""],Rect2(368,644,314,64),15,MUTED if buttons.upgrade.disabled else GOLD,true)
            _panel(Rect2(38,733,310,58),Color("#123b3a"),CYAN.darkened(0.3))
            _panel(Rect2(368,733,314,58),Color("#18233b"),PURPLE.darkened(0.4))
            _center("Umhang: %s"%("Smaragd" if model.profile.look=="emerald" else "Original"),Rect2(38,733,310,58),17,INK,true)
            _center("Aura: %s"%("Lv. 3" if model.level<3 else ("An" if model.profile.aura else "Aus")),Rect2(368,733,314,58),17,MUTED if model.level<3 else CYAN,true)
            for i in 5:
                var id:String=Equipment.IDS[i]
                var owned=model.profile.inventory.has(id)
                var d=Equipment.definition(id)
                var r=Rect2(38+(i%2)*332,813+floori(i/2.0)*76,312,66)
                var color=GOLD if id==model.profile.equipped else (PURPLE if d.rarity=="epic" else CYAN)
                _panel(r,Color(0.025,0.07,0.13,0.95),color if owned else Color("#33445b"))
                _icon("swords" if owned else "lock",Rect2(r.position+Vector2(12,17),Vector2(29,29)),color if owned else MUTED)
                _text(d.name, r.position+Vector2(50,27),16,INK if owned else MUTED,true)
                _text("Lv. %d · %s"%[model.profile.inventory[id].level,_rarity(d.rarity)] if owned else "Im Streifzug finden",r.position+Vector2(50,50),13,color if owned else MUTED)
        "Beute":
            _panel(Rect2(38,178,644,68))
            _icon("gold",Rect2(56,194,33,33))
            _text(str(model.gold),Vector2(101,220),22,GOLD,true)
            _icon("shard",Rect2(288,194,33,33))
            _text("%d Splitter"%model.profile.shards,Vector2(335,220),20,CYAN,true)
            _text("%d Waffen"%model.profile.inventory.size(),Vector2(537,220),17,MUTED)
            if model.profile.loot.is_empty():
                _center("Beute erscheint hier nach dem ersten Sieg.",Rect2(38,290,644,80),20,MUTED)
            for i in mini(7,model.profile.loot.size()):
                var item:Dictionary=model.profile.loot[i]
                var r=Rect2(38,270+i*86,644,74)
                var color=PURPLE if item.rarity=="epic" else (CYAN if item.rarity=="rare" else MUTED)
                _panel(r,Color(0.02,0.055,0.11,0.94),color)
                _icon("swords" if item.kind=="weapon" else "shard",Rect2(r.position+Vector2(17,19),Vector2(35,35)),color)
                _text(item.name,r.position+Vector2(71,29),19,INK,true)
                _text(_rarity(item.rarity),r.position+Vector2(71,54),14,color)
                _text("Anlegen" if item.kind=="weapon" else "×%d"%item.count,r.position+Vector2(520,43),17,GOLD if item.kind=="weapon" else MUTED,true)
        "Mehr":
            for i in 2:
                var x = 38 + i * 332
                _panel(Rect2(x, 204, 312, 88))
                _icon("map" if i == 0 else "flame", Rect2(x + 18, 225, 43, 43))
                _text("Aufgaben" if i == 0 else "Events", Vector2(x + 80, 253), 22, INK, true)
            _panel(Rect2(38, 320, 644, 180))
            _text("REALM ALLIANCE", Vector2(61, 361), 24, INK, true)
            _text("Wolkgarten · Combat 0.6.2", Vector2(61, 402), 18, MUTED)
            _text("Spielstand wird lokal gespeichert.", Vector2(61, 447), 18, MUTED)
            _text("Weitere Bereiche werden nach und nach geöffnet.", Vector2(61, 479), 17, MUTED)
            for i in 2:
                var r=Rect2(38+i*332,715,312,62)
                _panel(r,Color("#13314b"),CYAN.darkened(0.4))
                _center("Stand exportieren" if i==0 else "Stand importieren",r,18,INK,true)
            _center("Android-Preview: separater Spielstand",Rect2(38,790,644,30),16,MUTED)
            if model.read_only:
                _panel(Rect2(38,527,644,150),Color("#362032"),Color("#ffb580"))
                _text("Spielstand geschützt",Vector2(61,566),23,GOLD,true)
                _text("Die Originaldatei bleibt unverändert.",Vector2(61,607),18,INK)
                _text("Diese Sitzung wird nicht gespeichert.",Vector2(61,642),18,MUTED)
    if toast_until > Time.get_ticks_msec():
        var toast_y=maxf(1040,logical_height-265) if active_tab=="Wesen" else logical_height-265
        _panel(Rect2(38,toast_y,644,40),Color("#102139"),CYAN.darkened(0.5))
        _center(toast_title+" · "+toast_detail,Rect2(48,toast_y,624,40),14,INK)
    _panel(Rect2(38, logical_height - 188, 644, 62), Color("#13314c"), CYAN.darkened(0.4))
    _center("Zurück zum Kampf", Rect2(38, logical_height - 188, 644, 62), 20, INK, true)
