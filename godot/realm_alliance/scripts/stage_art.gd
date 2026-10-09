extends Node2D
class_name RAStageArt

# Temporary programmatic background. NO production asset is embedded in source.
func _draw() -> void:
    draw_rect(Rect2(-360, -370, 720, 640), Color("#111a31"))
    draw_circle(Vector2(155, -245), 100, Color("#2a4260", 0.34))
    draw_circle(Vector2(158, -245), 63, Color("#96acde", 0.11))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-360, 55), Vector2(-240, -102), Vector2(-126, 55),
        Vector2(-8, -160), Vector2(155, 30), Vector2(295, -90), Vector2(360, 70),
        Vector2(360, 235), Vector2(-360, 235)
    ]), Color("#1e3046"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-360, 120), Vector2(-180, -15), Vector2(-90, 90),
        Vector2(120, -45), Vector2(360, 100), Vector2(360, 250), Vector2(-360, 250)
    ]), Color("#233a46"))
    draw_rect(Rect2(-360, 115, 720, 180), Color("#26343a"))
    draw_rect(Rect2(-360, 116, 720, 7), Color("#b49c67", 0.8))
    draw_line(Vector2(-350, 200), Vector2(350, 200), Color("#121d29"), 3)
    for n in range(13):
        var x := -340 + n * 59
        draw_line(Vector2(x, 135), Vector2(x + 26, 218), Color("#455356", 0.52), 2)
