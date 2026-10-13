extends RefCounted
class_name RACombatLayout

# Layout metrics are deterministic, easy to test and independent of the game state.
# A portrait-first fixed arena always lives between the HUD and action controls.
static func solve(viewport_size: Vector2) -> Dictionary:
    var w: float = maxf(320.0, viewport_size.x)
    var h: float = maxf(600.0, viewport_size.y)
    var pad: float = clampf(w * 0.034, 14.0, 30.0)
    var hud_bottom: float = clampf(h * 0.145, 132.0, 194.0)
    var controls_height: float = clampf(h * 0.112, 164.0, 180.0)
    var controls_top: float = h - controls_height - 16.0
    var arena_height: float = maxf(260.0, controls_top - hud_bottom)
    var scale_factor: float = minf(w / 720.0, arena_height / 720.0)
    # Place the actors closer to the action HUD instead of leaving a deep
    # empty strip under the combat floor on tall portrait phones.
    # Clamp by the touch-zone's bottom edge to preserve interactive separation.
    var desired_y: float = hud_bottom + arena_height * 0.64
    var max_y: float = controls_top - 304.0 * scale_factor
    var scene_origin := Vector2(w * 0.5, minf(desired_y, max_y))
    var tap_origin := scene_origin + Vector2(-348.0, -306.0) * scale_factor
    var tap_size := Vector2(696.0, 610.0) * scale_factor
    return {
        "viewport": Vector2(w, h),
        "padding": pad,
        "hud_bottom": hud_bottom,
        "controls_top": controls_top,
        "controls_height": controls_height,
        "stage_origin": scene_origin,
        "stage_scale": scale_factor,
        "tap_rect": Rect2(tap_origin, tap_size),
        "font_scale": clampf(w / 720.0, 0.70, 1.0)
    }
