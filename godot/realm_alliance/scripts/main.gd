extends Control
const GLUTKERN_BACKDROP=preload("res://assets/world65/glutkern.webp")
const CombatModel = preload("res://scripts/systems/combat_session.gd")
const ManualInput = preload("res://scripts/combat_input_buffer.gd")
var manual_input = ManualInput.new()
const SaveStore = preload("res://scripts/save_store.gd")
const AdminQA=preload("res://scripts/systems/admin_qa.gd")
const SaveTransfer=preload("res://scripts/save_transfer.gd")
var save_transfer
var _pending_import: Dictionary = {}
const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyVisual = preload("res://scripts/enemy_visual.gd")
const StageArt = preload("res://scripts/stage_art.gd")
const CombatLayout = preload("res://scripts/combat_layout.gd")
const EnemyStage735=preload("res://scripts/presentation/enemy_stage735.gd")
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
var world_backdrop: Control
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
var _resetting_guest=false
var _qa_active:bool=false
var _qa_original_model

var initial_creation_enabled=true
var creation_dialog
var realm_online

func _ready() -> void:
    realm_online=preload("res://scripts/online/realm_client708.gd").new();realm_online.name="RealmOnline";add_child(realm_online)
    var saved=SaveStore.load_state()
    model = CombatModel.new(saved)
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
    if get_tree().root.has_meta("realm_guest_reset_just_completed"):
        get_tree().root.remove_meta("realm_guest_reset_just_completed")
        if SaveStore.fresh_profile_ok() and saved.is_empty():
            hud.notify("Gast-Neustart erfolgreich","Nur Starter-Runenpaladin verfügbar · keine Begleiter oder alten Freischaltungen.",7)
        else:
            hud.notify("Neustart prüfen","Spielprofil entspricht nicht dem vorgesehenen Startzustand.",9)
    if model.outcome=="defeat" and _production_enabled: hero.play_death()
    if model.enemy_hp<=0: enemy.play_death()
    if model.load_error != "":
        hud.notify("Spielstand",model.load_error,12)
        if model.read_only: _on_hud_action("Mehr")
    if _production_enabled and not model.pending.is_empty():
        var d:Dictionary=model.pending.definition
        hero.play_action(str(d.get("animation",d.id)),float(d.windup),float(d.recovery),float(model.pending.hit_at)-float(d.windup)-int(model.pending.get("contact",0))*float(d.get("spacing",0)))
        hero.sync_clock(model.clock)
    if model.profile.kills>0 and model.load_error=="":hud.notify("Willkommen zurück",model.Tap.next_goal(model.profile),3)
    if initial_creation_enabled and saved.is_empty() and not model.read_only:call_deferred("_open_character_creation",true)
    if get_tree().root.has_meta("realm_launcher_open_account"):
        var account_requested=bool(get_tree().root.get_meta("realm_launcher_open_account",false))
        get_tree().root.remove_meta("realm_launcher_open_account")
        if account_requested and not saved.is_empty() and not model.read_only:call_deferred("_open_community")
    print("REALM 713: 712 game with launcher")

func _build_arena() -> void:
    var background := ColorRect.new()
    background.color = Color("#0c1324")
    background.set_anchors_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    if _production_enabled:
        var world := preload("res://scripts/presentation/stage_backdrop.gd").new()
        world_backdrop=world
        world.name = "WolkgartenProductionWorld"
        world.texture = load(ProductionArtGate.ROOT + "world/wolkgarten_battle_plate.png")
        world.set_anchors_preset(Control.PRESET_FULL_RECT)
        world.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(world)
    stage = Node2D.new()
    stage.name = "FixedCombatStage"
    add_child(stage)
    # Validated remote PNG is visible in the real production combat scene.
    if _production_enabled:
        var remote_art=preload("res://scripts/launcher/content_cache730.gd").texture("realm_stage_ornament")
        if remote_art!=null:
            var ornament=Sprite2D.new()
            ornament.name="VerifiedRemoteWorldProp730"
            ornament.texture=remote_art
            ornament.position=Vector2(-285,-115)
            ornament.scale=Vector2.ONE*clampf(95.0/maxf(1.0,remote_art.get_height()),0.06,0.55)
            ornament.modulate=Color(0.80,0.97,1.0,0.56)
            ornament.z_index=1
            stage.add_child(ornament)
    if not _production_enabled:
        stage.add_child(StageArt.new())
    if USE_SHARED_ART_PREVIEW and not _production_enabled:
        var stump := Sprite2D.new()
        stump.name = "SharedStyleSceneryPreview"
        # Gameplay decoration from verified runtime PNG pack; bundled art is fallback.
        var live_stump=preload("res://scripts/launcher/content_cache715.gd").texture("realm_stage_ornament")
        stump.texture = live_stump if live_stump!=null else preload("res://assets/preview/bramble/stage/glow_stump.png")
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
    companion_visual=preload("res://scripts/presentation/companion_visual.gd").new();companion_visual.name="ActiveCompanion";companion_visual.position=Vector2(-235,-4);companion_visual.scale=Vector2.ONE*.23;companion_visual.z_index=5;stage.add_child(companion_visual)
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
    manual_input.clear()
    if world_backdrop:
        world_backdrop.texture=load("res://assets/events69/harvest_world.webp") if not model.activity.is_empty() and model.Activities.CATALOG[model.activity.id].has("event") else (GLUTKERN_BACKDROP if model.region=="glutkern" else load(ProductionArtGate.ROOT+"world/wolkgarten_battle_plate.png"))
    if _production_enabled:
        enemy.configure_enemy(model.enemy_definition)
    enemy.show_wave(model.wave)
    _layout()
    if vfx:
        vfx.clear();vfx.sync(model,hero.position,enemy.position)
        vfx.emit_effect("arcane_seal" if model.enemy_definition.kind=="normal" else "reward",enemy.position+Vector2(0,-70),230 if model.enemy_definition.kind=="normal" else 340,0.65,"spawn",7)
    camera_feedback.reset()

