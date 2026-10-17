extends RefCounted
class_name RACombatLayout

# HUD and actors share one scale. Wide windows keep a centered portrait column.
static func solve(viewport_size: Vector2, safe_top: float = 0, safe_bottom: float = 0) -> Dictionary:
    var w = maxf(1, viewport_size.x)
    var h = maxf(1, viewport_size.y)
    var usable = maxf(1, h - safe_top - safe_bottom)
    var s = minf(w / 720.0, usable / 1280.0)
    var logical_h = usable / s
    var left = (w - 720.0 * s) / 2.0
    var hud_bottom = safe_top + 284.0 * s
    var controls_top = safe_top + (logical_h - 330.0) * s
    var origin = Vector2(w / 2.0, controls_top - 25.0 * s)
    return {
        "viewport": Vector2(w, h), "padding": 18.0 * s,
        "ui_left": left, "ui_scale": s, "logical_height": logical_h,
        "hud_bottom": hud_bottom, "controls_top": controls_top,
        "controls_height": 330.0 * s, "stage_origin": origin,
        "stage_scale": s, "font_scale": s,
        "tap_rect": Rect2(left, hud_bottom, 720.0 * s, maxf(0, controls_top - hud_bottom))
    }
