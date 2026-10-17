extends Node2D
class_name RAImpactFX

# Small procedural impact drawn in the stage's own coordinate system.
# No full-screen color rect: avoids blue/white touch flashing.
var _age: float = 0.0
var _lifetime: float = 0.33
var _skill: bool = false

func configure(is_skill: bool) -> void:
    _skill = is_skill
    _lifetime = 0.47 if _skill else 0.33

func _process(delta: float) -> void:
    _age += delta
    if _age >= _lifetime:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var t: float = clampf(_age / _lifetime, 0.0, 1.0)
    var alpha: float = (1.0 - t) * (1.0 - t)
    var radius: float = (55.0 if _skill else 40.0) + t * 63.0
    var hot := Color(1.0, 0.82 if _skill else 0.93, 0.55, alpha)
    var edge := Color(0.82 if _skill else 0.75, 0.49 if _skill else 0.84, 1.0, alpha * 0.70)
    draw_arc(Vector2.ZERO, radius, -2.28, 0.32, 20, hot, 9.0 if _skill else 6.0, true)
    draw_arc(Vector2.ZERO, radius - 16.0, -2.1, 0.1, 20, edge, 3.0, true)
    draw_circle(Vector2.ZERO, (13.0 if _skill else 9.0) * (1.0 - t) + 2.0, Color(1.0, 0.97, 0.81, alpha * 0.8))
    for i in range(9 if _skill else 6):
        var angle: float = float(i) * TAU / float(9 if _skill else 6) + 0.28
        var start: Vector2 = Vector2.RIGHT.rotated(angle) * (18.0 + 17.0 * t)
        var stop: Vector2 = Vector2.RIGHT.rotated(angle) * (35.0 + 60.0 * t)
        draw_line(start, stop, hot, 4.0 if _skill else 2.8, true)