var companion_visual
func _sync_hero() -> void:
    var key="%s:%d:%s:%s:%s:%s"%[model.profile.equipped,model.upgrade_level,model.profile.look,str(model.profile.aura),model.hero_id+JSON.stringify(model.profile.hero_equipment),JSON.stringify(model.profile.hero_evolution)]
    key+=str(model.Economy.enchant_bonus(model.profile,model.profile.equipped))+JSON.stringify(model.profile.hero_mastery)+JSON.stringify(model.profile.wardrobe)+JSON.stringify(model.profile.get("character712",{}))
    if key!=_last_visual_key:
        _last_visual_key=key
        hero.equip_weapon(model.weapon_index)
        hero.set_upgrade_tier(model.upgrade_level+int(model.Economy.enchant_bonus(model.profile,model.profile.equipped)/2))
        if _production_enabled:
            hero.set_hero(model.hero_id)
            hero.set_look(model.profile.look,bool(model.profile.aura) and model.level>=3)
            hero.set_gear(model.profile)
            _fit_equipped_wings()
    if _production_enabled:
        var shield=model.hero_status.active.get("shield",{})
        if companion_visual:companion_visual.sync(model.profile,model.clock)
        hero.set_shield(model.hero_status.has("shield",model.clock),clampf(float(shield.get("amount",0))/maxf(1,model.player_max_hp*0.35),0,1))

func _fit_equipped_wings() -> void:
    if not _production_enabled:return
    hero.position.x=-185
    if hero.attachments and hero.attachments.wings.visible:
        # Preserve hero scale; move the presentation anchor enough for large back art.
        hero.position.x+=maxf(0,hero.attachments.wings.scale.x-.70)*405*hero.scale.x

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
    if world_backdrop:world_backdrop.align_ground(_stage_home.y,.73 if not model.activity.is_empty() and model.Activities.CATALOG[model.activity.id].has("event") else .71)
    var zone: Rect2 = metrics["tap_rect"]
    touch_zone.position = zone.position
    touch_zone.size = zone.size
    hud.position = Vector2(metrics["ui_left"], safe_top)
    hud.scale = Vector2.ONE * float(metrics["ui_scale"])
    hud.configure(metrics["logical_height"])
    if _production_enabled:
        var tall=clampf((float(metrics.logical_height)-1280.0)/280.0,0,1)
        hero.scale=Vector2.ONE*lerpf(.66,.71,tall)
        _fit_equipped_wings()
        var kind=str(model.enemy_definition.kind)
        var available=(_stage_home.y-safe_top)/float(metrics.ui_scale)-300.0
        var height=EnemyStage735.target_height(kind,str(model.enemy_definition.visual),available)
        enemy.fit_height(height,230.0 if kind=="boss" else 205.0)

