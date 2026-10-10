extends Node2D
class_name RAStageArt

# Temporary programmatic background. NO production asset is embedded in source.
func _draw() -> void:
    # Extended vertical backplate: tall phones must not expose dead black gaps
    # above/below the fixed combat band. No production art is changed.
    draw_rect(Rect2(-360, -850, 720, 1500), Color("#111a31"))
    draw_rect(Rect2(-360, -340, 720, 490), Color("#141f35", 0.38))
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
    draw_rect(Rect2(-360, 295, 720, 355), Color("#182630"))
    # Shallow atmospheric strokes keep the tall viewport visually connected.
    draw_line(Vector2(-360, 425), Vector2(360, 425), Color("#8a9c83", 0.08), 2)
    draw_line(Vector2(-360, 555), Vector2(360, 555), Color("#8a9c83", 0.04), 2)
    draw_rect(Rect2(-360, 116, 720, 7), Color("#b49c67", 0.8))
    draw_line(Vector2(-350, 200), Vector2(350, 200), Color("#121d29"), 3)
    for n in range(13):
        var x := -340 + n * 59
        draw_line(Vector2(x, 135), Vector2(x + 26, 218), Color("#455356", 0.52), 2)
