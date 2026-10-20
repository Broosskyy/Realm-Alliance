extends RefCounted
class_name RACompanionProgress
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Roster=preload("res://scripts/systems/hero_roster.gd")
static var _data:Dictionary={}
static func catalog() -> Dictionary:
    if _data.is_empty():_data=JSON.parse_string(FileAccess.get_file_as_string("res://data/roster67.json")).pets
    return _data
static func ensure(p:Dictionary) -> bool:
    if not p.has("companions"):p.companions={"schema":1,"active":"","owned":{}}
    var d=p.companions
    if not Validate.header(d) or not d.get("owned") is Dictionary or not d.get("active") is String:return false
    if d.active!="" and not d.owned.has(d.active):return false
    for id in d.owned:
        var item=d.owned[id]
        if not catalog().has(id) or not item is Dictionary or not Validate.integer(item.get("xp"),0,2000000000) or not Validate.integer(item.get("evolution"),0,1):return false
    return true
static func level(p:Dictionary,id:String) -> int:
    if not ensure(p) or not p.companions.owned.has(id):return 1
    var value=int(p.companions.owned[id].xp);var result=1
    while result<10 and value>=40+20*(result-1):value-=40+20*(result-1);result+=1
    return result
static func can_acquire(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not catalog().has(id) or p.companions.owned.has(id):return false
    var d:Dictionary=catalog()[id]
    return not bool(d.get("event",false)) and Roster.eligible(p,d) and int(p.gold)>=int(d.gold) and int(p.shards)>=int(d.shards)
static func acquire(p:Dictionary,id:String) -> bool:
    if not can_acquire(p,id):return false
    var d:Dictionary=catalog()[id];p.gold-=int(d.gold);p.shards-=int(d.shards)
    p.companions.owned[id]={"xp":0,"evolution":0,"source":"local_companion_v1"};return true
static func equip(p:Dictionary,id:String) -> bool:
    if not ensure(p) or (id!="" and not p.companions.owned.has(id)):return false
    p.companions.active=id;return true
static func gain(p:Dictionary,amount:int) -> void:
    if not ensure(p) or p.companions.active=="" or amount<=0:return
    var d:Dictionary=p.companions.owned[p.companions.active];d.xp=mini(2000000000,int(d.xp)+maxi(1,amount/2))
static func can_evolve(p:Dictionary,id:String) -> bool:
    return ensure(p) and p.companions.owned.has(id) and level(p,id)>=3 and int(p.companions.owned[id].evolution)==0 and int(p.world_progress.stars.get("wolkgarten:4",0))>0 and int(p.gold)>=100 and int(p.shards)>=6
static func evolve(p:Dictionary,id:String) -> bool:
    if not can_evolve(p,id):return false
    p.gold-=100;p.shards-=6;p.companions.owned[id].evolution=1;return true
static func strength(p:Dictionary,id:String) -> float:
    if not ensure(p) or not p.companions.owned.has(id):return 1.0
    return (1+.06*(level(p,id)-1))*(1.5 if int(p.companions.owned[id].evolution)>0 else 1.0)
