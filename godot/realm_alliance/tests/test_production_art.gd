extends SceneTree

const Gate = preload("res://scripts/production_art_gate.gd")
const Hero = preload("res://scripts/production_hero.gd")
const Enemy = preload("res://scripts/production_enemy.gd")

var total: int = 0
var failures: int = 0

func check(ok: bool, name: String) -> void:
    total += 1
    if ok:
        print("PASS ", name)
    else:
        failures += 1
        push_error("FAIL " + name)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not Gate.available():
        check(Gate.missing_paths().size() > 0, "missing assets choose safe Bramble preview")
        print("Production art: FALLBACK (asset-bundle ZIP not yet imported)")
        quit(1 if failures > 0 else 0)
        return
    var arena: Node2D = Node2D.new()
    root.add_child(arena)
    var hero: RAProductionHero = Hero.new()
    arena.add_child(hero)
    check(hero.weapon_is_modular(), "weapon sprite is separate from body")
    check(hero.current_pose() == "idle", "hero starts in idle")
    var body: Sprite2D = hero.get_node("ArtRoot/BodySprite")
    var weapon: Sprite2D = hero.get_node("ArtRoot/RightHandSocket/ReplaceableSword")
    var socket: Node2D = hero.get_node("ArtRoot/RightHandSocket")
    check(body.position == -Hero.PIVOT, "common ground pivot")
    check((weapon.position + Hero.BLADE_GRIP * weapon.scale).length() < 0.01, "wrapped sword handle attaches to socket")
    var first: Texture2D = weapon.texture
    hero.equip_weapon(1)
    check(first != weapon.texture, "weapon swaps independently")
    for pose in Gate.HERO_STATES:
        hero._set_pose(pose)
        check(body.texture != null and body.position == -Hero.PIVOT, pose + ": grounded body texture")
        check(socket.position == Hero.HANDS[pose] - Hero.PIVOT, pose + ": calibrated hand")
    hero._set_pose("idle")
    check(hero.play_attack(), "attack can start")
    await create_timer(0.75).timeout
    check(hero.current_pose() == "idle", "attack recovers")
    var golem: RAProductionEnemy = Enemy.new()
    golem.scale = Vector2.ONE * 0.78
    arena.add_child(golem)
    golem.show_wave(5)
    check(golem.scale.x > 0.78, "boss scale");
    var sprite: Sprite2D = golem.get_node("GolemSprite")
    var initial: Vector2 = sprite.position
    golem.play_hit()
    check(sprite.position == initial, "golem hit grounded")
    golem.play_death()
    check(sprite.position == initial, "golem defeated grounded")
    print("Production art: %d/%d checks" % [total - failures, total])
    quit(1 if failures > 0 else 0)
