extends RefCounted
class_name RAActivities69
const V=preload("res://scripts/systems/domain_validation.gd")
const World=preload("res://scripts/systems/world_progress.gd")
const Economy=preload("res://scripts/systems/economy68.gd")
const Events=preload("res://scripts/systems/event69.gd")
const Chests=preload("res://scripts/systems/chest_rewards.gd")
const CATALOG={
 "harvest_abbey":{"name":"Herbstabtei","description":"Halloween · Kürbiswächter, Kristallschatten und Erntekönig. Sammle Erntezeichen und erfülle die Questkette.","region":"wolkgarten","count":5,"hp_scale":1.0,"damage_scale":1.0,"gold":70,"forge_dust":8,"unlock":"wolkgarten:2","timer":0,"event":"harvest_2026"},
 "gold_vault":{"name":"Schatzgewölbe","description":"3 Wellen · Gold und eine Wächtertruhe. Schwächere Gegner, kurze Goldrunde.","region":"wolkgarten","count":3,"hp_scale":1.15,"damage_scale":1.0,"gold":120,"forge_dust":4,"unlock":"wolkgarten:4","timer":0},
 "ember_forge":{"name":"Aschenschmiede","description":"5 Wellen · Doppelhiebe und Eruption. Runenstaub und Glutkerne für die Schmiede.","region":"glutkern","count":5,"hp_scale":1.25,"damage_scale":1.1,"gold":40,"forge_dust":20,"ember_core":2,"unlock":"glutkern:2","timer":0},
 "colossus_trial":{"name":"Prüfung des Kolosses","description":"Lokale Bossprüfung · 60 Sekunden. Bronze: Sieg, Silber: 40 s, Gold: 25 s. Keine geteilte Online-Begegnung.","region":"glutkern","count":1,"hp_scale":3.0,"damage_scale":1.3,"gold":150,"forge_dust":12,"ember_core":2,"unlock":"glutkern:4","timer":60}
}
static func ensure(p:Dictionary) -> bool:
    if not p.has("activities"):p.activities={"schema":1,"clears":{},"best_seconds":{},"receipts":{}}
    var d=p.activities
    if not V.header(d) or not d.get("clears") is Dictionary or not d.get("best_seconds") is Dictionary or not d.get("receipts") is Dictionary:return false
    for id in d.clears:
        if not CATALOG.has(id) or not V.integer(d.clears[id],0,2000000000):return false
    for id in d.best_seconds:
        if not CATALOG.has(id) or not (d.best_seconds[id] is float or d.best_seconds[id] is int) or not is_finite(float(d.best_seconds[id])) or float(d.best_seconds[id])<0:return false
    for uid in d.receipts:
        if not uid is String or not CATALOG.has(d.receipts[uid]):return false
    return true
static func unlocked(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not CATALOG.has(id):return false
    return int(p.world_progress.stars.get(CATALOG[id].unlock,0))>0
static func encounter(id:String,index:int) -> Dictionary:
    var d:Dictionary=CATALOG[id]
    var slot=4 if index==int(d.count)-1 else index
    var enemy=Events.catalog()[d.event].encounters[index].duplicate(true) if d.has("event") else World.encounter(d.region,slot)
    enemy.id=id+":"+enemy.id
    enemy.hp=int(round(enemy.hp*float(d.hp_scale)))
    enemy.damage=int(round(enemy.damage*float(d.damage_scale)))
    return enemy
static func complete(p:Dictionary,id:String,run:String,seconds:float) -> Dictionary:
    if not ensure(p) or not Economy.ensure(p) or not CATALOG.has(id) or p.activities.receipts.has(run):return {}
    var d:Dictionary=CATALOG[id]
    if float(d.timer)>0 and seconds>float(d.timer):return {}
    var medal=3 if id=="colossus_trial" and seconds<=25 else (2 if id=="colossus_trial" and seconds<=40 else 1)
    var gold=int(d.gold)*medal
    p.gold=mini(2000000000,int(p.gold)+gold)
    for key in Economy.MATERIALS:
        p.economy.materials[key]=mini(2000000000,int(p.economy.materials[key])+int(d.get(key,0)))
    p.activities.receipts[run]=id
    p.activities.clears[id]=mini(2000000000,int(p.activities.clears.get(id,0))+1)
    p.activities.best_seconds[id]=minf(seconds,float(p.activities.best_seconds.get(id,seconds)))
    if d.has("event"):Events.record(p,d.event,"clears")
    Chests.grant(p,("event:"+d.event+":" if d.has("event") else "")+run+":"+id+":completion")
    return {"gold":gold,"medal":medal,"seconds":seconds,"id":id}