func _on_hud_action(id: String) -> void:
    if is_instance_valid(creation_dialog) and creation_dialog.visible:return
    if id=="character_create":_open_character_creation();return
    if id=="character_activate":
        if model.activate_character():_character_changed()
        return
    if id.begins_with("character_hair:"):
        if not model.read_only and model.Character.set_hair(model.profile,id.trim_prefix("character_hair:")):_character_changed()
        return
    if id.begins_with("character_class:"):
        var selected=id.trim_prefix("character_class:")
        if not model.Character.can_choose(model.profile,selected):return
        var dialog=preload("res://scripts/ui/modal_dialog.gd").new();add_child(dialog);dialog.title="Klasse wählen"
        dialog.dialog_text=model.Character.config().classes[selected].name+" wird die Klasse deiner Figur. Körper, Haare und Charakterlevel bleiben erhalten. Der neue Job startet auf Level 1. Diese erste Klassenwahl ist dauerhaft."
        dialog.get_ok_button().text="Klasse bestätigen"
        dialog.confirmed.connect(func():if model.choose_class(selected):_character_changed())
        dialog.popup_centered(Vector2i(620,520));return
    if id.begins_with("bestiary_claim:"):
        if not model.read_only and model.Bestiary.claim(model.profile,id.trim_prefix("bestiary_claim:")):
            _persist();_refresh();hud.notify("Meisterschaft belohnt","Gold und Himmelssplitter erhalten",2)
        return
    if id in ["more_heroes","more_pets","more_talents"]:
        _on_hud_action("Wesen")
        hud.collection_page.category="Begleiter" if id=="more_pets" else "Helden";hud.collection_page.detail="";hud.collection_page._reload()
        if id=="more_talents":_open_talents()
        return
    if id=="more_forge":_open_rpg_hub(1);return
    if id=="community":_open_community();return
    if id=="guest_reset":_ask_guest_reset();return
    if id=="equipment":_open_gear_slot("weapon");return
    if id.begins_with("develop:"):_open_evolution(id.split(":",true,1)[1]);return
    if id.begins_with("hero_") and ":" in id or id.begins_with("pet_") and ":" in id:
        var pair=id.split(":",true,1);var ok=false
        match pair[0]:
            "hero_select":ok=model.select_hero(pair[1])
            "hero_unlock":ok=model.unlock_hero(pair[1])
            "pet_select":ok=model.select_companion(pair[1])
            "pet_unlock":ok=model.acquire_companion(pair[1])
            "pet_evolve":ok=model.evolve_companion(pair[1])
        if ok:
            manual_input.clear();_last_visual_key=""
            if vfx:vfx.clear()
            if _production_enabled:hero.revive()
            _sync_hero();_persist();_refresh();hud.notify("Besetzung aktualisiert","Stage und Gegner-HP bleiben erhalten",2)
        return
    if id in ["economy","activities","journey"]:
        _open_rpg_hub({"economy":0,"activities":2,"journey":3}[id]);return
    if id=="admin":
        _open_admin_qa()
        return
    if _qa_active and id in ["save_export","save_import"]:
        hud.notify("QA-Schutz","Import und Export sind im Testmodus gesperrt",3)
        return
    if id=="roster":
        if active_tab!="Wesen":return
        var dialog=preload("res://scripts/ui/roster_dialog.gd").new();add_child(dialog);dialog.configure(model)
        dialog.progression_changed.connect(func(message):_sync_hero();_persist();_refresh();audio.play("reward");hud.notify(message,"Helden & Begleiter"))
        dialog.selection_changed.connect(func():
            manual_input.clear()
            # Visual handoff only: never respawn the enemy or reset the dungeon.
            if vfx:vfx.clear()
            _last_visual_key=""
            if _production_enabled:hero.revive()
            _sync_hero()
            _persist()
            _refresh()
            hud.notify("Besetzung gewechselt","Gleiche Stage · gleicher Kampf",2))
        dialog.popup_centered_clamped(Vector2i(680,mini(1350,int(get_viewport_rect().size.y)-130)))
    elif id=="hit_mode":
        var modes=[1,2,4];var current=model.Tap.mode(model.profile);var next=current
        for offset in range(1,4):
            var candidate=modes[(modes.find(current)+offset)%3]
            if model.Tap.unlocked(model.profile,candidate):next=candidate;break
        if model.select_hit_mode(next):_persist();hud.notify("Angriffsfolge x%d"%next,"x2: Lv.3 + Elite · x4: Lv.6 + Gartenkoloss")
    elif id=="ultimate":
        if active_tab=="Kampf":
            var accepted=manual_input.request_ultimate(model)
            if accepted==ManualInput.QUEUED:hud.notify("Sternenfall vorgemerkt","Startet nach dem laufenden Schlag",.8)
            _consume_events();_refresh()
    elif id=="combat_options":
        var dialog=preload("res://scripts/ui/combat_options_dialog.gd").new();add_child(dialog);dialog.configure(model);dialog.policy_changed.connect(func():_persist();_refresh());dialog.popup_centered(Vector2i(620,760))
    elif id=="sound":
        preferences.sound=not preferences.sound;preferences.save_settings();_apply_preferences()
    elif id=="effects":
        preferences.effects=(preferences.effects+1)%3;preferences.save_settings();_apply_preferences()
    elif id=="settings":
        _on_hud_action("Mehr")
    elif id in ["Kampf","Abenteuer","Wesen","Beute","Mehr","return"]:
        manual_input.clear()
        active_tab="Kampf" if id=="return" else id
        hud.active_tab=active_tab
        stage.visible=active_tab=="Kampf"
        stage.process_mode=Node.PROCESS_MODE_INHERIT if active_tab=="Kampf" else Node.PROCESS_MODE_DISABLED
        touch_zone.visible=active_tab=="Kampf" and model.outcome=="fighting"
    elif id.begins_with("stage:"):
        _confirm_stage(id)
    elif id.begins_with("item:"):
        _open_inventory_item(id)
    elif id in ["quests","events","mail"]:
        _open_quests(id=="events")
    elif id=="talents":
        _open_talents()
    elif id=="auto":
        auto_enabled=not auto_enabled
    elif id.begins_with("skill"):
        _on_skill(int(id.trim_prefix("skill")))
    elif id=="locked":
        if not _on_skill(3): hud.notify("Wächterwall","Ab Heldenlevel 2 · 20 Momentum")
    elif id=="adopt_starter":
        var dialog=preload("res://scripts/ui/modal_dialog.gd").new();add_child(dialog)
        dialog.title="Runenpaladin übernehmen?";dialog.dialog_text="Der Runenpaladin wird kostenfrei freigeschaltet und aktiviert. Die XP deines bisherigen Starthelden werden übernommen. Alle bisherigen Helden, Aufstiegsränge und Gegenstände bleiben erhalten.";dialog.ok_button_text="Übernehmen";dialog.cancel_button_text="Zurück"
        dialog.confirmed.connect(func():
            if model.adopt_starter():_sync_hero();_persist();_refresh();hud.notify("Runenpaladin bereit","Bisheriger Fortschritt bleibt erhalten")
            dialog.queue_free())
        dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(650,500))
    elif id=="restart":
        if model.continue_after_victory():
            if _production_enabled: hero.revive()
            _consume_events()
            _persist()
    elif id=="weapon":
        model.cycle_weapon();_sync_hero();_persist()
    elif id.begins_with("gear_"):
        _open_gear_slot(str(model.HeroEquipment.CATALOG[id.trim_prefix("gear_")].slot))
    elif id.begins_with("equipment:"):
        _open_gear_slot(id.trim_prefix("equipment:"))
    elif id=="evolve":
        _open_evolution()
    elif id.begins_with("hero_skill_"):
        _open_skill_info(int(id.trim_prefix("hero_skill_")))
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
        var looks=["canonical","emerald","astral"]
        model.set_look(looks[(looks.find(model.profile.look)+1)%looks.size()])
        _sync_hero();_persist()
    elif id=="aura":
        if model.toggle_aura(): _sync_hero();_persist()
        else: hud.notify("Evolutionsaura","Freischaltung auf Heldenlevel 3")
    else:
        active_tab="Mehr";hud.active_tab=active_tab;stage.visible=false;touch_zone.visible=false
        hud.notify("Noch nicht geöffnet","Dieser Bereich folgt später")
    _refresh()

