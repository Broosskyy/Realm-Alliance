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
        if id not in ["base","upgraded",FORM,"legendary"]:return false
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
    var rank=highest(profile)
    return {"hp":[0,10,HP,40][rank],"attack":[0,3,ATTACK,12][rank]}

const FORMS=["base","upgraded","awakened","legendary"]
const NAMES=["I · Basis","II · Aufgewertet","III · Erwacht","IV · Legendär"]
static func highest(p:Dictionary) -> int:
    if not ensure(p):return 0
    var rank=0
    for id in p.hero_evolution.unlocked:rank=maxi(rank,FORMS.find(id))
    return rank
static func form_rank(p:Dictionary) -> int:
    return FORMS.find(p.hero_evolution.active) if ensure(p) else 0
static func form_cost(rank:int) -> Dictionary:
    return [{},{"gold":75,"shards":4,"forge_dust":10,"level":3},{"gold":GOLD,"shards":SHARDS,"level":UNLOCK_LEVEL},{"gold":600,"shards":24,"forge_dust":60,"ember_core":5,"level":12}][clampi(rank,0,3)]
static func can_advance(p:Dictionary) -> bool:
    var next=highest(p)+1
    if next>3:return false
    var cost=form_cost(next)
    if not preload("res://scripts/systems/economy68.gd").affordable(p,cost):return false
    return next<3 or (int(p.world_progress.stars.get("glutkern:4",0))>0 and int(p.activities.clears.get("colossus_trial",0))>0)
static func advance(p:Dictionary) -> bool:
    if not can_advance(p):return false
    var next=highest(p)+1;var cost=form_cost(next)
    p.gold-=int(cost.gold);p.shards-=int(cost.shards)
    for id in ["forge_dust","ember_core"]:p.economy.materials[id]-=int(cost.get(id,0))
    p.hero_evolution.unlocked.append(FORMS[next]);p.hero_evolution.active=FORMS[next];return true
static func select_form(p:Dictionary,id:String) -> bool:
    if not ensure(p) or id not in p.hero_evolution.unlocked:return false
    p.hero_evolution.active=id;return true
