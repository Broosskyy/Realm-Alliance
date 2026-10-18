extends RefCounted
class_name RAHeroEvolution
const Progress=preload("res://scripts/systems/player_progress.gd")
const FORM="awakened"
const UNLOCK_LEVEL=5
const GOLD=150
const SHARDS=8
const HP=20
const ATTACK=5
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("hero_evolution"):
        profile.hero_evolution={"schema":1,"unlocked":["base"],"active":"base"}
    var data=profile.hero_evolution
    if not data is Dictionary or int(data.get("schema",0))!=1 or not data.get("unlocked") is Array:return false
    if not data.unlocked.has("base") or str(data.get("active","")) not in data.unlocked:return false
    for id in data.unlocked:
        if id not in ["base",FORM]:return false
    return true
static func unlocked(profile: Dictionary) -> bool:
    return ensure(profile) and profile.hero_evolution.unlocked.has(FORM)
static func active(profile: Dictionary) -> bool:
    return unlocked(profile) and profile.hero_evolution.active==FORM
static func can_unlock(profile: Dictionary) -> bool:
    return ensure(profile) and not unlocked(profile) and Progress.level(int(profile.xp))>=UNLOCK_LEVEL and int(profile.gold)>=GOLD and int(profile.shards)>=SHARDS
static func unlock(profile: Dictionary) -> bool:
    if not can_unlock(profile):return false
    profile.gold-=GOLD;profile.shards-=SHARDS
    profile.hero_evolution.unlocked.append(FORM);profile.hero_evolution.active=FORM
    return true
static func toggle(profile: Dictionary) -> bool:
    if not unlocked(profile):return false
    profile.hero_evolution.active="base" if active(profile) else FORM
    return true
static func bonuses(profile: Dictionary) -> Dictionary:
    # Progression bonuses are permanent. Switching the cosmetic form cannot heal
    # or silently alter equipped items, skill costs, loot or the economy.
    return {"hp":HP if unlocked(profile) else 0,"attack":ATTACK if unlocked(profile) else 0}
