extends RefCounted
class_name RAAnimationTimeline
# Presentation samples the same simulation time/deadline as CombatSession.
static func sample(id: String, elapsed: float, hit_at: float, recovery: float) -> Dictionary:
    if id.begins_with("chain_"):return basic_chain(id,elapsed,hit_at,recovery)
    var windup=maxf(hit_at,0.001)
    var p=clampf(elapsed/windup,0,1)
    var after=clampf((elapsed-windup)/maxf(recovery,0.01),0,1)
    var casting=id in ["arcane_eye","guardian_wall"]
    if id=="guardian_wall":
        return {"pose":"hit" if elapsed<recovery*0.75 else "ready","offset":Vector2(-8*(1-after),0),"done":elapsed>=hit_at+recovery,"phase":"guard"}
    var pose="ready"
    var offset=Vector2.ZERO
    if elapsed<windup:
        if casting:
            pose="ready" if id=="arcane_eye" else "hit"
            offset=Vector2(-4,-sin(p*PI)*10)
        else:
            pose="windup" if p<0.90 else "attack_contact"
            offset=Vector2(lerpf(-12,60 if id=="ultimate" else (48 if id=="sky_blade" else 32),smoothstep(0.55,1,p)),-sin(p*PI)*9)
    elif after<0.22:
        pose="ready" if casting else "attack_contact"
        offset=Vector2(0 if casting else (60 if id=="ultimate" else (48 if id=="sky_blade" else 32)),0)
    elif after<1:
        pose="ready" if casting else "recovery"
        offset=Vector2((0 if casting else (60 if id=="ultimate" else (48 if id=="sky_blade" else 32)))*(1-smoothstep(.22,1,after)),0)
    else:
        pose="idle"
    var frame={"pose":pose,"offset":offset,"done":elapsed>=windup+recovery,"phase":"charge" if p<0.5 else ("swing" if elapsed<windup else "recovery")}
    if not casting:frame.weapon_track=weapon_track(p,after,-1,0.0)
    return frame

static func basic_chain(id: String,elapsed: float,windup: float,recovery: float) -> Dictionary:
    var parts=id.split("_");var step=int(parts[1]);var contacts=int(parts[2])
    var total=windup+recovery
    var first=clampf(elapsed/maxf(.01,windup),0,1)
    var last=windup+(contacts-1)*.065
    var after=clampf((elapsed-last)/maxf(.01,total-last),0,1)
    var pose="windup" if step!=1 else "ready"
    var angle=lerpf(-20,-12,first) if step!=1 else lerpf(40,65,first)
    var advance=10.0 if step<2 else 18.0
    var approach=smoothstep(.5,1.0,first)
    var offset=Vector2(lerpf(-8*first,advance,approach),-sin(first*PI)*5-(12*approach if step==1 else 0))
    if elapsed>=windup:
        pose="attack_contact"
        var stroke=clampf((elapsed-windup)/maxf(.06,last-windup+.06),0,1)
        angle=lerpf(65,-60,stroke) if step==1 else lerpf(-12,28 if step==0 else 48,stroke)
        offset=Vector2(advance*(1-smoothstep(0,1,after)),-12*(1-after) if step==1 else 0)
        if elapsed>last+.1:pose="recovery"
    var stroke=clampf((elapsed-windup)/maxf(.06,last-windup+.06),0,1)
    return {"pose":"idle" if elapsed>=total else pose,"offset":offset,"done":elapsed>=total,"phase":"charge" if elapsed<windup else "recovery","weapon_angle":angle*(1-after),"weapon_track":weapon_track(first,after,step,stroke),"art_rotation":0.025*(1-after) if step==2 else 0.0}

# The blade follows a continuous track across body-frame changes. Pose names
# resolve through each hero's calibration; no renderer override may reset it.
static func weapon_track(charge:float,recovery:float,step:int,stroke:float) -> Dictionary:
    var preparation="ready" if step==1 else "windup"
    var pullback=40.0 if step==1 else (-12.0 if step<0 else -20.0)
    var contact=65.0 if step==1 else (0.0 if step<0 else -12.0)
    if charge<.5:
        var blend=smoothstep(0,.5,charge)
        return {"from":"idle","to":preparation,"blend":blend,"offset":pullback*blend}
    if charge<1:
        var blend=smoothstep(.5,1,charge)
        return {"from":preparation,"to":"attack_contact","blend":blend,"offset":lerpf(pullback,contact,blend)}
    var blend=smoothstep(0,1,recovery)
    var swing=sin(minf(recovery/.55,1.0)*PI)*28 if step<0 else (lerpf(65,-60,stroke) if step==1 else lerpf(-12,28 if step==0 else 48,stroke))
    return {"from":"attack_contact","to":"idle","blend":blend,"offset":swing*(1-blend)}

