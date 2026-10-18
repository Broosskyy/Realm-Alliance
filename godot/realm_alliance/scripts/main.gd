extends Control
const CombatModel = preload("res://scripts/systems/combat_session.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const SaveTransfer=preload("res://scripts/save_transfer.gd")
var save_transfer
var _pending_import: Dictionary = {}
const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyVisual = preload("res://scripts/enemy_visual.gd")
const StageArt = preload("res://scripts/stage_art.gd")
const CombatLayout = preload("res://scripts/combat_layout.gd")
const CombatHUD = preload("res://scripts/combat_hud.gd")
const VFXController=preload("res://scripts/presentation/combat_vfx_controller.gd")
const CameraFeedback=preload("res://scripts/presentation/camera_feedback.gd")
const CombatAudio=preload("res://scripts/presentation/combat_audio.gd")
const PresentationSettings=preload("res://scripts/presentation/presentation_settings.gd")
var vfx
var camera_feedback=CameraFeedback.new()
var audio
var preferences=PresentationSettings.new()
const Feedback = preload("res://scripts/combat_feedback.gd")
const BramblePreviewHero = preload("res://scripts/bramble_preview_hero.gd")
const BramblePreviewEnemy = preload("res://scripts/bramble_preview_enemy.gd")
const ProductionArtGate = preload("res://scripts/production_art_gate.gd")
const ProductionHero = preload("res://scripts/production_hero.gd")
const ProductionEnemy = preload("res://scripts/production_enemy.gd")
const USE_SHARED_ART_PREVIEW = true
var model
var hero
var enemy
var stage: Node2D
var touch_zone: Control
var hud
var auto_enabled: bool = true
var active_tab: String = "Kampf"
var _production_enabled: bool = false
var _stage_home: Vector2
var _last_stage_tap_ms = -1000
var _auto_clock = 0.0
var _save_clock = 0.0
var _save_failed = false
var _last_visual_key = ""
var _ui_clock = 0.0

func _ready() -> void:
    model = CombatModel.new(SaveStore.load_state())
    _production_enabled = ProductionArtGate.available()
    _build_arena()
    _build_hud()
    vfx=VFXController.new();stage.add_child(vfx)
    audio=CombatAudio.new();add_child(audio)
    preferences.load_settings();_apply_preferences()
    if _production_enabled:hero.external_clock=true
    save_transfer=SaveTransfer.new()
    add_child(save_transfer)
    save_transfer.notice.connect(func(title,detail): hud.notify(title,detail,5))
    save_transfer.import_ready.connect(_confirm_import)
    _show_encounter()
    _sync_hero()
    get_viewport().size_changed.connect(_layout)
    _layout()
    _refresh()
    if model.outcome=="defeat" and _production_enabled: hero.play_death()
    if model.enemy_hp<=0: enemy.play_death()
    if model.load_error != "":
        hud.notify("Spielstand",model.load_error,12)
        if model.read_only: _on_hud_action("Mehr")
    if _production_enabled and not model.pending.is_empty():
        var d:Dictionary=model.pending.definition
        hero.play_action(str(d.id),float(d.windup),float(d.recovery),float(model.pending.hit_at)-float(d.windup))
        hero.sync_clock(model.clock)
    print("REALM 6.3: canonical hero, weapons and survival systems loaded")

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
    hud.name="CombatHUD"
    hud.z_index=100
    hud.model=model
    add_child(hud)
    hud.action.connect(_on_hud_action)

func _show_encounter() -> void:
    if _production_enabled:
        enemy.configure_enemy(model.enemy_definition)
    enemy.show_wave(model.wave)
    _layout()
    if vfx:
        vfx.clear();vfx.sync(model,hero.position,enemy.position)
        vfx.emit_effect("arcane_seal" if model.enemy_definition.kind=="normal" else "reward",enemy.position+Vector2(0,-70),230 if model.enemy_definition.kind=="normal" else 340,0.65,"spawn",7)
    camera_feedback.reset()

func _sync_hero() -> void:
    var key="%s:%d:%s:%s"%[model.profile.equipped,model.upgrade_level,model.profile.look,str(model.profile.aura)]
    if key!=_last_visual_key:
        _last_visual_key=key
        hero.equip_weapon(model.weapon_index)
        hero.set_upgrade_tier(model.upgrade_level)
        if _production_enabled: hero.set_look(model.profile.look,bool(model.profile.aura) and model.level>=3)
    if _production_enabled:
        var shield=model.hero_status.active.get("shield",{})
        hero.set_shield(model.hero_status.has("shield",model.clock),clampf(float(shield.get("amount",0))/maxf(1,model.player_max_hp*0.35),0,1))

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
        hero.scale = Vector2.ONE * lerpf(0.64, 0.82, tall)
        enemy.set_layout_scale(lerpf(0.72, 0.93, tall) if model.enemy_definition.visual == "golem" else 0.90)

func _on_hud_action(id: String) -> void:
    if id=="sound":
        preferences.sound=not preferences.sound;preferences.save_settings();_apply_preferences()
    elif id=="effects":
        preferences.effects=(preferences.effects+1)%3;preferences.save_settings();_apply_preferences()
    elif id=="settings":
        _on_hud_action("Mehr")
    elif id in ["Kampf","Abenteuer","Wesen","Beute","Mehr","return"]:
        active_tab="Kampf" if id=="return" else id
        hud.active_tab=active_tab
        stage.visible=active_tab=="Kampf"
        stage.process_mode=Node.PROCESS_MODE_INHERIT if active_tab=="Kampf" else Node.PROCESS_MODE_DISABLED
        touch_zone.visible=active_tab=="Kampf" and model.outcome=="fighting"
    elif id=="auto":
        auto_enabled=not auto_enabled
    elif id.begins_with("skill"):
        _on_skill(int(id.trim_prefix("skill")))
    elif id=="locked":
        if not _on_skill(3): hud.notify("Wächterwall","Ab Heldenlevel 2 · 20 Momentum")
    elif id=="restart":
        if model.restart():
            if _production_enabled: hero.revive()
            _consume_events()
            _persist()
    elif id=="weapon":
        model.cycle_weapon();_sync_hero();_persist()
    elif id.begins_with("equip_"):
        var item=id.trim_prefix("equip_")
        if model.equip(item):
            _sync_hero();_persist()
            hud.notify("Angelegt",model.Equipment.definition(item).name)
        else: hud.notify("Noch nicht gefunden","Waffe im Streifzug erbeuten")
    elif id=="save_export":
        save_transfer.export_save(model.snapshot())
    elif id=="save_import":
        save_transfer.import_save()
    elif id=="upgrade":
        if model.try_upgrade():
            audio.play("reward")
            _sync_hero();_persist();hud.notify("Waffe aufgewertet","Level %d · Angriff %d"%[model.upgrade_level+1,model.hero_damage()])
    elif id=="look":
        model.set_look("emerald" if model.profile.look=="canonical" else "canonical")
        _sync_hero();_persist()
    elif id=="aura":
        if model.toggle_aura(): _sync_hero();_persist()
        else: hud.notify("Evolutionsaura","Freischaltung auf Heldenlevel 3")
    else:
        active_tab="Mehr";hud.active_tab=active_tab;stage.visible=false;touch_zone.visible=false
        hud.notify("Noch nicht geöffnet","Dieser Bereich folgt später")
    _refresh()

func _apply_preferences() -> void:
    if audio:audio.enabled=preferences.sound
    if vfx:vfx.intensity=preferences.intensity()
    camera_feedback.intensity=preferences.intensity()
    hud.sound_enabled=preferences.sound;hud.effect_level=preferences.effects
    hud.queue_redraw()

func _on_stage_input(event: InputEvent) -> void:
    var pressed=false
    if event is InputEventScreenTouch: pressed=event.pressed
    elif event is InputEventMouseButton: pressed=event.pressed and event.button_index==MOUSE_BUTTON_LEFT
    if pressed:
        var now=Time.get_ticks_msec()
        if now-_last_stage_tap_ms>80:
            _last_stage_tap_ms=now
            _on_tap()
        touch_zone.accept_event()

func _on_tap() -> bool:
    if active_tab!="Kampf": return false
    var ok=model.request_action("basic")
    _consume_events()
    return ok

func _on_skill(index: int = 0) -> bool:
    if active_tab!="Kampf" or index<0 or index>=4: return false
    var ok=model.request_action(CombatModel.SKILL_IDS[index])
    _consume_events()
    _refresh()
    return ok

func _process(delta: float) -> void:
    if model==null or active_tab!="Kampf": return
    var simulation_delta=camera_feedback.step(delta)
    model.tick(simulation_delta)
    _auto_clock+=simulation_delta
    stage.position=_stage_home+camera_feedback.offset()*stage.scale.x
    if auto_enabled and _auto_clock>=0.72:
        _auto_clock=0
        model.request_action("basic")
    _consume_events()
    if _production_enabled:hero.sync_clock(model.clock)
    vfx.sync(model,hero.position,enemy.position)
    _ui_clock+=delta
    if _ui_clock>=0.1:
        _ui_clock=0
        _refresh()
    _save_clock+=delta
    if _save_clock>=2:
        _save_clock=0
        _persist()

func _consume_events() -> void:
    for e in model.drain_events():
        match e.type:
            "hero_action":
                if _production_enabled:
                    hero.play_action(e.id,float(e.get("windup",0.28)),float(e.get("recovery",0.35)),float(e.get("started_at",model.clock)))
                    vfx.sync(model,hero.position,enemy.position)
                    vfx.action(e,hero._socket if _production_enabled else null)
                    audio.play({"arcane_eye":"arcane","rage_flame":"fire","guardian_wall":"shield"}.get(e.id,"swing"))
                else: hero.play_attack(e.id!="basic")
            "telegraph":
                if model.outcome!="fighting": continue
                if _production_enabled: enemy.play_telegraph(float(e.duration),str(e.pattern))
                _fx("telegraph",enemy.position,float(e.duration))
            "damage":
                enemy.play_hit()
                vfx.impact(str(e.source),bool(e.critical))
                audio.play("fire" if e.source in ["fire","burn"] else "impact")
                if e.source!="burn":camera_feedback.impact(6 if e.critical or e.source in ["sky","fire","counter"] else 1.6,0.055 if e.critical else 0.035)
                _popup(str(e.amount),Vector2(80,-340),Color("#ffb03d") if e.critical else (Color("#ffa44e") if e.source=="burn" else Color("#fff0b8")),"KRIT!" if e.critical else ("BRENNEN" if e.source=="burn" else ("KONTER" if e.source=="counter" else "")))
            "hero_hit":
                if _production_enabled:
                    enemy.play_attack()
                    hero.play_hit(int(e.blocked)>0)
                vfx.emit_effect("shield" if int(e.blocked)>0 else "fire_impact",hero.position+Vector2(25,-130),180,0.35)
                camera_feedback.impact(4 if e.heavy else 2,0.045)
                audio.play("shield" if int(e.blocked)>0 else "impact")
                var message="-%d"%e.amount if int(e.amount)>0 else "BLOCK"
                _popup(message,Vector2(-270,-230),Color("#ff9898") if int(e.amount)>0 else Color("#74dfff"),"-%d Schild"%e.blocked if int(e.blocked)>0 else "")
                hud.hit_flash=0.18 if int(e.amount)>0 else 0.0
            "shield":
                vfx.emit_effect("shield",hero.position+Vector2(25,-140),260,0.45)
            "status":
                vfx.emit_effect("arcane_eye" if e.id=="mark" else "fire_impact",enemy.position+Vector2(-40,-155),170,0.5)
            "heal":
                _popup("+%d"%e.amount,Vector2(-250,-240),Color("#74ffb1"))
            "enemy_defeated":
                enemy.play_death()
                vfx.emit_effect("arcane_seal",enemy.position+Vector2(0,-55),260,0.55,"spawn",8)
                _persist()
            "reward":
                var r=e.reward
                audio.play("reward")
                vfx.emit_effect("reward",enemy.position+Vector2(-15,-70),190,0.65,"spawn",18)
                hud.notify("+%d Gold · +%d XP"%[r.gold,r.xp],r.item.name)
                _popup("+%d G · +%d XP"%[r.gold,r.xp],Vector2(40,-85),Color("#ffd56d"))
            "level_up":
                vfx.emit_effect("reward",hero.position+Vector2(40,-130),300,0.9,"spawn",18)
                hud.notify("Level %d"%e.level,"Wächterwall bereit" if int(e.level)==2 else "Neue Kraft freigeschaltet")
            "spawn":
                _show_encounter()
            "defeat":
                if _production_enabled: hero.play_death()
                _persist()
            "victory":
                _persist()
    _sync_hero()
    if _production_enabled:hero.sync_clock(model.clock)
    if vfx:vfx.sync(model,hero.position,enemy.position)

func _fx(kind: String, at: Vector2, duration: float = 0.48) -> void:
    if kind=="telegraph":
        for child in stage.get_children():
            if child is RACombatFeedback and child.kind=="telegraph": child.queue_free()
    var fx=Feedback.new()
    fx.configure(kind,duration)
    fx.position=at
    fx.z_index=10
    stage.add_child(fx)

func _popup(text: String, at: Vector2, color: Color, caption: String = "") -> void:
    var label=Label.new()
    label.text=(caption+"\n" if caption!="" else "")+text
    label.add_theme_font_override("font",hud.bold)
    label.add_theme_font_size_override("font_size",35 if caption!="" else 30)
    label.add_theme_color_override("font_color",color)
    label.add_theme_color_override("font_outline_color",Color("#081221"))
    label.add_theme_constant_override("outline_size",6)
    label.mouse_filter=Control.MOUSE_FILTER_IGNORE
    label.position=at
    label.size=Vector2(210,80)
    label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    label.z_index=15
    stage.add_child(label)
    var t=create_tween().set_parallel(true)
    t.tween_property(label,"position:y",at.y-55,0.6)
    t.tween_property(label,"modulate:a",0.0,0.3).set_delay(0.4)
    t.finished.connect(label.queue_free)

func _refresh() -> void:
    if hud==null: return
    enemy.set_health(model.enemy_hp,model.enemy_max_hp)
    hud.auto_enabled=auto_enabled
    touch_zone.visible=active_tab=="Kampf" and model.outcome=="fighting"
    hud.update_buttons()
    hud.queue_redraw()

func _persist() -> void:
    if model!=null and not model.read_only:
        if not SaveStore.save_state(model.snapshot()) and not _save_failed:
            _save_failed=true
            if hud: hud.notify("Speichern fehlgeschlagen","Fortschritt bleibt nur in dieser Sitzung",8)

func _notification(what: int) -> void:
    if what==NOTIFICATION_APPLICATION_PAUSED: _persist()

func _exit_tree() -> void:
    _persist()

func _confirm_import(data: Dictionary) -> void:
    _pending_import=data
    var candidate=CombatModel.new(data)
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new()
    dialog.title="Spielstand übernehmen?"
    dialog.dialog_text="Geladen: Level %d · %d Gold.\nDein vorheriger Stand wird vor dem Import gesichert."%[candidate.level,candidate.gold]
    dialog.ok_button_text="Übernehmen"
    dialog.cancel_button_text="Abbrechen"
    dialog.confirmed.connect(func():
        _apply_import()
        dialog.queue_free())
    dialog.canceled.connect(func():
        _pending_import={}
        dialog.queue_free())
    add_child(dialog)
    dialog.popup_centered(Vector2i(580,220))

func _apply_import() -> bool:
    if _pending_import.is_empty(): return false
    var candidate=CombatModel.new(_pending_import)
    _pending_import={}
    if not SaveStore.install_import(candidate.snapshot()):
        hud.notify("Import fehlgeschlagen","Der bisherige Stand bleibt erhalten",8)
        return false
    model=candidate
    hud.model=model
    _last_visual_key=""
    if _production_enabled: hero.revive()
    _show_encounter();_sync_hero()
    if model.outcome=="defeat" and _production_enabled:hero.play_death()
    if model.enemy_hp<=0:enemy.play_death()
    _on_hud_action("Kampf")
    hud.notify("Spielstand übernommen","Level %d · %d Gold"%[model.level,model.gold])
    return true
