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
    for id in ["mail", "settings", "auto", "skill0", "skill1", "locked", "skill2", "Kampf", "Abenteuer", "Wesen", "Beute", "Mehr", "weapon", "upgrade", "return", "quests", "events"]:
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
    configure(1280.0)

func _tooltip(id: String) -> String:
    return {"auto":"Automatischen Standardangriff umschalten", "skill0":"Himmelsklinge · 2,8× Schaden", "skill1":"Arkaner Blick · 25 Momentum", "skill2":"Zornesflamme · 40 Zorn", "locked":"Fähigkeit noch nicht verfügbar", "weapon":"Separates Schwert wechseln", "upgrade":"Angriff mit Gold aufwerten", "return":"Zurück zum Kampf", "mail":"Posteingang", "settings":"Einstellungen", "quests":"Aufgaben", "events":"Events"}.get(id, id)

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
    if buttons.is_empty():
        return
    var in_combat = active_tab == "Kampf"
    for id in ["auto", "skill0", "skill1", "locked", "skill2"]:
        buttons[id].visible = in_combat
    for id in ["weapon", "upgrade"]:
        buttons[id].visible = active_tab == "Wesen"
    for id in ["quests", "events"]:
        buttons[id].visible = active_tab == "Mehr"
    buttons["return"].visible = not in_combat
    if model == null:
        return
    var now = Time.get_ticks_msec()
    buttons["skill0"].disabled = now < int(cooldowns[0]) or model.enemy_hp <= 0
    buttons["skill1"].disabled = now < int(cooldowns[1]) or momentum < 25 or model.enemy_hp <= 0
    buttons["skill2"].disabled = now < int(cooldowns[2]) or rage < 40 or model.enemy_hp <= 0
    buttons["upgrade"].disabled = model.gold < model.upgrade_cost() or model.upgrade_level >= 500

func notify(title: String, detail: String, seconds: float = 3.0) -> void:
    toast_title = title
    toast_detail = detail
    toast_until = Time.get_ticks_msec() + int(seconds * 1000.0)
    queue_redraw()

func _process(delta: float) -> void:
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

