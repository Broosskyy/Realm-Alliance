extends SceneTree

const Main = preload("res://scripts/main.gd")
const Layout = preload("res://scripts/combat_layout.gd")
var failures = 0
var checks = 0

func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene = load("res://scenes/main.tscn").instantiate()
    root.add_child(scene)
    scene.auto_enabled = false
    scene.model = scene.CombatModel.new()
    scene.hud.model = scene.model
    scene._refresh()
    var hud = scene.hud
    check(scene._production_enabled, "Canonical pack is required for UI acceptance")
    check(scene.hero.weapon_is_modular(), "Hero retains separate weapon socket")
    check(not scene.enemy.show_local_health, "Central enemy HUD replaces the local debug bar")
    for tab in ["Abenteuer", "Wesen", "Beute", "Mehr", "Kampf"]:
        hud.buttons[tab].pressed.emit()
        check(scene.active_tab == tab, "Navigation opens " + tab)
        check(scene.touch_zone.visible == (tab == "Kampf"), "Shell consumes arena input")
        check(scene._try_attack(1.0, false) == (tab == "Kampf"), "Only the combat page can start attacks")
        if tab == "Kampf":
            await create_timer(0.8).timeout
    scene._on_hud_action("Wesen")
    var weapon_before = scene.model.weapon_index
    hud.buttons["weapon"].pressed.emit()
    check(scene.model.weapon_index != weapon_before, "Weapon change remains reachable")
    scene.model.gold = scene.model.upgrade_cost()
    scene._refresh()
    hud.buttons["upgrade"].pressed.emit()
    check(scene.model.upgrade_level == 1 and scene.model.gold == 0, "Upgrade spends real gold")
    scene._on_hud_action("Kampf")
    var ready_before = scene.skill_cooldowns[1]
    scene._on_skill(1)
    check(scene.skill_cooldowns[1] == ready_before, "Cannot spend unavailable momentum")
    scene.momentum = 100
    scene._on_skill(1)
    check(scene.momentum == 75 and scene.skill_cooldowns[1] > Time.get_ticks_msec(), "Skill starts cooldown and consumes momentum")
    var cooldown_before = scene.skill_cooldowns[1]
    scene._on_skill(1)
    check(scene.momentum == 75 and cooldown_before == scene.skill_cooldowns[1], "Cooldown rejects repeat input")
    await create_timer(0.8).timeout
    scene.rage = 100
    scene._on_skill(2)
    check(scene.rage == 60 and scene.skill_cooldowns[2] > Time.get_ticks_msec(), "Rage skill consumes its own resource")
    await create_timer(0.8).timeout
    scene.auto_enabled = false
    scene._on_hud_action("auto")
    check(scene.auto_enabled, "AUTO button toggles standard attacks")
    scene.auto_enabled = false
    for v in [Vector2(360,720), Vector2(720,1280), Vector2(720,1560), Vector2(1080,2400), Vector2(1280,720)]:
        var m = Layout.solve(v, 12, 18)
        hud.configure(m.logical_height)
        for id in ["skill0", "skill1", "skill2", "locked"]:
            var b: Button = hud.buttons[id]
            check(b.position.y + b.size.y <= hud.buttons["Kampf"].position.y, "Skills stay above navigation")
            check(b.size.x * m.ui_scale >= 44, "Skill touch target remains at least 44 pixels")
    if "--capture-ui" in OS.get_cmdline_user_args():
        scene.model = scene.CombatModel.new({"wave":5,"gold":148,"total_kills":4,"weapon_index":1})
        hud.model = scene.model
        scene.hero.equip_weapon(1)
        scene.enemy.show_wave(5)
        scene.momentum = 68
        scene.rage = 42
        scene.skill_cooldowns = [0,0,0]
        hud.toast_until = -1
        scene._refresh()
        for v in [Vector2i(720,1280), Vector2i(720,1560), Vector2i(360,800), Vector2i(1280,720)]:
            root.size = v
            await process_frame
            scene._layout()
            for tab in ["Kampf", "Wesen", "Abenteuer", "Beute", "Mehr"]:
                if v != Vector2i(720,1280) and tab != "Kampf":
                    continue
                scene._on_hud_action(tab)
                await process_frame
                await RenderingServer.frame_post_draw
                root.get_texture().get_image().save_png("/tmp/realm-ui-%dx%d-%s.png" % [v.x,v.y,tab])
    print("Combat UI: %d/%d checks" % [checks - failures, checks])
    scene.queue_free()
    await process_frame
    quit(1 if failures else 0)