func _open_admin_qa() -> void:
    if not AdminQA.enabled() or active_tab!="Mehr" or model.read_only:
        return
    if not _qa_active:
        # Commit the original session first, then work on a *different* in-memory session.
        if not SaveStore.save_state(model.snapshot()):
            hud.notify("QA nicht gestartet","Normalen Spielstand zuerst sichern",6)
            return
        _qa_original_model=model
        model=CombatModel.new(_qa_original_model.snapshot())
        if model.read_only:
            model=_qa_original_model
            _qa_original_model=null
            hud.notify("QA nicht gestartet","Spielstand konnte nicht kopiert werden",6)
            return
        _qa_active=true
        hud.model=model
        hud.qa_mode=true
        manual_input.clear()
        _last_visual_key=""
        _show_encounter()
        _sync_hero()
        _refresh()
    var dialog=preload("res://scripts/ui/admin_qa_dialog.gd").new()
    add_child(dialog)
    dialog.configure(model)
    dialog.operation_requested.connect(func(kind:String):
        if kind=="leave":
            _leave_admin_qa()
            dialog.queue_free()
            return
        if AdminQA.apply(model,kind):
            manual_input.clear()
            hero.revive()
            _last_visual_key=""
            _show_encounter()
            _sync_hero()
            _refresh()
            dialog.refresh(model)
            hud.notify("QA-Testaktion",kind+" · wird nicht gespeichert",3)
        else:
            hud.notify("QA-Testaktion","Nicht möglich oder bereits erledigt",3))
    dialog.popup_centered_clamped(Vector2i(680,mini(1350,int(get_viewport_rect().size.y)-130)))

func _leave_admin_qa() -> void:
    if not _qa_active:return
    model=_qa_original_model
    _qa_original_model=null
    _qa_active=false
    hud.model=model
    hud.qa_mode=false
    manual_input.clear()
    _last_visual_key=""
    if _production_enabled:hero.revive()
    _show_encounter()
    _sync_hero()
    _refresh()
    hud.notify("QA verlassen","Dein normaler Spielstand ist wieder aktiv",5)

func _open_gear_slot(slot:String) -> void:
    if active_tab not in ["Wesen","Beute"]:return
    var dialog=preload("res://scripts/ui/equipment_page.gd").new();add_child(dialog);dialog.configure(model,slot)
    dialog.changed.connect(func(message):_sync_hero();_persist();_refresh();hud.notify(message,"Ausrüstung",2))
    dialog.popup_centered(Vector2i(696,1000))

func _open_gear(id: String) -> void:
    if active_tab not in ["Wesen","Beute"] or not model.HeroEquipment.CATALOG.has(id):return
    if model.read_only:
        hud.notify("Ausrüstung gesperrt","Spielstand bleibt unverändert.");return
    var dialog=preload("res://scripts/ui/hero_equipment_dialog.gd").new()
    add_child(dialog);dialog.configure(model,id)
    dialog.operation.connect(func(item,kind):
        var accepted=model.economy_command(kind.split("|")[0],item,kind.split("|")[1]) if "|" in kind else model.change_gear(item,kind)
        if accepted:
            if kind=="acquire":model.change_gear(item)
            _sync_hero();_persist();_refresh()
            hud.notify("Ausrüstung aktualisiert","HP %d · Verteidigung %d"%[model.player_max_hp,model.defense]))
    dialog.popup_centered(Vector2i(mini(600,int(get_viewport_rect().size.x)-24),380))

func _ask_guest_reset() -> void:
    if _resetting_guest or _qa_active:return
    if active_tab!="Mehr":return
    if realm_online!=null and (not realm_online.token.is_empty() or realm_online.connected):
        hud.notify("Gast-Reset gesperrt","Bitte zuerst in Gemeinschaft vom Online-Konto abmelden.",6)
        return
    var warning=preload("res://scripts/ui/modal_dialog.gd").new()
    add_child(warning)
    warning.title="Gast-Spielstand zurücksetzen?"
    warning.dialog_text="Deine lokalen Gast-Heldenfreischaltungen, Charaktere, Begleiter, Flügel, Waffen-Upgrades, Währungen und Erfolge werden entfernt.\n\nDanach beginnt ein neues Spiel mit dem STARTHELDEN RUNENPALADIN. Andere Helden und Pets bleiben nur als gesperrte Katalogeinträge sichtbar.\n\nNicht rückgängig zu machen. Cloud-Konten bleiben unberührt. Exportiere deinen Stand vorher unter Mehr, wenn du ihn behalten möchtest."
    warning.ok_button_text="Endgültig zurücksetzen"
    warning.cancel_button_text="Abbrechen"
    warning.confirmed.connect(func():warning.queue_free();_reset_guest_now())
    warning.canceled.connect(warning.queue_free)
    warning.popup_centered(Vector2i(660,600))

func _reset_guest_now() -> void:
    if _resetting_guest or _qa_active:return
    if realm_online!=null and (not realm_online.token.is_empty() or realm_online.connected):return
    _resetting_guest=true
    if not SaveStore.reset_guest() or not SaveStore.fresh_profile_ok():
        _resetting_guest=false
        hud.notify("Zurücksetzen fehlgeschlagen","Lokale Daten konnten nicht vollständig bereinigt werden.",8)
        return
    # Never call _persist() on the old model while the scene is shutting down.
    get_tree().root.set_meta("realm_guest_reset_just_completed",true)
    get_tree().call_deferred("change_scene_to_file","res://scenes/main.tscn")

func _open_community() -> void:
    if active_tab!="Mehr":return
    var dialog=preload("res://scripts/ui/community708.gd").new();add_child(dialog);dialog.configure(model,realm_online)
    dialog.local_changed.connect(func():_persist();_refresh())
    dialog.restore_requested.connect(func(data):
        _pending_import=data;_apply_import();dialog.queue_free()
    )
    dialog.popup_centered(Vector2i(696,1000))

