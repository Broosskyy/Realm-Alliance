extends Control

const CombatModel = preload("res://scripts/combat_model.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyVisual = preload("res://scripts/enemy_visual.gd")
const StageArt = preload("res://scripts/stage_art.gd")

var model
var hero
var enemy
var stage: Node2D
var touch_zone: Button
var header: Label
var wave_info: Label
var hp_info: Label
var help_text: Label
var bottom_panel: PanelContainer
var auto_button: Button
var skill_button: Button
var weapon_button: Button
var upgrade_button: Button
var auto_timer: Timer
var wave_timer: Timer

var auto_enabled: bool = true
var attack_locked: bool = false
var queued_multiplier: float = 1.0
var skill_ready_at: int = 0
var ui_accumulator: float = 0.0

func _ready() -> void:
    model = CombatModel.new(SaveStore.load_state())
    _build_arena()
    _build_hud()
    hero.impact.connect(_on_hero_impact)
    hero.action_finished.connect(_on_hero_action_finished)
    hero.equip_weapon(model.weapon_index)
    hero.set_upgrade_tier(model.upgrade_level)
    enemy.show_wave(model.wave)
    auto_timer = Timer.new()
    auto_timer.wait_time = 0.85
    auto_timer.autostart = true
    add_child(auto_timer)
    auto_timer.timeout.connect(_on_auto_tick)
    wave_timer = Timer.new()
    wave_timer.one_shot = true
    add_child(wave_timer)
    wave_timer.timeout.connect(_advance_wave)
    get_viewport().size_changed.connect(_layout)
    _layout()
    _refresh()

func _build_arena() -> void:
    var background := ColorRect.new()
    background.color = Color("#0c1324")
    background.set_anchors_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    stage = Node2D.new()
    stage.name = "FixedCombatStage"
    add_child(stage)
    stage.add_child(StageArt.new())
    hero = HeroRig.new()
    hero.name = "Realmwaechter"
    hero.position = Vector2(-170, 118)
    hero.scale = Vector2(1.65, 1.65)
    stage.add_child(hero)
    enemy = EnemyVisual.new()
    enemy.name = "Enemy"
    enemy.position = Vector2(163, 118)
    enemy.scale = Vector2(1.48, 1.48)
    stage.add_child(enemy)
    touch_zone = Button.new()
    touch_zone.flat = true
    touch_zone.focus_mode = Control.FOCUS_NONE
    touch_zone.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    touch_zone.pressed.connect(_on_tap)
    add_child(touch_zone)

func _make_label(value: String, size: int, color: Color) -> Label:
    var node := Label.new()
    node.text = value
    node.add_theme_font_size_override("font_size", size)
    node.add_theme_color_override("font_color", color)
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(node)
    return node

func _make_button(text: String, parent: HBoxContainer) -> Button:
    var button := Button.new()
    button.text = text
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 65)
    button.add_theme_font_size_override("font_size", 19)
    button.add_theme_color_override("font_color", Color("#f6ead7"))
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#273a51")
    normal.set_corner_radius_all(12)
    normal.set_border_width_all(2)
    normal.border_color = Color("#627184")
    button.add_theme_stylebox_override("normal",normal)
    var down := normal.duplicate() as StyleBoxFlat
    down.bg_color = Color("#465e77")
    button.add_theme_stylebox_override("pressed", down)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("#354c67")
    button.add_theme_stylebox_override("hover", hover)
    button.focus_mode = Control.FOCUS_NONE
    parent.add_child(button)
    return button

func _build_hud() -> void:
    header = _make_label("REALM ALLIANCE", 36, Color("#e3c78f"))
    wave_info = _make_label("", 25, Color("#edf1f5"))
    hp_info = _make_label("", 23, Color("#b9d8d7"))
    help_text = _make_label("Combat Foundation 01 | Placeholder-Art", 16, Color("#9daab9"))
    bottom_panel = PanelContainer.new()
    var frame := StyleBoxFlat.new()
    frame.bg_color = Color("#111f32",0.96)
    frame.border_color = Color("#9c8865")
    frame.set_border_width_all(2)
    frame.set_corner_radius_all(20)
    frame.set_content_margin_all(12)
    bottom_panel.add_theme_stylebox_override("panel", frame)
    add_child(bottom_panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 10)
    bottom_panel.add_child(stack)
    var row1 := HBoxContainer.new()
    row1.add_theme_constant_override("separation", 8)
    stack.add_child(row1)
    var tap_button := _make_button("TAP", row1)
    tap_button.pressed.connect(_on_tap)
    auto_button = _make_button("AUTO: AN", row1)
    auto_button.pressed.connect(_toggle_auto)
    skill_button = _make_button("SKILL", row1)
    skill_button.pressed.connect(_on_skill)
    var row2 := HBoxContainer.new()
    row2.add_theme_constant_override("separation", 8)
    stack.add_child(row2)
    weapon_button = _make_button("SCHWERT", row2)
    weapon_button.pressed.connect(_cycle_weapon)
    upgrade_button = _make_button("UPGRADE", row2)
    upgrade_button.pressed.connect(_buy_upgrade)