func _draw_header() -> void:
    _panel(Rect2(12, 12, 225, 68), Color(0.015,0.055,0.12,0.91))
    _panel(Rect2(15, 14, 64, 64), Color("#142840"), GOLD.darkened(0.3), 17)
    if portrait:
        draw_texture_rect(portrait, Rect2(16, 13, 63, 63), false)
    var level = 1 + model.total_kills / 10
    _text("Lv. %d" % level, Vector2(89, 40), 22, INK, true)
    _bar(Rect2(89, 51, 101, 11), float(model.total_kills % 10) / 10.0, CYAN)
    _text("%d%%" % ((model.total_kills % 10) * 10), Vector2(195, 61), 13, MUTED)
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
    var boss = model.wave % 5 == 0
    _panel(Rect2(240, 168, 458, 106), Color(0.01,0.035,0.075,0.94), Color(0.55,0.25,0.3,0.8) if boss else Color(0.28,0.52,0.71,0.55))
    _icon("crown" if boss else "rock", Rect2(254, 180, 33, 33), GOLD if boss else Color.WHITE)
    _text("Steingolem", Vector2(296, 202), 25, INK, true)
    _text("Lv. %d" % model.wave, Vector2(615, 201), 18, MUTED)
    _bar(Rect2(255, 217, 428, 24), float(model.enemy_hp) / model.enemy_max_hp, Color("#f23754"))
    _center("%d / %d" % [model.enemy_hp, model.enemy_max_hp], Rect2(255, 216, 428, 24), 16, INK, true)
    _text("BOSS" if boss else "NORMAL", Vector2(257, 261), 12, GOLD if boss else MUTED, true)
    for i in 3:
        _icon(["flame", "shield", "rock"][i], Rect2(365 + i * 28, 247, 21, 21))
    _text("Erdpanzer", Vector2(461, 263), 14, MUTED)
    if toast_until > Time.get_ticks_msec() or toast_until == 0:
        _panel(Rect2(18, 169, 207, 91), Color(0.02,0.04,0.07,0.87), Color(0.66,0.46,0.15,0.62))
        _icon("flame", Rect2(29, 184, 31, 40))
        var title = toast_title if toast_until != 0 else "Wolkgarten"
        _text(title, Vector2(66, 197), 15, GOLD, true, 150)
        _text(toast_detail if toast_until != 0 else "Tippen zum Angriff", Vector2(30, 242), 12, MUTED, false, 186)
    draw_texture_rect(_bottom_fade, Rect2(0, controls_top - 90, 720, 330 + 90), false)
    var y = controls_top + 8
    _resource(Rect2(18, y, 248, 58), "heart", "100 / 100", 1.0, Color("#36df73"))
    _resource(Rect2(278, y, 165, 58), "eye", "%d%%" % momentum, momentum / 100.0, PURPLE)
    _resource(Rect2(455, y, 155, 58), "flame", "%d%%" % rage, rage / 100.0, Color("#ff8a22"))
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
    var locked = i == 2
    var index = i if i < 2 else 2
    var cd = 0.0 if locked else maxf(0, (float(cooldowns[index]) - Time.get_ticks_msec()) / 1000.0)
    var unaffordable = (i == 1 and momentum < 25) or (i == 3 and rage < 40)
    var r = Rect2(center - Vector2(66,66), Vector2(132,132))
    draw_texture_rect(orbs[i], r, false, Color(0.64,0.69,0.78) if unaffordable else Color.WHITE)
    if cd > 0:
        var polygon = PackedVector2Array([center])
        var ratio = cd / float(durations[index])
        for j in range(33):
            var angle = -PI / 2 + TAU * ratio * j / 32.0
            polygon.append(center + Vector2(cos(angle), sin(angle)) * 55)
        draw_colored_polygon(polygon, Color(0.0,0.015,0.06,0.72))
        draw_arc(center, 58, -PI/2, -PI/2 + TAU * ratio, 64, Color(0.8,0.94,1,0.8), 2, true)
        _center("%.1f" % cd, Rect2(center - Vector2(45, 20), Vector2(90, 40)), 28, INK, true)
    var label = ["Klinge", "Arkanblick", "Gesperrt", "Zornesflamme"][i]
    _center(label, Rect2(center.x - 80, center.y + 66, 160, 22), 14, MUTED if locked else INK, true)
    if not locked and cd <= 0:
        _panel(Rect2(center.x - 43, center.y + 39, 86, 23), Color("#061122"), Color(0.4,0.55,0.7,0.7), 10)
        _center("25 M" if i == 1 else ("40 Z" if i == 3 else "BEREIT"), Rect2(center.x - 43, center.y + 39, 86, 23), 12, MUTED if unaffordable else CYAN, true)

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
            _panel(Rect2(38, 177, 644, 440), Color(0.015,0.055,0.11,0.92))
            _center("Realmwächter", Rect2(38, 191, 644, 38), 26, INK, true)
            _center("Ausrüstung", Rect2(38, 232, 644, 26), 16, MUTED)
            if hero_texture:
                draw_texture_rect(hero_texture, Rect2(98, 265, 440, 352), false)
            if weapon_texture:
                draw_set_transform(Vector2(553, 442), -0.9)
                draw_texture_rect(weapon_texture, Rect2(-55, -35, 210, 70), false)
                draw_set_transform(Vector2.ZERO)
            _text("Angriff %d" % model.hero_damage(), Vector2(61, 595), 19, GOLD, true)
            _text("Aufwertung +%d" % model.upgrade_level, Vector2(445, 595), 18, MUTED)
            _panel(Rect2(38, 644, 310, 64), Color("#11334f"), CYAN.darkened(0.3))
            _panel(Rect2(368, 644, 314, 64), Color("#3c2851"), PURPLE.darkened(0.2))
            _center("Schwert wechseln", Rect2(38, 644, 310, 64), 20, INK, true)
            _center("Aufwerten · %d G" % model.upgrade_cost(), Rect2(368, 644, 314, 64), 18, MUTED if model.gold < model.upgrade_cost() else GOLD, true)
            _center("Wähle dein Schwert und verstärke deinen Angriff.", Rect2(38, 727, 644, 30), 16, MUTED)
        "Beute":
            _panel(Rect2(38, 190, 644, 237))
            _icon("chest", Rect2(308, 206, 104, 104))
            _center("%d Gold gesammelt" % model.gold, Rect2(38, 318, 644, 40), 29, GOLD, true)
            _center("%d Gegner besiegt" % model.total_kills, Rect2(38, 367, 644, 30), 18, MUTED)
            _center("Ausrüstungsbeute folgt in einem späteren Ausbau.", Rect2(38, 470, 644, 40), 18, MUTED)
        "Mehr":
            for i in 2:
                var x = 38 + i * 332
                _panel(Rect2(x, 204, 312, 88))
                _icon("map" if i == 0 else "flame", Rect2(x + 18, 225, 43, 43))
                _text("Aufgaben" if i == 0 else "Events", Vector2(x + 80, 253), 22, INK, true)
            _panel(Rect2(38, 320, 644, 180))
            _text("REALM ALLIANCE", Vector2(61, 361), 24, INK, true)
            _text("Wolkgarten · Combat UI 0.6.1", Vector2(61, 402), 18, MUTED)
            _text("Spielstand wird lokal gespeichert.", Vector2(61, 447), 18, MUTED)
            _text("Weitere Bereiche werden nach und nach geöffnet.", Vector2(61, 479), 17, MUTED)
    if toast_until > Time.get_ticks_msec():
        _panel(Rect2(38, logical_height - 265, 644, 52), Color("#102139"), CYAN.darkened(0.5))
        _center(toast_title + " · " + toast_detail, Rect2(48, logical_height - 265, 624, 52), 16, INK)
    _panel(Rect2(38, logical_height - 188, 644, 62), Color("#13314c"), CYAN.darkened(0.4))
    _center("Zurück zum Kampf", Rect2(38, logical_height - 188, 644, 62), 20, INK, true)
