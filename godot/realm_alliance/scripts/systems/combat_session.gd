extends RefCounted
class_name RACombatSession

const Definitions = preload("res://scripts/systems/skill_definition.gd")
const SkillRuntime = preload("res://scripts/systems/skill_runtime.gd")
const Status = preload("res://scripts/systems/combat_status.gd")
const Behavior = preload("res://scripts/systems/enemy_behavior.gd")
const Equipment = preload("res://scripts/systems/equipment.gd")
const HeroEquipment=preload("res://scripts/systems/hero_equipment.gd")
const Evolution=preload("res://scripts/systems/hero_evolution.gd")
const Progress = preload("res://scripts/systems/player_progress.gd")
const Rewards = preload("res://scripts/systems/reward_system.gd")
const Migration = preload("res://scripts/systems/save_migration.gd")
const World=preload("res://scripts/systems/world_progress.gd")
const Advancement=preload("res://scripts/systems/skill_progress.gd")
const Quests=preload("res://scripts/systems/quest_system.gd")
const Chests=preload("res://scripts/systems/chest_rewards.gd")
const Tap=preload("res://scripts/systems/tap_combat.gd")
const Boss=preload("res://scripts/systems/boss_phase.gd")
const Roster=preload("res://scripts/systems/hero_roster.gd")
const Companions=preload("res://scripts/systems/companion_progress.gd")
const PetRuntime=preload("res://scripts/systems/companion_runtime.gd")
var companion=PetRuntime.new()
var tap=Tap.new()
var boss=Boss.new()
var action_sequence=0
const ACTOR_ID="hero:realmwachter:local"
const STEP: float = 1.0 / 60.0
const SKILL_IDS = ["sky_blade", "arcane_eye", "rage_flame", "guardian_wall"]
const WEAPON_IDS = Equipment.IDS

var profile: Dictionary
var skills = SkillRuntime.new()
var enemy_status = Status.new()
var hero_status = Status.new()
var behavior = Behavior.new()
var enemy_definition: Dictionary = {}
var clock: float = 0.0
var accumulator: float = 0.0
var region: String = "wolkgarten"
var tier: int = 0
var encounter: int = 0
var run_id: String = "run-1"
var outcome: String = "fighting"
var player_hp: int = 150
var enemy_hp: int = 85
var enemy_max_hp: int = 85
var momentum: float = 25.0
var rage: float = 0.0
var busy_until: float = 0.0
var pending: Dictionary = {}
var transition_at: float = 0.0
var hit_count: int = 0
var events: Array = []
var read_only: bool = false
var load_error: String = ""
var gold: int:
    get: return int(profile.gold)
    set(value): profile.gold = value
var wave: int:
    get: return tier * 5 + encounter + 1
var weapon_index: int:
    get: return Equipment.IDS.find(profile.equipped)
var upgrade_level: int:
    get: return int(profile.inventory[profile.equipped].level) - 1
var total_kills: int:
    get: return int(profile.kills)
var level: int:
    get: return Progress.level(int(profile.xp))
var hero_id:String:
    get:return Roster.active(profile)
var hero_name:String:
    get:return str(Roster.definition(profile).name)
var hero_level:int:
    get:return Roster.level(profile)
var actor_id:String:
    get:return "hero:"+hero_id+":local"
var player_max_hp: int:
    get: return int(round((150+(hero_level-1)*12)*float(Roster.definition(profile).hp_scale)))+int(HeroEquipment.stats(profile).hp)+int(Evolution.bonuses(profile).hp)+int(Advancement.bonuses(profile).hp)
var defense: int:
    get: return int(HeroEquipment.stats(profile).defense)+int(Roster.definition(profile).defense)
var power: int:
    get: return hero_damage()*10+player_max_hp+defense*12

