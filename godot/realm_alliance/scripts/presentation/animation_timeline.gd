extends RefCounted
class_name RAAnimationTimeline
# Presentation samples the same simulation time/deadline as CombatSession.
static func sample(id: String, elapsed: float, hit_at: float, recovery: float) -> Dictionary:
    var windup=maxf(hit_at,0.001)
    var p=clampf(elapsed/windup,0,1)
    var after=clampf((elapsed-windup)/maxf(recovery,0.01),0,1)
    var casting=id in ["arcane_eye","guardian_wall"]
    var pose="ready"
    var offset=Vector2.ZERO
    if elapsed<windup:
        if casting:
            pose="ready" if id=="arcane_eye" else "hit"
            offset=Vector2(-4,-sin(p*PI)*10)
        else:
            pose="windup" if p<0.72 else "attack_contact"
            offset=Vector2(lerpf(-12,34,smoothstep(0.65,1,p)),-sin(p*PI)*9)
    elif after<0.22:
        pose="ready" if casting else "attack_contact"
        offset=Vector2(0 if casting else (48 if id=="sky_blade" else 32),0)
    elif after<1:
        pose="ready" if casting else "recovery"
        offset=Vector2((0 if casting else 24)*(1-after),0)
    else:
        pose="idle"
    return {"pose":pose,"offset":offset,"done":elapsed>=windup+recovery,"phase":"charge" if p<0.5 else ("swing" if elapsed<windup else "recovery")}
