extends SceneTree

const Layout = preload("res://scripts/combat_layout.gd")
var failures: int = 0
var checks: int = 0

func check(ok: bool, explanation: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("FAIL " + explanation)
    else:
        print("PASS " + explanation)

func _initialize() -> void:
    var cases := {
        "small portrait": Vector2(360, 720),
        "standard portrait": Vector2(720, 1280),
        "tall portrait": Vector2(720, 1600),
        "large phone": Vector2(1080, 2400)
    }
    for name in cases.keys():
        var m: Dictionary = Layout.solve(cases[name])
        var v: Vector2 = m["viewport"]
        var tap: Rect2 = m["tap_rect"]
        var top: float = m["controls_top"]
        var origin: Vector2 = m["stage_origin"]
        var scale_factor: float = m["stage_scale"]
        check(scale_factor > 0.0, name + ": valid scene scale")
        check(tap.position.x >= -0.01 and tap.end.x <= v.x + 0.01, name + ": tap stays inside screen")
        check(tap.position.y >= m["hud_bottom"] - 0.01, name + ": tap does not cover HUD")
        check(tap.end.y <= top + 0.01, name + ": tap does not cover controls")
        check(origin.y > m["hud_bottom"] and origin.y < top, name + ": stage in arena")
        check(float(m["controls_height"]) <= 180.0, name + ": control panel stays compact")
        check(top + float(m["controls_height"]) <= v.y, name + ": panel fits screen")
    print("Combat layout: %d/%d checks." % [checks - failures, checks])
    quit(1 if failures > 0 else 0)