func _init(data: Dictionary = {}) -> void:
    var normalized: Dictionary = Migration.normalize(data)
    profile = normalized.profile
    read_only = bool(normalized.get("read_only", false))
    load_error = str(normalized.get("load_error", ""))
    if not HeroEquipment.ensure(profile):
        read_only=true
        load_error="Ausrüstungsdaten nicht kompatibel. Original bleibt unverändert; Speichern gesperrt."
    if not Evolution.ensure(profile):
        read_only=true
        load_error="Evolutionsdaten nicht kompatibel. Original bleibt unverändert; Speichern gesperrt."
    var checkpoint: Dictionary = normalized.get("checkpoint", {})
    for domain in [World,Advancement,Quests,Chests,Tap,Roster,Companions]:
        var valid=domain.ensure(profile,checkpoint) if domain==World else domain.ensure(profile)
        if not valid:
            read_only=true;load_error="Fortschrittsdaten nicht kompatibel. Original bleibt unverändert; Speichern gesperrt."
    region=str(checkpoint.get("region","wolkgarten"))
    if region not in World.IDS or not World.unlocked(profile,region):
        region="wolkgarten";read_only=true;load_error="Region nicht kompatibel; Speichern gesperrt."
    _refresh_skill_definitions()
    tier = clampi(int(checkpoint.get("tier",0)),0,100)
    encounter = clampi(int(checkpoint.get("encounter",0)),0,4)
    run_id = str(checkpoint.get("run_id", "run-1"))
    _spawn()
    if checkpoint.has("clock"):
        clock = maxf(0, float(checkpoint.clock))
        player_hp = clampi(int(checkpoint.get("player_hp", player_max_hp)),0,player_max_hp)
        enemy_hp = clampi(int(checkpoint.get("enemy_hp",enemy_max_hp)),0,enemy_max_hp)
        momentum = clampf(float(checkpoint.get("momentum",25)),0,100)
        rage = clampf(float(checkpoint.get("rage",0)),0,100)
        outcome = str(checkpoint.get("outcome","fighting"))
        if outcome not in ["fighting","breathe","victory","defeat"]:
            outcome = "fighting"
        busy_until = float(checkpoint.get("busy_until",0))
        transition_at = float(checkpoint.get("transition_at",clock))
        pending = checkpoint.get("pending",{}).duplicate(true)
        hit_count = int(checkpoint.get("hit_count",0))
        skills.ready_at = checkpoint.get("cooldowns",{}).duplicate(true)
        enemy_status.active = checkpoint.get("enemy_status",{}).duplicate(true)
        hero_status.active = checkpoint.get("hero_status",{}).duplicate(true)
        behavior.restore(checkpoint.get("behavior",{}))
        action_sequence=maxi(0,int(checkpoint.get("action_sequence",0)))
        var tap_state=checkpoint.get("tap_combat",{})
        var boss_state=checkpoint.get("boss_phase",{})
        var pet_state=checkpoint.get("companion_runtime",{})
        if not pet_state is Dictionary or not companion.restore(pet_state) or not tap_state is Dictionary or not boss_state is Dictionary or not tap.restore(tap_state) or not boss.restore(boss_state):
            read_only=true;load_error="Kampfdaten nicht kompatibel; Original bleibt geschützt."
    else:
        player_hp = player_max_hp
    events.clear()

func hero_damage() -> int:
    return maxi(1,int(round((Equipment.damage(profile)+2*(hero_level-1)+int(Evolution.bonuses(profile).attack)+int(Advancement.bonuses(profile).attack))*float(Roster.definition(profile).attack_scale))))

func unlock_hero(id:String) -> bool:return not read_only and Roster.unlock(profile,id)
func select_hero(id:String) -> bool:
    if read_only or not Roster.ensure(profile) or not Roster.can_play(id) or not profile.hero_roster.owned.has(id) or id==hero_id:return false
    # A roster change is NOT a new dungeon run: keep checkpoint, enemy health,
    # reward claim IDs, run serial, status effects on the enemy and time.
    # Cancel only the outgoing hero's action and defensive effects.
    profile.hero_roster.active=id
    _refresh_skill_definitions()
    pending.clear()
    busy_until=clock
    hero_status.active.clear()
    tap.reset_chain()
    player_hp=clampi(player_hp,0,player_max_hp) # Never heal by switching heroes.
    return true
func acquire_companion(id:String) -> bool:return not read_only and Companions.acquire(profile,id)
func select_companion(id:String) -> bool:
    if read_only or not Companions.ensure(profile) or id==str(profile.companions.active):return false
    var previous_id=str(profile.companions.active)
    if not Companions.equip(profile,id):return false
    # In-flight attacks of a removed companion must never land as the new pet.
    companion.pending.clear()
    # First pet equip should feel immediate; repeated mid-combat swaps must not
    # be used to bypass the existing companion attack cooldown.
    if previous_id!="":companion.ready_at=maxf(companion.ready_at,clock+0.35)
    return true
