extends RefCounted
class_name RAHeroRoster
const Character=preload("res://scripts/systems/character_progress712.gd")
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
# Add IDs only after full pose/socket/weapon art integration and scene tests.
const VISUALLY_APPROVED=["realmwachter","runenpaladin","schattenjager"]
static var _data:Dictionary={}
static func catalog() -> Dictionary:
    if _data.is_empty():_data=JSON.parse_string(FileAccess.get_file_as_string("res://data/roster67.json")).heroes
    return _data
static func playable_catalog() -> Dictionary:
    var result={}
    for id in ["runenpaladin","schattenjager","realmwachter"]:
        if id in VISUALLY_APPROVED and bool(catalog()[id].get("playable",false)):
            result[id]=catalog()[id]
    return result

static func can_play(id:String) -> bool:
    return playable_catalog().has(id)

static func ensure(p:Dictionary) -> bool:
    if not p.has("hero_roster"):p.hero_roster={"schema":1,"active":"realmwachter","owned":{"realmwachter":{"xp":int(p.xp),"source":"legacy_guardian"}}}
    var d=p.hero_roster
    if not Validate.header(d) or not d.get("owned") is Dictionary or d.owned.is_empty():return false
    if d.has("independent_xp") and not d.independent_xp is bool:return false
    if d.has("starter_revision") and not Validate.integer(d.starter_revision,1,1):return false
    if not catalog().has(d.get("active")) or not d.owned.has(d.active):return false
    for id in d.owned:
        if not catalog().has(id) or not d.owned[id] is Dictionary or not Validate.integer(d.owned[id].get("xp"),0,2000000000):return false
    # Non-destructive 6.7.1 migration: former playable Kaela becomes a future
    # NPC. Keep all acquired hero records and earned XP, but restore the player's
    # masked guardian if the retired character was active.
    if not can_play(str(d.active)):
        d.active="realmwachter" if d.owned.has("realmwachter") else "runenpaladin" if d.owned.has("runenpaladin") else "schattenjager"
        if not d.owned.has(d.active):return false
    # One-time compensation for old purchases; marker prevents duplicate grants
    # on repeated loads. This does not affect fresh players or their inventory.
    if d.owned.has("kaela") and not bool(d.get("kaela_compensated",false)):
        p.gold=mini(2000000000,int(p.gold)+150)
        p.shards=mini(2000000000,int(p.shards)+8)
        d.kaela_compensated=true
    return true
static func active(p:Dictionary) -> String:return Character.visual_id(p) if Character.active(p) else str(p.hero_roster.active) if ensure(p) else "realmwachter"
static func xp(p:Dictionary,id:String="") -> int:
    if not ensure(p):return 0
    if id=="":id=active(p)
    if id.begins_with("adventurer_") and Character.exists(p):return int(p.character712.xp)
    if not p.hero_roster.owned.has(id):return 0
    if id=="realmwachter" and p.hero_roster.owned.size()==1 and not bool(p.hero_roster.get("independent_xp",false)):return int(p.xp)
    return int(p.hero_roster.owned[id].xp)
static func level(p:Dictionary,id:String="") -> int:return Progress.level(xp(p,id))
static func eligible(p:Dictionary,d:Dictionary) -> bool:
    return Progress.level(int(p.xp))>=int(d.unlock_level) and (d.stage=="" or int(p.world_progress.stars.get(d.stage,0))>0)
static func can_unlock(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not can_play(id) or p.hero_roster.owned.has(id):return false
    var d:Dictionary=catalog()[id]
    return eligible(p,d) and int(p.gold)>=int(d.gold) and int(p.shards)>=int(d.shards)
static func unlock(p:Dictionary,id:String) -> bool:
    if not can_unlock(p,id):return false
    if id=="runenpaladin" and can_adopt_starter(p):return adopt_starter(p)
    var d:Dictionary=catalog()[id]
    if p.hero_roster.owned.size()==1 and p.hero_roster.owned.has("realmwachter") and not bool(p.hero_roster.get("independent_xp",false)):p.hero_roster.owned.realmwachter.xp=int(p.xp)
    p.gold-=int(d.gold);p.shards-=int(d.shards);p.hero_roster.owned[id]={"xp":0,"source":"roster709"};return true
static func gain(p:Dictionary,amount:int) -> void:
    if not ensure(p) or amount<=0:return
    if Character.active(p):Character.gain(p,amount);return
    var id=active(p)
    p.hero_roster.owned[id].xp=mini(2000000000,xp(p,id)+amount) if p.hero_roster.owned.size()>1 or bool(p.hero_roster.get("independent_xp",false)) else int(p.xp)
static func definition(p:Dictionary) -> Dictionary:return Character.definition(p) if Character.active(p) else catalog()[active(p)]

static func can_adopt_starter(p:Dictionary) -> bool:
    return ensure(p) and not p.hero_roster.has("starter_revision") and p.hero_roster.owned.has("realmwachter") and not p.hero_roster.owned.has("runenpaladin")
static func adopt_starter(p:Dictionary) -> bool:
    if not can_adopt_starter(p):return false
    var previous_xp=xp(p,"realmwachter")
    p.hero_roster.owned.realmwachter.xp=previous_xp
    p.hero_roster.owned.runenpaladin={"xp":previous_xp,"source":"starter_transition709"}
    p.hero_roster.independent_xp=true;p.hero_roster.starter_revision=1
    return true
