extends RefCounted
class_name RAJourney70
const V=preload("res://scripts/systems/domain_validation.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
const METRICS=["crafts","dungeons","boss_trials"]
const TITLES={"vault_keeper":{"name":"Hüter der Gewölbe","metric":"dungeons","goal":5},"colossus_breaker":{"name":"Kolossbrecher","metric":"boss_trials","goal":3},"rune_smith":{"name":"Runenschmied","metric":"crafts","goal":5}}
const SPECIALIZATIONS={"vanguard":{"name":"Vorhut","description":"+8 Angriff","attack":8,"hp":0,"defense":0},"sentinel":{"name":"Bastion","description":"+40 HP, +3 Verteidigung","attack":0,"hp":40,"defense":3}}
static func ensure(p:Dictionary) -> bool:
    if not p.has("journey"):p.journey={"schema":1,"last_seen":0,"day":-1,"week":-1,"daily_kills":0,"weekly_bosses":0,"claimed":{},"metrics":{"crafts":0,"dungeons":0,"boss_trials":0},"title":"","specialization":""}
    var d=p.journey
    if not V.header(d) or not d.get("claimed") is Dictionary or not d.get("metrics") is Dictionary:return false
    for key in ["last_seen","daily_kills","weekly_bosses"]:
        if not V.integer(d.get(key),0,9000000000000):return false
    for key in ["day","week"]:
        if not V.integer(d.get(key),-1,2000000000):return false
    for key in METRICS:
        if not V.integer(d.metrics.get(key),0,2000000000):return false
    for key in d.claimed:
        if key not in ["login","daily","weekly"] or d.claimed[key]!=true:return false
    return d.get("title") in [""]+TITLES.keys() and d.get("specialization") in [""]+SPECIALIZATIONS.keys()
# UTC periods, Monday-based weeks. Rollback never reopens a claimed period.
# Explicitly local clock, no claim of competitive/server time authority.
static func refresh(p:Dictionary,now:int) -> bool:
    if not ensure(p) or now<0:return false
    var d=p.journey
    now=maxi(now,int(d.last_seen))
    var high_water=int(floor(now/86400.0))*86400
    if high_water>int(d.last_seen):d.last_seen=high_water
    var day=int(floor(now/86400.0));var week=int(floor((day+3)/7.0))
    if day>int(d.day):
        d.day=day;d.daily_kills=0;d.claimed.erase("login");d.claimed.erase("daily")
    if week>int(d.week):d.week=week;d.weekly_bosses=0;d.claimed.erase("weekly")
    return true
static func kill(p:Dictionary,boss:bool,now:int) -> void:
    if not refresh(p,now):return
    p.journey.daily_kills=mini(2000000000,int(p.journey.daily_kills)+1)
    if boss:p.journey.weekly_bosses=mini(2000000000,int(p.journey.weekly_bosses)+1)
static func record(p:Dictionary,metric:String) -> void:
    if ensure(p) and metric in METRICS:p.journey.metrics[metric]=mini(2000000000,int(p.journey.metrics[metric])+1)
static func can_claim(p:Dictionary,id:String,now:int) -> bool:
    if not refresh(p,now) or p.journey.claimed.has(id):return false
    return id=="login" or (id=="daily" and int(p.journey.daily_kills)>=10) or (id=="weekly" and int(p.journey.weekly_bosses)>=5)
static func claim(p:Dictionary,id:String,now:int) -> bool:
    if not can_claim(p,id,now):return false
    var reward={"login":[25,1],"daily":[80,3],"weekly":[250,8]}[id]
    if int(p.gold)+reward[0]>2000000000 or int(p.shards)+reward[1]>2000000000:return false
    p.journey.claimed[id]=true;p.gold+=reward[0];p.shards+=reward[1];return true
static func earned(p:Dictionary,id:String) -> bool:
    return ensure(p) and TITLES.has(id) and int(p.journey.metrics[TITLES[id].metric])>=int(TITLES[id].goal)
static func select_title(p:Dictionary,id:String) -> bool:
    if not ensure(p) or (id!="" and not earned(p,id)):return false
    p.journey.title=id;return true
static func specialize(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not SPECIALIZATIONS.has(id) or id==p.journey.specialization or Progress.level(int(p.xp))<8:return false
    var cost=0 if p.journey.specialization=="" else 100
    if int(p.gold)<cost:return false
    p.gold-=cost;p.journey.specialization=id;return true
static func bonuses(p:Dictionary) -> Dictionary:
    return SPECIALIZATIONS.get(p.journey.specialization,{"attack":0,"hp":0,"defense":0}) if ensure(p) else {"attack":0,"hp":0,"defense":0}

static func next_goal(p:Dictionary) -> String:
    if int(p.kills)<5:return "Besiege fünf Gegner und hole deine erste Aufgabenbelohnung ab."
    if int(p.inventory[p.equipped].level)<2:return "Werte deine Klinge in Wesen auf. Ein Waffenlevel gibt +6 Angriff."
    if int(p.world_progress.stars.get("wolkgarten:4",0))==0:return "Bezwinge den Gartenkoloss. Dadurch öffnest du Glutkern und das Schatzgewölbe."
    if str(p.companions.active)=="":return "Wähle einen Begleiter in Wesen. Er trainiert durch deine Kampf-XP."
    if int(p.activities.clears.get("gold_vault",0))==0:return "Schließe das Schatzgewölbe ab und öffne deine Belohnungstruhe in Beute."
    if int(p.journey.metrics.crafts)==0:return "Sammle Runenstaub und Glutkerne für dein erstes Rezept."
    if int(p.activities.clears.get("colossus_trial",0))==0:return "Bezwinge den Aschenkoloss und stelle dich der lokalen Kolossprüfung."
    return "Meistere schnellere Bossprüfungen, sichtbare Entwicklungen und verdiente Titel."