func evolve_companion(id:String) -> bool:return not read_only and Companions.evolve(profile,id)

func upgrade_cost() -> int:
    return Equipment.upgrade_cost(profile)

func try_upgrade() -> bool:
    if read_only or not Equipment.upgrade(profile):return false
    Quests.record(profile,"upgrades");return true

func upgrade_weapon(id: String) -> bool:
    if read_only or not Equipment.upgrade_item(profile,id):return false
    Quests.record(profile,"upgrades");return true

func _refresh_skill_definitions() -> void:
    for id in SKILL_IDS:
        var d=Advancement.definition(profile,id)
        var changes:Dictionary=Roster.definition(profile).skills.get(id,{})
        var rank=Advancement.rank(profile,id)-1
        for key in changes:
            d[key]=changes[key]
            if key=="multiplier":d[key]=float(d[key])*(1+.1*rank)
            elif key=="absorb_fraction":d[key]=float(d[key])+.025*rank
        skills.definitions[id]=d

func upgrade_skill(id: String) -> bool:
    if read_only or not Advancement.upgrade(profile,id):return false
    _refresh_skill_definitions();return true

func train_talent(id: String) -> bool:
    var before=player_max_hp
    if read_only or not Advancement.talent(profile,id):return false
    if player_hp>0:player_hp=clampi(player_hp+player_max_hp-before,1,player_max_hp)
    return true

func claim_quest(id: String) -> bool:
    return not read_only and Quests.claim(profile,id)

func open_chest() -> Dictionary:
    if read_only:return {}
    return Chests.open(profile)

func start_stage(region_id: String,index: int=0) -> bool:
    if read_only or not World.can_enter(profile,region_id,index):return false
    region=region_id
    tier=0
    _reset_run(index)
    return true

func equip(id: String) -> bool:
    if not profile.inventory.has(id):
        return false
    profile.equipped = id
    hit_count = 0
    return true

func cycle_weapon() -> int:
    for offset in range(1,6):
        var id: String = Equipment.IDS[(weapon_index + offset) % 5]
        if profile.inventory.has(id) and equip(id):
            break
    return weapon_index

func set_look(id: String) -> bool:
    if id not in ["canonical", "emerald", "astral"]:
        return false
    profile.look = id
    return true

func change_gear(id: String, operation: String="equip") -> bool:
    if read_only:return false
    var before=player_max_hp
    var accepted=false
    match operation:
        "acquire":accepted=HeroEquipment.acquire(profile,id)
        "equip":accepted=HeroEquipment.equip(profile,id)
        "unequip":accepted=HeroEquipment.unequip(profile,id)
        "upgrade":accepted=HeroEquipment.upgrade(profile,id)
    if accepted and player_hp>0:player_hp=clampi(player_hp+player_max_hp-before,1,player_max_hp)
    return accepted

func change_evolution() -> bool:
    if read_only:return false
    var before=player_max_hp
    var accepted=Evolution.toggle(profile) if Evolution.unlocked(profile) else Evolution.unlock(profile)
    if accepted and player_hp>0:player_hp=clampi(player_hp+player_max_hp-before,1,player_max_hp)
    return accepted

func toggle_aura() -> bool:
    if level < 3:
        return false
    profile.aura = not bool(profile.aura)
    return true

func select_hit_mode(value: int) -> bool:
    return not read_only and Tap.select(profile,value)

func request_basic(source: String="manual") -> bool:
    return request_action("basic",{"tap_chain":true,"input_source":source})

func configure_auto_skills(enabled: bool,selected: Array) -> bool:
    if read_only or not Tap.ensure(profile):return false
    var candidate={"schema":1,"mode":profile.combat_mastery.mode,"auto_enabled":enabled,"auto_skills":selected.duplicate()}
    if not Tap.ensure({"combat_mastery":candidate}):return false
    profile.combat_mastery=candidate;return true

