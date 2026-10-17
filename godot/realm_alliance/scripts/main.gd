extends Control

const CombatModel = preload("res://scripts/combat_model.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyVisual = preload("res://scripts/enemy_visual.gd")
const StageArt = preload("res://scripts/stage_art.gd")
const CombatLayout = preload("res://scripts/combat_layout.gd")
const CombatHUD = preload("res://scripts/combat_hud.gd")
const ImpactFX = preload("res://scripts/impact_fx.gd")
const BramblePreviewHero = preload("res://scripts/bramble_preview_hero.gd")
const BramblePreviewEnemy = preload("res://scripts/bramble_preview_enemy.gd")
const BramblePreviewSlash = preload("res://scripts/bramble_preview_slash.gd")
const ProductionArtGate = preload("res://scripts/production_art_gate.gd")
const ProductionHero = preload("res://scripts/production_hero.gd")
const ProductionEnemy = preload("res://scripts/production_enemy.gd")

# The shared art preview is reversible. Original procedural HeroRig/EnemyVisual survive.
const USE_SHARED_ART_PREVIEW: bool = true

var model
var hero
var enemy
var stage: Node2D
var touch_zone: Control
var hud: RACombatHUD
var skill_cooldowns: Array = [0, 0, 0]
var momentum: float = 0.0
var rage: float = 0.0
var active_tab: String = "Kampf"
var auto_timer: Timer
var wave_timer: Timer

var auto_enabled: bool = true
var attack_locked: bool = false
var queued_multiplier: float = 1.0
var queued_skill_index: int = -1
var _stage_home: Vector2 = Vector2.ZERO
var _last_stage_tap_ms: int = -1000
var _production_enabled: bool = false

func _ready() -> void:
    model = CombatModel.new(SaveStore.load_state())
    _production_enabled = ProductionArtGate.available()
    if _production_enabled:
        print("REALM: canonical hero, weapons, Golem and world art loaded")
    else:
        print("REALM: art pack not installed, using safe Bramble preview fallback")
    _build_arena()
    _build_hud()
    hero.impact.connect(_on_hero_impact)
    hero.action_finished.connect(_on_hero_action_finished)
    hero.equip_weapon(model.weapon_index)
    hero.set_upgrade_tier(model.upgrade_level)
    enemy.show_wave(model.wave)
    auto_timer = Timer.new()
    auto_timer.wait_time = 0.72
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
    if _production_enabled:
        var world := TextureRect.new()
        world.name = "WolkgartenProductionWorld"
        world.texture = load(ProductionArtGate.ROOT + "world/wolkgarten_battle_plate.png")
        world.set_anchors_preset(Control.PRESET_FULL_RECT)
        world.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        world.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        world.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(world)
    stage = Node2D.new()
    stage.name = "FixedCombatStage"
    add_child(stage)
    if not _production_enabled:
        stage.add_child(StageArt.new())
    if USE_SHARED_ART_PREVIEW and not _production_enabled:
        var stump := Sprite2D.new()
        stump.name = "SharedStyleSceneryPreview"
        stump.texture = preload("res://assets/preview/bramble/stage/glow_stump.png")
        stump.position = Vector2(-273.0, -115.0)
        stump.scale = Vector2.ONE * 0.41
        stump.modulate = Color(0.83, 0.95, 0.91, 0.62)
        stump.z_index = 1
        stage.add_child(stump)
        # Shared-style forest props remain isolated preview assets.
        # Their silhouettes occupy the formerly bare upper battle backdrop.
        var willow := Sprite2D.new()
        willow.name = "SharedStyleWillowPreview"
        willow.texture = preload("res://assets/preview/bramble/stage/swamp_willow.png")
        willow.position = Vector2(252.0, -282.0)
        willow.scale = Vector2.ONE * 0.65
        willow.modulate = Color(0.70, 0.82, 0.88, 0.54)
        willow.z_index = 1
        stage.add_child(willow)
        var lantern := Sprite2D.new()
        lantern.name = "SharedStyleLanternPreview"
        lantern.texture = preload("res://assets/preview/bramble/stage/lantern_post.png")
        lantern.position = Vector2(-267.0, -220.0)
        lantern.scale = Vector2.ONE * 0.62
        lantern.modulate = Color(0.95, 0.89, 0.79, 0.70)
        lantern.z_index = 1
        stage.add_child(lantern)
    if _production_enabled:
        hero = ProductionHero.new()
    else:
        hero = BramblePreviewHero.new() if USE_SHARED_ART_PREVIEW else HeroRig.new()
    hero.name = "CanonicalRealmwaechter" if _production_enabled else ("ArtPreviewHero" if USE_SHARED_ART_PREVIEW else "Realmwaechter")
    hero.position = Vector2(-185, 0)
    hero.scale = Vector2.ONE * (0.56 if _production_enabled else (0.82 if USE_SHARED_ART_PREVIEW else 1.77))
    hero.z_index = 4
    stage.add_child(hero)
    if _production_enabled:
        enemy = ProductionEnemy.new()
    else:
        enemy = BramblePreviewEnemy.new() if USE_SHARED_ART_PREVIEW else EnemyVisual.new()
    if _production_enabled:
        enemy.show_local_health = false
    enemy.name = "ProductionGolem" if _production_enabled else ("ArtPreviewEnemy" if USE_SHARED_ART_PREVIEW else "Enemy")
    enemy.position = Vector2(188, 0)
    enemy.scale = Vector2.ONE * (0.61 if _production_enabled else (0.91 if USE_SHARED_ART_PREVIEW else 1.58))
    enemy.z_index = 3
    stage.add_child(enemy)
    touch_zone = Control.new()
    touch_zone.name = "CombatTouchZone"
    touch_zone.mouse_filter = Control.MOUSE_FILTER_STOP
    touch_zone.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    touch_zone.gui_input.connect(_on_stage_input)
    add_child(touch_zone)

func _build_hud() -> void:
    hud = CombatHUD.new()
    hud.name = "CombatHUD"
    hud.model = model
    add_child(hud)
    hud.action.connect(_on_hud_action)

func _layout() -> void:
    if stage == null or hud == null:
        return
    var viewport_size = get_viewport_rect().size
    var safe_top = 0.0
    var safe_bottom = 0.0
    if OS.has_feature("android") or OS.has_feature("ios"):
        var safe = DisplayServer.get_display_safe_area()
        var screen = DisplayServer.screen_get_size()
        var units = viewport_size.y / maxf(1.0, screen.y)
        safe_top = safe.position.y * units
        safe_bottom = maxf(0, screen.y - safe.end.y) * units
    var metrics: Dictionary = CombatLayout.solve(viewport_size, safe_top, safe_bottom)
    stage.scale = Vector2.ONE * float(metrics["stage_scale"])
    _stage_home = metrics["stage_origin"]
    stage.position = _stage_home
    var zone: Rect2 = metrics["tap_rect"]
    touch_zone.position = zone.position
    touch_zone.size = zone.size
    hud.position = Vector2(metrics["ui_left"], safe_top)
    hud.scale = Vector2.ONE * float(metrics["ui_scale"])
    hud.configure(metrics["logical_height"])
    if _production_enabled:
        var tall = clampf((float(metrics["logical_height"]) - 1280.0) / 280.0, 0.0, 1.0)
        hero.scale = Vector2.ONE * lerpf(0.62, 0.72, tall)
        enemy.set_layout_scale(lerpf(0.74, 0.94, tall))

func _on_hud_action(id: String) -> void:
    match id:
        "Kampf", "Abenteuer", "Wesen", "Beute", "Mehr":
            active_tab = id
            hud.active_tab = id
            stage.visible = id == "Kampf"
            touch_zone.visible = id == "Kampf"
            hud.update_buttons()
            _refresh()
        "return":
            _on_hud_action("Kampf")
        "auto":
            _toggle_auto()
        "skill0":
            _on_skill(0)
        "skill1":
            _on_skill(1)
        "skill2":
            _on_skill(2)
        "locked":
            hud.notify("Noch gesperrt", "Diese Fähigkeit folgt später")
        "weapon":
            _cycle_weapon()
        "upgrade":
            _buy_upgrade()
        "mail", "settings":
            _on_hud_action("Mehr")
            hud.notify("Posteingang" if id == "mail" else "Einstellungen", "Dieser Bereich folgt später")
        "quests", "events":
            hud.notify("Aufgaben" if id == "quests" else "Events", "Dieser Bereich folgt später")

func _on_stage_input(event: InputEvent) -> void:
    # Deduplicate emulated mouse events originating from the same mobile tap.
    var pressed: bool = false
    if event is InputEventScreenTouch:
        pressed = event.pressed
    elif event is InputEventMouseButton:
        pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
    if pressed:
        var now: int = Time.get_ticks_msec()
        if now - _last_stage_tap_ms > 80:
            _last_stage_tap_ms = now
            _on_tap()
        touch_zone.accept_event()

func _on_tap() -> void:
    _try_attack(1.0, false)

func _try_attack(multiplier: float, is_skill: bool) -> bool:
    if active_tab != "Kampf" or attack_locked or model.enemy_hp <= 0:
        return false
    attack_locked = true
    queued_multiplier = multiplier
    if not is_skill:
        queued_skill_index = -1
    if not hero.play_attack(is_skill):
        attack_locked = false
        return false
    return true

func _on_hero_impact() -> void:
    var result: Dictionary = model.attack(queued_multiplier)
    if not result.get("valid", false):
        return
    momentum = minf(100.0, momentum + 9.0)
    rage = minf(100.0, rage + 6.0)
    enemy.play_hit()
    var empowered: bool = queued_multiplier > 1.0
    _impact_burst(empowered)
    _damage_popup(int(result["damage"]), empowered)
    if bool(result["killed"]):
        enemy.play_death()
        _reward_popup(int(result["gold_gain"]))
        hud.notify("%d Siege in Folge" % model.total_kills, "+%d Gold · +1 Fortschritt" % result["gold_gain"])
        wave_timer.start(0.66)
    _persist()
    _refresh()

func _on_hero_action_finished() -> void:
    attack_locked = false

func _on_auto_tick() -> void:
    if auto_enabled:
        _try_attack(1.0, false)

func _on_skill(index: int = 0) -> void:
    if index < 0 or index > 2 or Time.get_ticks_msec() < int(skill_cooldowns[index]):
        return
    if (index == 1 and momentum < 25) or (index == 2 and rage < 40):
        return
    if _try_attack([2.8, 2.0, 4.0][index], true):
        queued_skill_index = index
        skill_cooldowns[index] = Time.get_ticks_msec() + int([5500, 8000, 15000][index])
        if index == 1:
            momentum -= 25
        if index == 2:
            rage -= 40
        _refresh()

func _toggle_auto() -> void:
    auto_enabled = not auto_enabled
    _refresh()

func _cycle_weapon() -> void:
    model.cycle_weapon()
    hero.equip_weapon(model.weapon_index)
    hud.notify("Waffe gewechselt", CombatModel.WEAPON_IDS[model.weapon_index].capitalize())
    _persist()
    _refresh()

func _buy_upgrade() -> void:
    if model.try_upgrade():
        hero.set_upgrade_tier(model.upgrade_level)
        hud.notify("Angriff aufgewertet", "+%d · %d Schaden" % [model.upgrade_level, model.hero_damage()])
        _persist()
        _refresh()

func _advance_wave() -> void:
    if model.advance_wave():
        enemy.show_wave(model.wave)
        _persist()
        _refresh()

func _impact_burst(is_skill: bool) -> void:
    if USE_SHARED_ART_PREVIEW and not _production_enabled:
        var slash: RABramblePreviewSlash = BramblePreviewSlash.new()
        slash.configure(is_skill)
        slash.position = enemy.position + Vector2(-35.0, -165.0)
        slash.z_index = 12
        stage.add_child(slash)
    else:
        var flash: RAImpactFX = ImpactFX.new()
        flash.configure(is_skill, queued_skill_index)
        flash.position = enemy.position + Vector2(-35.0, -240.0)
        flash.z_index = 12
        stage.add_child(flash)
    var shake: Tween = create_tween()
    stage.position = _stage_home + Vector2(-7.0 if is_skill else -3.0, 1.5) * stage.scale.x
    shake.tween_property(stage, "position", _stage_home, 0.13)

func _damage_popup(amount: int, is_skill: bool = false) -> void:
    var popup := Label.new()
    popup.text = ("SKILL!\n" if is_skill else "") + str(amount)
    popup.add_theme_font_override("font", hud.bold)
    popup.add_theme_font_size_override("font_size", 58 if is_skill else 44)
    popup.add_theme_constant_override("outline_size", 9)
    popup.add_theme_color_override("font_outline_color", Color("#071120"))
    popup.add_theme_color_override("font_color", Color("#ffc17b") if is_skill else Color("#ffe5a4"))
    popup.add_theme_color_override("font_shadow_color", Color("#211626"))
    popup.add_theme_constant_override("shadow_offset_x", 3)
    popup.add_theme_constant_override("shadow_offset_y", 4)
    popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup.z_index = 18
    stage.add_child(popup)
    popup.position = Vector2(30.0 + randf_range(-20, 20), enemy.position.y - enemy.scale.y * 500.0)
    popup.size = Vector2(260, 150)
    popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup.scale = Vector2(0.84, 0.84)
    var fly := create_tween()
    fly.set_parallel(true)
    fly.tween_property(popup, "position:y", popup.position.y - 92.0, 0.52)
    fly.tween_property(popup, "scale", Vector2(1.17, 1.17), 0.24)
    fly.tween_property(popup, "modulate:a", 0.0, 0.52).set_delay(0.14)
    fly.finished.connect(popup.queue_free)

func _reward_popup(gained: int) -> void:
    var popup := Label.new()
    popup.text = "+%d GOLD" % gained
    popup.add_theme_font_size_override("font_size", 27)
    popup.add_theme_color_override("font_color", Color("#f5c46e"))
    popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
    popup.z_index = 17
    stage.add_child(popup)
    popup.position = enemy.position + Vector2(-53.0, -40.0)
    var fly := create_tween()
    fly.set_parallel(true)
    fly.tween_property(popup, "position:y", popup.position.y - 52.0, 0.63)
    fly.tween_property(popup, "modulate:a", 0.0, 0.63).set_delay(0.10)
    fly.finished.connect(popup.queue_free)

func _refresh() -> void:
    enemy.set_health(model.enemy_hp, model.enemy_max_hp)
    hud.auto_enabled = auto_enabled
    hud.cooldowns = skill_cooldowns
    hud.momentum = momentum
    hud.rage = rage
    if _production_enabled:
        hud.weapon_texture = load(ProductionArtGate.ROOT + "weapons/" + ProductionArtGate.WEAPONS[model.weapon_index] + ".png")
    hud.update_buttons()
    hud.queue_redraw()

func _persist() -> void:
    SaveStore.save_state(model.snapshot())

func _exit_tree() -> void:
    if model != null:
        _persist()