func _open_evolution(hero_id:String="") -> void:
    if (hero_id=="" and model.Character.active(model.profile)) or hero_id.begins_with("adventurer_"):
        _on_hud_action("Wesen");hud.collection_page.category="Charakter";hud.collection_page.detail="";hud.collection_page._reload();return
    if active_tab!="Wesen":return
    var dialog=preload("res://scripts/ui/hero_development708.gd").new();add_child(dialog)
    dialog.configure(model,hero_id)
    dialog.changed.connect(func(message):_sync_hero();_consume_events();_persist();_refresh();audio.play("reward");hud.notify(message,"Heldenentwicklung",2))
    dialog.popup_centered(Vector2i(696,1000))

func _open_skill_info(index: int) -> void:
    if active_tab!="Wesen" or index not in range(4):return
    var d:Dictionary=model.skills.definitions[model.SKILL_IDS[index]]
    var detail=""
    match d.effect:
        "direct":detail="Konzentrierter Schwertschlag: %.1f× Angriff."%d.multiplier
        "mark":detail="Markierung: %.1f s lang +%d%% Trefferschaden."%[d.duration,roundi((float(d.amplify)-1)*100)]
        "burn":detail="Feuerschlag: %.1f× Angriff · %.1f s Brennen."%[d.multiplier,d.duration]
        "shield":detail="Schild: %d%% maximale HP · erster Block kontert."%roundi(float(d.absorb_fraction)*100)
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new()
    var cost_text="Kostenfrei" if d.cost_type=="none" else "Kosten: %d %s"%[d.cost,{"momentum":"Momentum","rage":"Zorn"}[d.cost_type]]
    dialog.title=d.name;dialog.dialog_text="%s\n\nAb Heldenlevel %d · %.1f s Abklingzeit\n%s\nAUTO-Skills optional unter Mehr."%[detail,d.unlock_level,d.cooldown,cost_text]
    var skill_id:String=model.SKILL_IDS[index]
    var rank=model.Advancement.rank(model.profile,skill_id)
    var upgrade=model.Advancement.cost(model.profile,skill_id)
    dialog.dialog_text+="\n\nSkillstufe %d/5 · Aufwertung: %d Gold +2 Splitter\nAb Heldenlevel %d · Wirkung steigt, Kosten/CD bleiben."%[rank,upgrade.gold,upgrade.level]
    var improve=dialog.add_button("Skill +1",true,"upgrade");improve.custom_minimum_size.y=100;improve.disabled=model.read_only or not model.Advancement.can_upgrade(model.profile,skill_id)
    dialog.custom_action.connect(func(action):
        if action=="upgrade":
            if model.upgrade_skill(skill_id):_persist();_refresh();hud.notify("Skill aufgewertet",d.name)
            dialog.queue_free())
    dialog.ok_button_text="Schließen";dialog.cancel_button_text="Zurück"
    dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free)
    add_child(dialog)
    dialog.game_page=true
    var skills=HBoxContainer.new();skills.add_theme_constant_override("separation",8);dialog.add_child(skills)
    for i in 4:
        var selector=Button.new();selector.text=["Schlag","Zeichen","Flamme","Schutz"][i];selector.tooltip_text=model.skills.definitions[model.SKILL_IDS[i]].name;selector.custom_minimum_size=Vector2(0,100);selector.size_flags_horizontal=Control.SIZE_EXPAND_FILL;selector.add_theme_font_size_override("font_size",22);skills.add_child(selector)
        if i==index:selector.add_theme_stylebox_override("normal",preload("res://scripts/ui/fantasy_theme.gd").box("primary"))
        selector.pressed.connect(func():dialog.queue_free();_open_skill_info(i))
    var card=preload("res://scripts/ui/progress_card.gd").new()
    card.configure(d.name,dialog.dialog_text,"res://assets/ui/work61/"+["skill_slash.png","skill_eye.png","skill_rage.png","skill_locked.png"][index],rank,5);dialog.add_child(card);dialog.dialog_text=""
    improve.reparent(card.body)
    var others=VBoxContainer.new();others.add_theme_constant_override("separation",16);dialog.add_child(others)
    for i in 4:
        if i==index:continue
        var definition=model.skills.definitions[model.SKILL_IDS[i]];var other_rank=model.Advancement.rank(model.profile,model.SKILL_IDS[i])
        var other=preload("res://scripts/ui/progress_card.gd").new()
        var info="%.1f s Abklingzeit · ab Heldenlevel %d"%[definition.cooldown,definition.unlock_level]
        other.configure(definition.name,info,"res://assets/ui/work61/"+["skill_slash.png","skill_eye.png","skill_rage.png","skill_locked.png"][i],other_rank,5);others.add_child(other)
        var open=Button.new();open.text="Details & Aufwertung";open.custom_minimum_size.y=100;other.body.add_child(open);open.pressed.connect(func():dialog.queue_free();_open_skill_info(i))
    dialog._prepare_body()
    dialog.popup_centered(Vector2i(680,900))

func _confirm_stage(id: String) -> void:
    var parts=id.split(":")
    if parts.size()!=3:return
    var region_id=parts[1];var index=int(parts[2])
    if not model.World.can_enter(model.profile,region_id,index):return
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new()
    dialog.title="Stage betreten";dialog.dialog_text="%s · %d-%d\nDer aktuelle Lauf wird beendet. Ausrüstung und Fortschritt bleiben erhalten.\nEin neuer Lauf beginnt mit vollen HP."%[model.World.NAMES[region_id],model.World.IDS.find(region_id)+1,index+1];dialog.ok_button_text="Betreten";dialog.cancel_button_text="Zurück"
    dialog.confirmed.connect(func():
        if model.start_stage(region_id,index):
            hero.revive();_consume_events();_persist();_on_hud_action("Kampf");hud.notify(model.World.NAMES[region_id],model.enemy_definition.name,2)
        dialog.queue_free())
    dialog.canceled.connect(dialog.queue_free);add_child(dialog);dialog.popup_centered(Vector2i(620,350))

