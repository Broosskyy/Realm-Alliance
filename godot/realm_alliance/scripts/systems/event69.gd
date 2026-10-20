extends RefCounted
class_name RAEvent69
const V=preload("res://scripts/systems/domain_validation.gd")
const Economy=preload("res://scripts/systems/economy68.gd")
const Chests=preload("res://scripts/systems/chest_rewards.gd")
static var _catalog:Dictionary={}
static func catalog() -> Dictionary:
    if _catalog.is_empty():_catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/events69.json"))
    return _catalog
static func ensure(p:Dictionary) -> bool:
    if not p.has("event_progress"):p.event_progress={"schema":1,"packs":{}}
    var d=p.event_progress
    if not V.header(d) or not d.get("packs") is Dictionary:return false
    for id in d.packs:
        if not catalog().has(id):return false
        var pack=d.packs[id]
        if not pack is Dictionary or not pack.get("claimed") is Dictionary:return false
        for metric in ["kills","bosses","clears"]:
            if not V.integer(pack.get(metric),0,2000000000):return false
        for quest in pack.claimed:
            if definition(id,quest).is_empty() or pack.claimed[quest]!=true:return false
    return true
static func pack(p:Dictionary,id:String) -> Dictionary:
    if not ensure(p) or not catalog().has(id):return {}
    if not p.event_progress.packs.has(id):p.event_progress.packs[id]={"kills":0,"bosses":0,"clears":0,"claimed":{}}
    return p.event_progress.packs[id]
static func record(p:Dictionary,id:String,metric:String,boss:bool=false) -> void:
    var d=pack(p,id)
    if d.is_empty():return
    if metric in ["kills","clears"]:d[metric]=mini(2000000000,int(d[metric])+1)
    if boss:d.bosses=mini(2000000000,int(d.bosses)+1)
    if Economy.ensure(p):p.economy.materials.harvest_token=mini(2000000000,int(p.economy.materials.harvest_token)+(5 if boss else (8 if metric=="clears" else 1)))
static func definition(id:String,quest:String) -> Dictionary:
    if catalog().has(id):
        for d in catalog()[id].quests:
            if d.id==quest:return d
    return {}
static func can_claim(p:Dictionary,id:String,quest:String) -> bool:
    var progress=pack(p,id);var d=definition(id,quest)
    return not progress.is_empty() and not d.is_empty() and not progress.claimed.has(quest) and (d.requires=="" or progress.claimed.has(d.requires)) and int(progress[d.metric])>=int(d.goal)
static func claim(p:Dictionary,id:String,quest:String) -> bool:
    if not can_claim(p,id,quest) or not Economy.ensure(p):return false
    var d=definition(id,quest)
    p.event_progress.packs[id].claimed[quest]=true
    p.economy.materials.harvest_token=mini(2000000000,int(p.economy.materials.harvest_token)+int(d.tokens))
    Chests.grant(p,"event:"+id+":"+quest)
    return true