func request_auto_skill() -> bool:
    if not Tap.ensure(profile) or not profile.combat_mastery.auto_enabled:return false
    for id in profile.combat_mastery.auto_skills:
        var d:Dictionary=skills.definitions[id]
        if d.cost_type=="momentum" and momentum<maxf(60,float(d.cost)):continue
        if d.cost_type=="rage" and rage<maxf(80,float(d.cost)):continue
        if id=="guardian_wall" and (player_hp>player_max_hp*.55 or hero_status.has("shield",clock)):continue
        if id=="arcane_eye" and enemy_status.has("mark",clock):continue
        if id=="rage_flame" and enemy_status.has("burn",clock):continue
        if request_action(id):return true
    return false

func request_action(id: String = "basic", options: Dictionary={}) -> bool:
    if outcome != "fighting" or player_hp <= 0 or enemy_hp <= 0 or not pending.is_empty() or clock < busy_until - 0.00001:
        return false
    var d: Dictionary
    if id=="ultimate":
        if not Tap.ultimate_unlocked(profile) or tap.charge<100 or clock<tap.ultimate_at:return false
        d=Tap.catalog().ultimate.duplicate(true)
        tap.charge=0;tap.ultimate_at=clock+float(d.cooldown)
    elif id == "basic":
        d = {"id":"basic","effect":"direct","multiplier":1.0,"windup":0.28,"recovery":0.35,"vfx":"basic"}
    else:
        if not skills.can_cast(id, clock, hero_level, {"momentum":momentum,"rage":rage}):
            return false
        d = skills.commit(id, clock)
        Quests.record(profile,"skills")
        if d.cost_type == "momentum":
            momentum -= float(d.cost)
        elif d.cost_type == "rage":
            rage -= float(d.cost)
    if id=="basic" and bool(options.get("tap_chain",false)):
        d=tap.plan(profile,clock);tap.accepted(d,clock)
    action_sequence+=1
    d.action_id=run_id+":"+actor_id+":"+str(action_sequence)
    d.actor_id=actor_id;d.target_id=run_id+":"+region+":"+str(encounter)
    d.rank=Advancement.rank(profile,id) if id in SKILL_IDS else 1
    d.base_damage = hero_damage()
    d.weapon_trait = Equipment.definition(profile.equipped).trait
    pending = {"definition":d,"hit_at":clock + float(d.windup)}
    busy_until = clock + float(d.windup) + float(d.recovery)
    events.append({"type":"hero_action","id":id,"started_at":clock,"windup":d.windup,"recovery":d.recovery,"animation":d.get("animation",id),"action_id":d.action_id,"actor_id":actor_id,"target_id":d.target_id,"contacts":d.get("contacts",1)})
    if d.effect == "shield":
        hero_status.apply("shield", clock, float(d.duration), {"amount":int(player_max_hp * float(d.absorb_fraction)),"counter":true,"counter_damage":int(hero_damage() * float(d.counter_multiplier))})
        pending.clear()
        events.append({"type":"shield","id":id})
    return true

func tick(delta: float) -> void:
    if delta <= 0:
        return
    accumulator += delta
    while accumulator + 0.000001 >= STEP:
        accumulator -= STEP
        _step()

func _step() -> void:
    if outcome in ["victory","defeat"]:
        accumulator = 0
        return
    clock += STEP
    if outcome == "breathe":
        if clock + 0.00001 >= transition_at:
            encounter += 1
            _spawn()
            events.append({"type":"spawn","id":enemy_definition.id})
        return
    if not pending.is_empty() and clock + 0.00001 >= float(pending.hit_at):
        var d: Dictionary = pending.definition
        if d.effect=="chain":_resolve_chain_contact()
        else:
            pending = {}
            _resolve(d)
    if outcome != "fighting":
        return
    for damage in enemy_status.take_ticks("burn",clock):
        _damage_enemy(int(damage),"burn",false)
        if outcome != "fighting":
            return
    enemy_status.expire(clock)
    hero_status.expire(clock)
    _update_companion()
    if outcome!="fighting":return
    if enemy_definition.kind=="boss":
        if clock<boss.break_until:return
        if not boss.enraged and enemy_hp<=enemy_max_hp*.5:
            boss.enraged=true;events.append({"type":"boss_phase","id":"enrage"})
    for event in behavior.update(clock):
        if event.type == "telegraph":
            events.append(event)
        else:
            _enemy_strike(float(event.multiplier)*(1.2 if boss.enraged else 1.0), bool(event.heavy))
        if outcome != "fighting":
            break

