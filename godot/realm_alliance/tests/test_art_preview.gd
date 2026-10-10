extends SceneTree

# Tests the real imported art preview without changing existing gameplay contracts.
const PreviewHero = preload("res://scripts/bramble_preview_hero.gd")
const PreviewEnemy = preload("res://scripts/bramble_preview_enemy.gd")
const PreviewSlash = preload("res://scripts/bramble_preview_slash.gd")

var checks: int = 0
var failures: int = 0

func verify(value: bool, text: String) -> void:
    checks += 1
    if value:
        print("PASS: " + text)
    else:
        failures += 1
        push_error("FAIL: " + text)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var files: Array[String] = [
        "hero/idle.png", "hero/ready.png", "hero/windup.png", "hero/contact.png", "hero/recovery.png",
        "weapon/longsword.png", "stage/glow_stump.png",
        "enemy/idle.png", "enemy/attack.png", "enemy/hit.png", "enemy/defeated.png",
        "vfx/00_glint.png", "vfx/01_arc_start.png", "vfx/02_arc_grow.png", "vfx/03_slash_peak.png",
        "vfx/04_impact_peak.png", "vfx/05_burst.png", "vfx/06_arc_fade.png", "vfx/07_motes_fade.png"
    ]
    for relative in files:
        var path: String = "res://assets/preview/bramble/" + relative
        verify(ResourceLoader.exists(path), "source texture imported: " + relative)

    for relative in ["hero/idle.png", "weapon/longsword.png", "enemy/idle.png", "vfx/03_slash_peak.png"]:
        var texture: Texture2D = load("res://assets/preview/bramble/" + relative)
        var image: Image = texture.get_image()
        verify(image.get_width() > 0 and image.get_height() > 0, "image decodes: " + relative)
        verify(image.get_pixel(0, 0).a < 0.10, "transparent corner: " + relative)

    var parent := Node2D.new()
    root.add_child(parent)
    var hero: RABramblePreviewHero = PreviewHero.new()
    parent.add_child(hero)
    verify(hero.socket_is_separate(), "weapon is a separate sprite parented to hand")
    verify(hero.preview_pose() == "idle", "authored body starts idle")
    hero.equip_weapon(2)
    verify(hero.play_attack(), "authored attack starts")
    await create_timer(0.29).timeout
    verify(hero.preview_pose() == "contact" or hero.preview_pose() == "recovery", "authored keyposes advance")
    await create_timer(0.45).timeout
    verify(hero.preview_pose() == "idle", "authored attack finishes and restores idle")

    var enemy: RABramblePreviewEnemy = PreviewEnemy.new()
    enemy.scale = Vector2.ONE * 0.82
    parent.add_child(enemy)
    enemy.show_wave(5)
    verify(enemy.scale.x > 0.82, "boss scales relative to original artwork")
    enemy.set_health(3, 10)
    verify(absf(enemy.health_ratio - 0.3) < 0.001, "art-backed enemy HP updates")
    verify(enemy.preview_has_four_states(), "monster preview imports four states")
    var slash: RABramblePreviewSlash = PreviewSlash.new()
    slash.configure(false)
    parent.add_child(slash)
    verify(slash.preview_frame_count() == 8, "eight source-authored slash VFX frames are available")
    print("Shared art preview: %d/%d checks passed." % [checks - failures, checks])
    quit(1 if failures > 0 else 0)
