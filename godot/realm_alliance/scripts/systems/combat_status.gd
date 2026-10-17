extends RefCounted
class_name RACombatStatus
# Deadlines live on the simulation clock, never on wall time or render frames.
var active: Dictionary = {}

func apply(id: String, now: float, duration: float, payload: Dictionary = {}) -> void:
    var value = payload.duplicate(true)
    value.expires = now + duration
    active[id] = value

func has(id: String, now: float) -> bool:
    return active.has(id) and float(active[id].expires) > now + 0.00001

func remaining(id: String, now: float) -> float:
    return maxf(0, float(active.get(id, {}).get("expires", 0)) - now)

func expire(now: float) -> void:
    for id in active.keys():
        if float(active[id].expires) <= now + 0.00001:
            active.erase(id)

func take_ticks(id: String, now: float) -> Array:
    var ticks: Array = []
    if not active.has(id):
        return ticks
    var s: Dictionary = active[id]
    var next: float = float(s.get("next_tick", INF))
    while next <= now + 0.00001 and next <= float(s.expires) + 0.00001:
        ticks.append(float(s.get("damage", 0)))
        next += maxf(0.05, float(s.get("interval", 1)))
    s.next_tick = next
    return ticks