func _open_inventory_item(id: String) -> void:
    var parts=id.split(":")
    if parts.size()!=3:return
    var kind=parts[1];var item=parts[2]
    if kind=="gear":_open_gear(item);return
    if kind=="weapon" and model.profile.inventory.has(item):
        var dialog=preload("res://scripts/ui/weapon_dialog.gd").new();add_child(dialog);dialog.configure(model,item)
        dialog.operation.connect(func(weapon,operation):
            var ok=model.upgrade_weapon(weapon) if operation=="upgrade" else (model.economy_command(operation.split("|")[0],weapon,operation.split("|")[1]) if "|" in operation else (not model.read_only and model.equip(weapon)))
            if ok:_sync_hero();_persist();_refresh();hud.notify("Ausrüstung aktualisiert",model.Equipment.definition(weapon).name))
        dialog.popup_centered(Vector2i(620,380));return
    var info=preload("res://scripts/ui/modal_dialog.gd").new();add_child(info)
    info.title="Wächtertruhe" if kind=="chest" else model.Economy.MATERIALS.get(item,{"name":"Himmelssplitter"}).name
    info.dialog_text="Eine echte Bossbelohnung. Enthält Gold, Splitter und ein Ausrüstungsteil; ein Duplikat ergibt zusätzliche Splitter." if kind=="chest" else "Aufwertungsmaterial aus Kämpfen, Aufgaben und Truhen. Bestand: %d"%model.profile.shards
    if model.Economy.MATERIALS.has(item):info.dialog_text="%s · Bestand: %d\nFür garantierte Rezepte in Shop & Schmiede."%[model.Economy.MATERIALS[item].name,model.profile.economy.materials[item]]
    info.ok_button_text="Öffnen" if kind=="chest" else "Schließen";info.cancel_button_text="Zurück";info.get_ok_button().disabled=model.read_only and kind=="chest"
    info.confirmed.connect(func():
        if kind=="chest":
            var reward=model.open_chest()
            if not reward.is_empty():
                _persist();_refresh();audio.play("reward");hud.notify("Truhe geöffnet",reward.item.name,3)
                var reveal=preload("res://scripts/ui/reward_dialog.gd").new();add_child(reveal);reveal.configure(reward,[1.0,.4,0.0][preferences.effects]);reveal.popup_centered(Vector2i(620,460))
        info.queue_free())
    info.canceled.connect(info.queue_free);info.popup_centered(Vector2i(620,360))

func _open_quests(achievements: bool) -> void:
    if not model.Quests.ensure(model.profile):hud.notify("Daten geschützt","Aufgaben sind nicht kompatibel.");return
    var dialog=preload("res://scripts/ui/quest_dialog.gd").new();add_child(dialog);dialog.configure(model,achievements)
    dialog.claim_requested.connect(func(id):
        if model.claim_quest(id):_persist();_refresh();audio.play("reward");hud.notify("Belohnung erhalten",model.Quests.definition(id).name))
    dialog.popup_centered(Vector2i(620,650))

func _open_talents() -> void:
    var dialog=preload("res://scripts/ui/talent_dialog.gd").new();add_child(dialog);dialog.configure(model)
    dialog.train_requested.connect(func(id):
        if model.train_talent(id):_sync_hero();_persist();_refresh();hud.notify("Talent gelernt","Stärke" if id=="might" else "Vitalität"))
    dialog.popup_centered(Vector2i(620,500))

func _apply_preferences() -> void:
    get_tree().root.set_meta("realm_effect_level",preferences.effects)
    if audio:audio.enabled=preferences.sound
    if vfx:vfx.intensity=[1.0,.4,0.0][preferences.effects]
    if _production_enabled and hero.aura:
        hero.aura.fx_intensity=[1.0,.4,0.0][preferences.effects]
        hero.fx_intensity=[1.0,.4,0.0][preferences.effects];hero.set_upgrade_tier(model.upgrade_level+int(model.Economy.enchant_bonus(model.profile,model.profile.equipped)/2))
    camera_feedback.intensity=[1.0,.4,0.0][preferences.effects]
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
    if active_tab!="Kampf" or is_instance_valid(creation_dialog) and creation_dialog.visible: return false
    var result=manual_input.request_tap(model)
    _consume_events()
    return result!=ManualInput.REJECTED

func _on_skill(index: int = 0) -> bool:
    if is_instance_valid(creation_dialog) and creation_dialog.visible:return false
    if active_tab!="Kampf" or index<0 or index>=4: return false
    var result=manual_input.request(model,index)
    if result==ManualInput.QUEUED:
        hud.notify("Skill vorgemerkt",str(model.skills.definitions[CombatModel.SKILL_IDS[index]].name),0.8)
    _consume_events()
    _refresh()
    return result!=ManualInput.REJECTED

