extends RefCounted
class_name RAPlayerProgress

static func required(level: int) -> int:
    return 80 + 20 * (level - 1)

static func level(xp: int) -> int:
    var result = 1
    var remaining = maxi(0, xp)
    while result < 100 and remaining >= required(result):
        remaining -= required(result)
        result += 1
    return result

static func xp_in_level(xp: int) -> int:
    var result = 1
    var remaining = maxi(0, xp)
    while result < 100 and remaining >= required(result):
        remaining -= required(result)
        result += 1
    return remaining