func _layout() -> void:
    if stage == null:
        return
    var viewport_size := get_viewport_rect().size
    var width := viewport_size.x
    var height := viewport_size.y
    var scale_factor := minf(width / 720.0, height / 1100.0)
    stage.scale = Vector2.ONE * scale_factor
    stage.position = Vector2(width * 0.5, height * 0.49)
    touch_zone.position = Vector2(maxf(0.0, stage.position.x - 340.0 * scale_factor), stage.position.y - 260.0 * scale_factor)
    touch_zone.size = Vector2(680.0 * scale_factor, 470.0 * scale_factor)
    header.position = Vector2(26, 25)
    header.size = Vector2(width - 52, 50)
    wave_info.position = Vector2(26, 86)
    wave_info.size = Vector2(width - 52, 40)
    hp_info.position = Vector2(26, 131)
    hp_info.size = Vector2(width - 52, 40)
    help_text.position = Vector2(26, height - 255)
    help_text.size = Vector2(width - 52, 25)
    bottom_panel.position = Vector2(18, height - 219)
    bottom_panel.size = Vector2(width - 36, 203)

func _on_tap() -> void:
    _try_attack(1.0, false)

func _try_attack(multiplier: float, is_skill: bool) -> bool:
    if attack_locked or model.enemy_hp <= 0:
        return false
    attack_locked = true
    queued_multiplier = multiplier
    if not hero.play_attack(is_skill):
        attack_locked = false
        return false
    return true

func _on_hero_impact() -> void:
    var result: Dictionary = model.attack(queued_multiplier)
    if not result.get("valid", false):
        return
    enemy.play_hit()
    _damage_popup(int(result["damage"]))
    if bool(result["killed"]):
        enemy.play_death()
        wave_timer.start(0.66)
    _persist()
    _refresh()

func _on_hero_action_finished() -> void:
    attack_locked = false

func _on_auto_tick() -> void:
    if auto_enabled:
        _try_attack(1.0, false)

func _on_skill() -> void:
    if Time.get_ticks_msec() < skill_ready_at:
        return
    if _try_attack(2.8, true):
        skill_ready_at = Time.get_ticks_msec() + 5500
        _refresh()

func _toggle_auto() -> void:
    auto_enabled = not auto_enabled
    _refresh()

func _cycle_weapon() -> void:
    model.cycle_weapon()
    hero.equip_weapon(model.weapon_index)
    _persist()
    _refresh()

func _buy_upgrade() -> void:
    if model.try_upgrade():
        hero.set_upgrade_tier(model.upgrade_level)
        _persist()
        _refresh()

func _advance_wave() -> void:
    if model.advance_wave():
        enemy.show_wave(model.wave)
        _persist()
        _refresh()

func _damage_popup(amount: int) -> void:
    var popup := Label.new()
    popup.text = str(amount)
    popup.add_theme_font_size_override("font_size", 42)
    popup.add_theme_color_override("font_color", Color("#ffdb81"))
    popup.add_theme_color_override("font_shadow_color", Color("#191927"))
    popup.add_theme_constant_override("shadow_offset_x", 2)
    popup.add_theme_constant_override("shadow_offset_y", 3)
    add_child(popup)
    popup.position = stage.position + enemy.position * stage.scale.x + Vector2(-20, -170) * stage.scale.x
    var fly := create_tween()
    fly.set_parallel(true)
    fly.tween_property(popup, "position:y", popup.position.y - 82.0, 0.50)
    fly.tween_property(popup, "modulate:a", 0.0, 0.50)
    fly.finished.connect(popup.queue_free)

func _refresh() -> void:
    wave_info.text = "WELLE %d  •  GOLD %d  •  KILLS %d" % [model.wave, model.gold, model.total_kills]
    hp_info.text = "GEGNER %d / %d HP   |   DMG %d" % [model.enemy_hp, model.enemy_max_hp, model.hero_damage()]
    enemy.set_health(model.enemy_hp, model.enemy_max_hp)
    auto_button.text = "AUTO: AN" if auto_enabled else "AUTO: AUS"
    weapon_button.text = "WAFFE: %s" % CombatModel.WEAPON_IDS[model.weapon_index].to_upper()
    upgrade_button.text = "UPGRADE: %d G" % model.upgrade_cost()
    upgrade_button.disabled = model.gold < model.upgrade_cost()
    _update_skill_label()

func _update_skill_label() -> void:
    var seconds := maxi(0, int(ceil(float(skill_ready_at - Time.get_ticks_msec()) / 1000.0)))
    skill_button.disabled = seconds > 0
    skill_button.text = "SKILL %ds" % seconds if seconds > 0 else "SKILL"

func _process(delta: float) -> void:
    ui_accumulator += delta
    if ui_accumulator >= 0.25 and skill_button != null:
        ui_accumulator = 0.0
        _update_skill_label()

func _persist() -> void:
    SaveStore.save_state(model.snapshot())

func _exit_tree() -> void:
    if model != null:
        _persist()
