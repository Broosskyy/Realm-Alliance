extends Node2D
class_name RAEnemyVisual

var wave: int = 1
var _motion: Tween

func show_wave(number: int) -> void:
    wave = number
    scale = Vector2.ONE
    modulate = Color.WHITE
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

func play_hit() -> void:
    if _motion and _motion.is_running():
        _motion.kill()
    modulate = Color("#fff1cc")
    _motion = create_tween()
    _motion.tween_property(self,"modulate",Color.WHITE,0.16)

func play_death() -> void:
    if _motion and _motion.is_running():
        _motion.kill()
    _motion = create_tween()
    _motion.set_parallel(true)
    _motion.tween_property(self,"scale",Vector2(0.76,0.76),0.27)
    _motion.tween_property(self,"modulate:a",0.0,0.27)