func _process(delta: float) -> void:
    if model==null or active_tab!="Kampf" or is_instance_valid(creation_dialog) and creation_dialog.visible: return
    camera_feedback.step(delta)
    model.tick(delta)
    manual_input.drain(model)
    _auto_clock+=delta
    stage.position=_stage_home+camera_feedback.offset()*stage.scale.x
    if auto_enabled and manual_input.is_empty() and model.clock>=model.busy_until:
        if model.request_auto_skill():_auto_clock=0
        elif _auto_clock>=.92 and model.request_basic("auto"):_auto_clock=0
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
    var consumed_events=model.drain_events()
    var completed=model.outcome=="victory"
    if completed:
        var banner=hud.get_node_or_null("ProgressCelebration")
        if banner:banner.queue_free()
        hud.toast_until=0
    for e in consumed_events:
        match e.type:
            "companion_action":
                if companion_visual:companion_visual.sync(model.profile,model.clock);companion_visual.cast(float(e.windup))
                var from=companion_visual.position+Vector2(0,-55)
                var to=enemy.position+Vector2(0,-150) if e.id!="sunbird" else hero.position+Vector2(0,-120)
                var effect=vfx.emit_effect("arcane_eye" if e.id!="sunbird" else "shield",from,80,float(e.windup),"projectile",15)
                if effect:effect.origin=from;effect.target=to;effect.model_deadline=model.clock+float(e.windup)
            "companion_impact":
                vfx.emit_effect("arcane_eye" if e.id!="sunbird" else "shield",enemy.position+Vector2(0,-150) if e.id!="sunbird" else hero.position+Vector2(0,-120),130,.3)
            "hero_level_up", "pet_level_up":
                if completed:continue
                hud.notify((str(model.Roster.catalog().get(e.id,{"name":model.hero_name}).name) if e.type=="hero_level_up" else str(model.Companions.catalog()[e.id].name))+" · Level %d"%e.level,"Durch XP gewachsen")
                _celebrate((str(model.Roster.catalog().get(e.id,{"name":model.hero_name}).name) if e.type=="hero_level_up" else str(model.Companions.catalog()[e.id].name))+" · Lv. %d"%e.level,"Dein Begleiter wächst" if e.type=="pet_level_up" else "Dein Held wird stärker")
                vfx.emit_effect("reward",hero.position+Vector2(0,-110),180,.55,"spawn",18)
            "combat_unlock":
                if completed:continue
                hud.notify("NEU: "+("Sternenfall" if e.id=="ultimate" else e.id+" Treffer"),"Dein Fortschritt hat eine neue Angriffskraft freigeschaltet",4)
                audio.play("reward");vfx.emit_effect("reward",hero.position+Vector2(30,-150),220,.7,"spawn",18)
            "activity_complete":
                hud.notify("Aktivität geschafft", "%s · %d Gold · Truhe in Beute"%[model.Activities.CATALOG[e.reward.id].name,e.reward.gold],4)
                audio.play("reward")
            "stage_clear":
                if completed:continue
                hud.notify("Stage geschafft", "%s · %s"%[model.World.NAMES[e.region],"★".repeat(int(e.stars))],1.2)
            "hero_action":
                if _production_enabled:
                    hero.play_action(str(e.get("animation",e.id)),float(e.get("windup",0.28)),float(e.get("recovery",0.35)),float(e.get("started_at",model.clock)))
                    vfx.sync(model,hero.position,enemy.position)
                    vfx.action(e,hero._socket if _production_enabled else null)
                    audio.play({"arcane_eye":"arcane","rage_flame":"fire","guardian_wall":"shield"}.get(e.id,"swing"))
                else: hero.play_attack(e.id!="basic")
            "chain_contact":
                vfx.chain_contact(int(e.step),int(e.index),int(e.contacts),bool(e.critical))
                if int(e.index)==0 and (int(e.step)==2 or bool(e.critical)):camera_feedback.impact(3,.035)
            "boss_phase":
                if e.id=="break":
                    if _production_enabled:enemy.interrupt_telegraph()
                    vfx.cancel_enemy_warnings()
                    for child in stage.get_children():
                        if child is RACombatFeedback and child.kind=="telegraph":child.queue_free()
                if _production_enabled:enemy.play_hit()
                hud.notify("RÜSTUNGSBRUCH" if e.id=="break" else "BOSS: RASEREI","1,6 s · +25% Schaden" if e.id=="break" else "+20% Angriff · Telegraphe beachten",1.6)
                vfx.emit_effect("sky_impact" if e.id=="break" else "fire_impact",enemy.position+Vector2(-40,-190),260,.5)
                if e.id=="break":camera_feedback.impact(5,.06)
            "telegraph":
                if model.outcome!="fighting": continue
                if _production_enabled: enemy.play_telegraph(float(e.duration),str(e.pattern))
                _fx("telegraph",enemy.position,float(e.duration))
                vfx.enemy_warning(model,str(e.pattern),float(e.duration),hero.position+Vector2(0,-4))
            "damage":
                enemy.play_hit()
                if not bool(e.get("subhit",false)) and e.source!="pet":vfx.impact(str(e.source),bool(e.critical),int(e.get("skill_rank",1)))
                audio.play("fire" if e.source in ["fire","burn"] else "impact")
                if e.source not in ["burn","chain","pet"]:camera_feedback.impact(6 if e.critical or e.source in ["sky","fire","counter"] else 1.6,0.055 if e.critical else 0.035)
                _damage_popup(e)
            "hero_hit":
                if _production_enabled:
                    enemy.play_attack()
                    hero.play_hit(int(e.blocked)>0)
                vfx.emit_effect("shield" if int(e.blocked)>0 else "fire_impact",hero.position+Vector2(25,-130),180,0.35)
                camera_feedback.impact(4 if e.heavy else 2,0.045)
                if model.enemy_definition.pattern=="eruption":vfx.emit_effect("fire_impact",hero.position+Vector2(0,-55),220 if e.heavy else 150,.42,"impact",16)
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
                if completed:continue
                var r=e.reward
                if companion_visual:companion_visual.reward()
                audio.play("reward")
                vfx.emit_effect("reward",enemy.position+Vector2(-15,-70),190,0.65,"spawn",18)
                hud.notify("+%d Gold · +%d XP"%[r.gold,r.xp],r.item.name)
                _popup("+%d G · +%d XP"%[r.gold,r.xp],Vector2(40,-85),Color("#ffd56d"))
            "level_up":
                if completed:continue
                _celebrate("Level %d"%e.level,"Neue Kraft für dein Abenteuer")
                vfx.emit_effect("reward",hero.position+Vector2(40,-130),300,0.9,"spawn",18)
                hud.notify("Level %d"%e.level,"Wächterwall bereit" if int(e.level)==2 else "Neue Kraft freigeschaltet")
            "spawn":
                _show_encounter()
            "defeat":
                if _production_enabled: hero.play_death()
                _persist()
            "victory":
                hud.toast_until=0
                _persist()
    var unlock_labels=[]
    for event in consumed_events:
        if event.type=="combat_unlock":unlock_labels.append("Sternenfall" if event.id=="ultimate" else event.id+" Treffer")
    if not completed and not unlock_labels.is_empty():hud.notify("Freigeschaltet: "+" · ".join(unlock_labels),model.Tap.next_goal(model.profile),5)
    _sync_hero()
    if not consumed_events.is_empty():hud.queue_redraw()
    if _production_enabled:hero.sync_clock(model.clock)
    if vfx:vfx.sync(model,hero.position,enemy.position)