func _resolve_chain_contact() -> void:
    var d:Dictionary=pending.definition
    var index=int(pending.get("contact",0))
    if not d.has("parts"):
        hit_count+=1
        d.critical=d.weapon_trait=="critical" and hit_count%4==0
        var multiplier=float(d.multiplier)*(1.6 if d.critical else 1.0)
        if enemy_status.has("mark",clock):multiplier*=float(enemy_status.active.mark.get("amplify",1.35))
        d.parts=Tap.split_damage(maxi(int(d.contacts),int(round(int(d.base_damage)*multiplier))),int(d.contacts))
        d.actual_total=0
    var before=enemy_hp
    _damage_enemy(int(d.parts[index]),"chain",bool(d.critical),d)
    d.actual_total+=before-enemy_hp
    var finished=index+1>=int(d.contacts) or outcome!="fighting"
    tap.contact(clock,finished)
    events.append({"type":"chain_contact","step":d.chain_step,"index":index,"contacts":d.contacts,"critical":d.critical,"action_id":d.action_id})
    if finished:
        pending.clear()
        momentum=minf(100,momentum+9+(5 if d.weapon_trait=="momentum" else 0));rage=minf(100,rage+7)
        if d.weapon_trait=="lifesteal":
            var healed=mini(player_max_hp-player_hp,maxi(1,int(int(d.actual_total)*.12)))
            player_hp+=healed
            if healed>0:events.append({"type":"heal","amount":healed})
        if outcome=="fighting":
            if d.weapon_trait=="burn" and not enemy_status.has("burn",clock):_burn(2,1,maxi(1,int(int(d.base_damage)*.18)))
            if d.weapon_trait=="guard" and not hero_status.has("shield",clock):hero_status.apply("guard",clock,5,{"amount":mini(15,int(hero_status.active.get("guard",{}).get("amount",0))+3)})
    else:
        pending={"definition":d,"contact":index+1,"hit_at":float(pending.hit_at)+float(d.spacing)}

func _resolve(d: Dictionary) -> void:
    if player_hp <= 0 or enemy_hp <= 0:
        return
    var weapon_trait: String = str(d.get("weapon_trait",Equipment.definition(profile.equipped).trait))
    var base_damage: int = int(d.get("base_damage",hero_damage()))
    var critical = false
    if d.effect == "direct":
        hit_count += 1
        critical = weapon_trait == "critical" and hit_count % 4 == 0
    var multiplier = float(d.multiplier) * (1.6 if critical else 1.0)
    if enemy_status.has("mark",clock):
        multiplier *= float(enemy_status.active.mark.get("amplify",1.35))
    var damage = maxi(1,int(round(base_damage * multiplier)))
    var actual_damage = mini(enemy_hp,damage)
    _damage_enemy(damage,str(d.vfx),critical,d)
    if d.id!="ultimate":tap.charge=mini(100,tap.charge+int(Tap.catalog().charge_per_skill))
    momentum = minf(100,momentum + 9 + (5 if weapon_trait == "momentum" else 0))
    rage = minf(100,rage + 7)
    if weapon_trait == "lifesteal":
        var amount = mini(player_max_hp-player_hp,maxi(1,int(actual_damage * 0.12)))
        player_hp += amount
        if amount > 0:
            events.append({"type":"heal","amount":amount})
    if outcome != "fighting":
        return
    if d.effect == "mark":
        enemy_status.apply("mark",clock,float(d.duration),{"amplify":d.amplify})
        events.append({"type":"status","id":"mark"})
    if d.effect == "burn":
        _burn(float(d.duration),float(d.tick_interval),maxi(1,int(base_damage * float(d.tick_multiplier))))
    elif weapon_trait == "burn" and d.effect == "direct":
        if not enemy_status.has("burn",clock) or float(enemy_status.active.burn.damage) < base_damage * 0.4:
            _burn(2.0,1.0,maxi(1,int(base_damage*0.18)))
    if weapon_trait == "guard" and not hero_status.has("shield",clock):
        hero_status.apply("guard",clock,5.0,{"amount":mini(15,int(hero_status.active.get("guard",{}).get("amount",0))+3)})

