extends RefCounted
class_name RAEnemyBehavior
var definition: Dictionary = {}
var state: String = "idle"
var deadline: float = 2.0
var strikes: int = 0
var second: bool = false

func configure(d: Dictionary, now: float) -> void:
    definition = d.duplicate(true)
    state = "idle"
    deadline = now + 2.1
    strikes = 0
    second = false

func update(now: float) -> Array:
    var events: Array = []
    if now + 0.00001 < deadline:
        return events
    if state == "idle":
        state = "windup"
        deadline = now + float(definition.windup)
        var heavy_next=definition.pattern=="heavy" and (strikes+1)%2==0
        events.append({"type":"telegraph", "duration":definition.windup,"pattern":"heavy" if heavy_next else ("single" if definition.pattern=="heavy" else definition.pattern)})
    elif state == "windup":
        strikes += 1
        var heavy = definition.pattern == "heavy" and strikes % 2 == 0
        events.append({"type":"enemy_strike", "multiplier":1.65 if heavy else (0.7 if second else 1.0),"heavy":heavy})
        if definition.pattern == "double" and not second:
            second = true
            deadline = now + 0.5
            events.append({"type":"telegraph", "duration":0.5,"pattern":"followup"})
        else:
            second = false
            state = "idle"
            deadline = now + float(definition.interval)
    return events

func snapshot() -> Dictionary:
    return {"state":state,"deadline":deadline,"strikes":strikes,"second":second}

func restore(d: Dictionary) -> void:
    state = str(d.get("state", "idle"))
    deadline = float(d.get("deadline", 2.1))
    strikes = int(d.get("strikes", 0))
    second = bool(d.get("second", false))