func _celebrate(title:String,detail:String) -> void:
    if active_tab!="Kampf":return
    var old=hud.get_node_or_null("ProgressCelebration")
    if old:old.queue_free()
    var banner=preload("res://scripts/ui/progress_celebration708.gd").new();banner.name="ProgressCelebration";hud.add_child(banner);banner.configure(title,detail,"res://assets/work708/ui/title_crest.tres",[1.0,.4,0.0][preferences.effects])

func _fx(kind: String, at: Vector2, duration: float = 0.48) -> void:
    if kind=="telegraph":
        for child in stage.get_children():
            if child is RACombatFeedback and child.kind=="telegraph": child.queue_free()
    var fx=Feedback.new()
    fx.configure(kind,duration)
    fx.position=at
    fx.z_index=10
    stage.add_child(fx)

func _damage_popup(event:Dictionary) -> void:
    var key=str(event.get("action_id","")) if bool(event.get("subhit",false)) else ""
    if key!="":
        for child in stage.get_children():
            if not child is Label or child.is_queued_for_deletion() or str(child.get_meta("damage_action",""))!=key:continue
            var amount=int(child.get_meta("damage_total",0))+int(event.amount)
            var hits=int(child.get_meta("damage_hits",1))+1
            child.set_meta("damage_total",amount);child.set_meta("damage_hits",hits)
            child.text=("%d × KRIT!" if bool(event.critical) else "%d TREFFER")%hits+"\n"+str(amount)
            return
    var caption="KRIT!" if event.critical else ("BRENNEN" if event.source=="burn" else ("KONTER" if event.source=="counter" else ""))
    var label=_popup(str(event.amount),Vector2(70+(model.tap.combo%3)*34,-300-(model.tap.combo%3)*38),Color("#ffb03d") if event.critical else (Color("#ffa44e") if event.source=="burn" else Color("#fff0b8")),caption)
    if key!="":
        label.set_meta("damage_action",key);label.set_meta("damage_total",int(event.amount));label.set_meta("damage_hits",1)
        label.add_theme_font_size_override("font_size",35)

func _popup(text: String, at: Vector2, color: Color, caption: String = "") -> Label:
    var existing=[]
    for child in stage.get_children():
        if child is Label and not child.is_queued_for_deletion():existing.append(child)
    if existing.size()>=10:existing[0].queue_free()
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
    return label

func _refresh() -> void:
    if hud==null: return
    hud.qa_mode=_qa_active
    enemy.set_health(model.enemy_hp,model.enemy_max_hp)
    hud.auto_enabled=auto_enabled
    touch_zone.visible=active_tab=="Kampf" and model.outcome=="fighting"
    hud.update_buttons()
    hud.queue_redraw()

func _persist() -> void:
    # Never write the in-memory QA sandbox to the player's real save or Web journal.
    if _qa_active or _resetting_guest:return
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
    if _qa_active:return false
    if _pending_import.is_empty(): return false
    var candidate=CombatModel.new(_pending_import)
    _pending_import={}
    if candidate.read_only or not SaveStore.install_import(candidate.snapshot()):
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

func _open_rpg_hub(index:int=0) -> void:
    var dialog=preload("res://scripts/ui/rpg_hub.gd").new();add_child(dialog);dialog.configure(model,index)
    dialog.changed.connect(func(message):_last_visual_key="";_sync_hero();_persist();_refresh();audio.play("reward");hud.notify(message,"Fortschritt gespeichert"))
    dialog.hero_development_requested.connect(func():dialog.queue_free();_on_hud_action("Wesen");_open_evolution())
    dialog.activity_requested.connect(func(id):
        if model.start_activity(id):
            hero.revive();_consume_events();_persist();_on_hud_action("Kampf");_refresh())
    dialog.leave_requested.connect(func():
        var state=model.leave_activity()
        if not state.is_empty():
            model=CombatModel.new(state);hud.model=model;hero.revive();_last_visual_key="";_show_encounter();_sync_hero();_persist();_on_hud_action("Kampf");_refresh())
    dialog.popup_centered_clamped(Vector2i(680,mini(1350,int(get_viewport_rect().size.y)-130)))

func _open_character_creation(required:bool=false) -> void:
    if model.read_only or model.Character.exists(model.profile):return
    if is_instance_valid(creation_dialog):creation_dialog.queue_free()
    manual_input.clear()
    creation_dialog=preload("res://scripts/ui/character_creation712.gd").new();add_child(creation_dialog);creation_dialog.configure(model,required)
    creation_dialog.created.connect(func(body,hair):
        if model.create_character(body,hair):
            creation_dialog.hide();_character_changed();_on_hud_action("Wesen")
            hud.collection_page.category="Charakter";hud.collection_page.detail="";hud.collection_page._reload())
    creation_dialog.popup_centered(Vector2i(680,1000))
func _character_changed() -> void:
    manual_input.clear();_last_visual_key=""
    if vfx:vfx.clear()
    if _production_enabled:hero.revive()
    _sync_hero();_persist();_refresh()