func _burn(duration: float, interval: float, damage: int) -> void:
    var next_tick = clock + interval
    if enemy_status.has("burn",clock):
        if int(enemy_status.active.burn.damage) > damage:
            return
        next_tick = float(enemy_status.active.burn.next_tick)
    enemy_status.apply("burn",clock,duration,{"interval":interval,"next_tick":next_tick,"damage":damage})
    events.append({"type":"status","id":"burn"})

func _damage_enemy(amount: int, source: String, critical: bool, context: Dictionary={}) -> void:
    if enemy_hp <= 0 or outcome != "fighting":
        return
    if enemy_definition.kind=="boss" and clock<boss.break_until:amount=int(round(amount*1.25))
    var actual = mini(enemy_hp,maxi(1,amount))
    enemy_hp -= actual
    events.append({"type":"damage","amount":actual,"source":source,"critical":critical,"action_id":context.get("action_id",""),"actor_id":context.get("actor_id",actor_id),"target_id":run_id+":"+region+":"+str(encounter),"subhit":source=="chain","skill_rank":context.get("rank",1)})
    if enemy_hp>0 and enemy_definition.kind=="boss" and not context.is_empty() and source not in ["burn","counter","pet"]:
        if boss.contact(clock,1 if source=="chain" else 3):
            behavior.state="idle";behavior.second=false;behavior.deadline=boss.break_until+float(enemy_definition.interval)
            events.append({"type":"boss_phase","id":"break"})
    if enemy_hp == 0:
        pending.clear()
        enemy_status.active.clear()
        var before_unlocks=[Tap.unlocked(profile,2),Tap.unlocked(profile,4),Tap.ultimate_unlocked(profile)]
        var old_level = level
        var old_hero_level=hero_level
        var pet_id=str(profile.companions.active)
        var old_pet_level=Companions.level(profile,pet_id)
        var reward = Rewards.grant(profile,run_id+":"+str(encounter),enemy_definition,tier)
        if reward.granted:
            Roster.gain(profile,int(reward.xp));Companions.gain(profile,int(reward.xp))
            var stars=World.clear_stage(profile,region,encounter,float(player_hp)/player_max_hp)
            events.append({"type":"stage_clear","stars":stars,"region":region,"stage":encounter})
            if enemy_definition.kind=="boss":
                Quests.record(profile,"bosses")
                Chests.grant(profile,run_id+":"+region+":boss")
            events.append({"type":"reward","reward":reward})
            if hero_level>old_hero_level and hero_id!="realmwachter":events.append({"type":"hero_level_up","id":hero_id,"level":hero_level})
            if pet_id!="" and Companions.level(profile,pet_id)>old_pet_level:events.append({"type":"pet_level_up","id":pet_id,"level":Companions.level(profile,pet_id)})
            var after_unlocks=[Tap.unlocked(profile,2),Tap.unlocked(profile,4),Tap.ultimate_unlocked(profile)]
            for i in 3:
                if after_unlocks[i] and not before_unlocks[i]:events.append({"type":"combat_unlock","id":["x2","x4","ultimate"][i]})
        if level > old_level:
            events.append({"type":"level_up","level":level})
        profile.best_wave = maxi(int(profile.best_wave),wave + 1)
        player_hp = mini(player_max_hp,player_hp + int(player_max_hp * 0.12))
        outcome = "victory" if encounter == 4 else "breathe"
        transition_at = clock + 0.9
        events.append({"type":"enemy_defeated"})
        if outcome == "victory":
            events.append({"type":"victory"})

func _enemy_strike(multiplier: float, heavy: bool) -> void:
    var damage = maxi(1,int(round((float(enemy_definition.damage)+tier*1.5)*multiplier))-defense)
    var blocked = 0
    var counter = 0
    for id in ["shield","guard"]:
        if hero_status.has(id,clock):
            var s: Dictionary = hero_status.active[id]
            var absorb = mini(damage,int(s.amount))
            s.amount = int(s.amount) - absorb
            blocked += absorb
            damage -= absorb
            if bool(s.get("counter",false)):
                s.counter = false
                counter = int(s.get("counter_damage",0))
            if int(s.amount) <= 0:
                hero_status.active.erase(id)
    player_hp = maxi(0,player_hp-damage)
    rage = minf(100,rage+8)
    events.append({"type":"hero_hit","amount":damage,"blocked":blocked,"heavy":heavy})
    if player_hp <= 0:
        outcome = "defeat"
        pending.clear()
        tap.reset_chain()
        hero_status.active.clear()
        events.append({"type":"defeat"})
    else:
        if hero_id=="kaela" and blocked>0:
            var healing=mini(player_max_hp-player_hp,maxi(1,int(round(player_max_hp*.03))))
            if healing>0:player_hp+=healing;events.append({"type":"heal","amount":healing,"source":"rune_guard"})
        if counter>0:_damage_enemy(counter,"counter",false)

