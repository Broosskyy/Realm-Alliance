extends SceneTree

const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyVisual = preload("res://scripts/enemy_visual.gd")

var failures: int = 0
var checks: int = 0

func _check(ok: bool, name: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("FAILED " + name)
    else:
        print("PASS " + name)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var arena := Node2D.new()
    root.add_child(arena)
    var hero: Node2D = HeroRig.new()
    arena.add_child(hero)
    var arm: Node2D = hero.get_node("BodyRoot/RightArmPivot")
    var socket: Node2D = hero.get_node("BodyRoot/RightArmPivot/WeaponSocket")
    _check(socket.get_parent() == arm, "weapon socket is parented to the moving hand")
    _check(socket.get_child_count() == 4, "starter sword has separate blade and hilt parts")
    hero.equip_weapon(1)
    _check(socket.get_child_count() == 4, "equipping swaps four weapon parts instead of overlaying")
    var before: Vector2 = socket.global_position
    arm.rotation_degrees = 43.0
    _check(socket.global_position.distance_to(before) > 6.0, "weapon follows the rotated arm")
    arm.rotation_degrees = 0.0
    _check(hero.play_attack(), "hero can start an attack")
    await create_timer(0.7).timeout
    _check(absf(arm.rotation_degrees) < 0.1, "attack returns hand to its rest angle")
    _check(hero.play_attack(true), "skill attack is available after recovery")

    var enemy: Node2D = EnemyVisual.new()
    enemy.position = Vector2(160, 120)
    enemy.scale = Vector2(1.48, 1.48)
    arena.add_child(enemy)
    enemy.show_wave(2)
    _check(enemy.scale.x > 1.40, "wave spawn preserves original enemy scale")
    enemy.set_health(5, 10)
    _check(absf(enemy.health_ratio - 0.5) < 0.001, "enemy HP bar reflects damage")
    enemy.play_death()
    await create_timer(0.33).timeout
    enemy.show_wave(5)
    _check(enemy.scale.x > 1.48, "boss wave applies intentional size bonus")
    _check(enemy.modulate.a > 0.99, "new enemy resets death transparency")
    print("Visual contract: %d/%d checks." % [checks - failures, checks])
    quit(1 if failures > 0 else 0)
