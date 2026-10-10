extends Node2D
class_name RAEnemyVisual

var wave: int = 1
var health_ratio: float = 1.0
var _motion: Tween
var _base_scale: Vector2 = Vector2.ONE
var _display_scale: Vector2 = Vector2.ONE
var _base_position: Vector2 = Vector2.ZERO
var _idle_time: float = 0.0
var _dying: bool = false

func _ready() -> void:
    _base_scale = scale
    _display_scale = scale
    _base_position = position

func _process(delta: float) -> void:
    if _dying or (_motion != null and _motion.is_running()):
        return
    _idle_time += delta
    scale = _display_scale * (1.0 + sin(_idle_time * 2.0) * 0.014)
    position.y = _base_position.y + sin(_idle_time * 2.4) * 2.4

func show_wave(number: int) -> void:
    if _motion != null and _motion.is_running():
        _motion.kill()
    wave = number
    health_ratio = 1.0
    _dying = false
    # Never reset to Vector2.ONE: it used to silently cancel the combat scale.
    _display_scale = _base_scale * (1.08 if wave % 5 == 0 else 1.0)
    scale = _display_scale
    position = _base_position
    modulate = Color.WHITE
    queue_redraw()

func set_health(current_hp: int, maximum_hp: int) -> void:
    health_ratio = clampf(float(current_hp) / float(maxi(1, maximum_hp)), 0.0, 1.0)
    queue_redraw()

func _draw() -> void:
    var main_color := Color("#527b7d") if wave % 5 != 0 else Color("#b47859")
    var shadow_color := Color("#293c4f") if wave % 5 != 0 else Color("#58394d")
    draw_circle(Vector2(0,-54), 63.0 if wave % 5 == 0 else 54.0, shadow_color)
    draw_colored_polygon(PackedVector2Array([
        Vector2(-57,-96), Vector2(-85,-150), Vector2(-34,-119),
        Vector2(0,-129), Vector2(42,-119), Vector2(90,-147),
        Vector2(57,-96), Vector2(51,-15), Vector2(-51,-15)
    ]), main_color)
    draw_colored_polygon(PackedVector2Array([
        Vector2(-36,-93), Vector2(0,-115), Vector2(39,-94),
        Vector2(26,-54), Vector2(-27,-54)
    ]), Color("#8baba4"))
    draw_circle(Vector2(-19,-86),8.0,Color("#fcdb7d"))
    draw_circle(Vector2(20,-86),8.0,Color("#fcdb7d"))
    draw_circle(Vector2(-19,-85),3.0,Color("#392d31"))
    draw_circle(Vector2(20,-85),3.0,Color("#392d31"))
    draw_rect(Rect2(-24,-37,48,10),Color("#2c3d48"))
    draw_line(Vector2(-36,-16),Vector2(-54,0),Color("#293c4f"),9.0)
    draw_line(Vector2(36,-16),Vector2(54,0),Color("#293c4f"),9.0)
    # A grounded health bar immediately above the enemy, even in the POC.
    var boss := wave % 5 == 0
    var frame_color := Color("#c8a56b") if boss else Color("#8797aa")
    var hp_color := Color("#ef9965") if boss else Color("#76c6a6")
    draw_rect(Rect2(-73, -204, 146, 18), Color("#0a1521"))
    draw_rect(Rect2(-69, -200, 138, 10), Color("#384150"))
    draw_rect(Rect2(-69, -200, 138.0 * health_ratio, 10), hp_color)
    draw_rect(Rect2(-73, -204, 146, 18), frame_color, false, 2.0)

func play_hit() -> void:
    if _dying:
        return
    if _motion != null and _motion.is_running():
        _motion.kill()
    scale = _display_scale
    position = _base_position
    modulate = Color("#fff0c1")
    _motion = create_tween()
    _motion.set_trans(Tween.TRANS_SINE)
    _motion.tween_property(self, "position:x", _base_position.x + 11.0, 0.07)
    _motion.tween_property(self, "position:x", _base_position.x, 0.12)
    _motion.parallel().tween_property(self, "modulate", Color.WHITE, 0.15)

func play_death() -> void:
    if _motion != null and _motion.is_running():
        _motion.kill()
    _dying = true
    _motion = create_tween()
    _motion.set_trans(Tween.TRANS_QUAD)
    _motion.set_parallel(true)
    _motion.tween_property(self, "scale", _display_scale * 0.76, 0.27)
    _motion.tween_property(self, "position:y", _base_position.y + 18.0, 0.27)
    _motion.tween_property(self, "modulate:a", 0.0, 0.27)