func _update_companion() -> void:
    if not Companions.ensure(profile):return
    var id=str(profile.companions.active)
    if id=="":return
    var d:Dictionary=Companions.catalog()[id]
    if not companion.pending.is_empty():
        if clock+.00001<float(companion.pending.hit_at):return
        var action=companion.pending.duplicate(true);companion.pending.clear()
        if id!=action.id:return
        if float(d.heal_fraction)>0:
            var amount=mini(player_max_hp-player_hp,int(action.amount))
            if amount>0:player_hp+=amount;events.append({"type":"heal","amount":amount,"source":"companion"})
        else:_damage_enemy(int(action.amount),"pet",false,{"action_id":action.action_id,"actor_id":"companion:"+id+":local"})
        events.append({"type":"companion_impact","id":id,"action_id":action.action_id});return
    if clock<companion.ready_at or (float(d.heal_fraction)>0 and player_hp>=player_max_hp):return
    companion.sequence+=1
    var amount=maxi(1,int(round((player_max_hp*float(d.heal_fraction) if float(d.heal_fraction)>0 else hero_damage()*float(d.attack_scale))*Companions.strength(profile,id))))
    var uid=run_id+":companion:"+id+":"+str(companion.sequence)
    companion.pending={"id":id,"hit_at":clock+float(d.windup),"amount":amount,"action_id":uid};companion.ready_at=clock+float(d.interval)
    events.append({"type":"companion_action","id":id,"windup":d.windup,"action_id":uid})

func _spawn() -> void:
    tap.reset_chain();boss.reset();companion.pending.clear()
    enemy_definition = World.encounter(region,encounter)
    enemy_max_hp = int(round(float(enemy_definition.hp)*(1.0 + tier * 0.12)))
    enemy_hp = enemy_max_hp
    outcome = "fighting"
    enemy_status.active.clear()
    pending.clear()
    behavior.configure(enemy_definition,clock)
    busy_until = clock

func restart() -> bool:
    if outcome not in ["victory", "defeat"]:
        return false
    var won = outcome == "victory"
    if won:
        tier = mini(100,tier+1)
    _reset_run(0)
    return true

func _reset_run(start: int) -> void:
    profile.run_serial = int(profile.run_serial)+1
    run_id = "run-%d" % int(profile.run_serial)
    profile.claims = {}
    encounter = start
    clock = 0
    accumulator = 0
    skills.ready_at.clear()
    tap=Tap.new();boss.reset();companion.reset();action_sequence=0
    hero_status.active.clear()
    momentum = 25
    rage = 0
    hit_count = 0
    _spawn()
    player_hp = player_max_hp
    events.clear()
    events.append({"type":"spawn","id":enemy_definition.id})

func drain_events() -> Array:
    var result = events
    events = []
    return result

func snapshot() -> Dictionary:
    return {"version":2,"profile":profile.duplicate(true),"checkpoint":{"region":region,"tier":tier,"encounter":encounter,"run_id":run_id,"clock":clock,"player_hp":player_hp,"enemy_hp":enemy_hp,"momentum":momentum,"rage":rage,"outcome":outcome,"busy_until":busy_until,"transition_at":transition_at,"hit_count":hit_count,"pending":pending.duplicate(true),"cooldowns":skills.snapshot(),"hero_status":hero_status.active.duplicate(true),"enemy_status":enemy_status.active.duplicate(true),"behavior":behavior.snapshot(),"tap_combat":tap.snapshot(),"boss_phase":boss.snapshot(),"action_sequence":action_sequence,"companion_runtime":companion.snapshot()}}
