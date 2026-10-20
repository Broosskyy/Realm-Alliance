extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Buffer=preload("res://scripts/combat_input_buffer.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:
    var model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());var input=Buffer.new()
    check(not input.drain(model) and model.pending.is_empty(),"empty buffer never auto-casts a skill")
    check(input.request(model,0)==Buffer.CAST,"free manual request executes immediately")
    check(input.request(model,0)==Buffer.REJECTED,"cooldown cannot be bypassed by buffering")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.profile.xp=80;model.momentum=100
    model.request_action()
    check(input.request(model,3)==Buffer.QUEUED,"manual defense buffers behind a normal attack")
    check(model.momentum==100 and not model.hero_status.has("shield",model.clock),"queueing spends nothing and does not apply shield early")
    check(model.skills.remaining("guardian_wall",model.clock)==0,"queueing starts no cooldown")
    check(not input.drain(model),"pending attack retains its impact timing")
    model.tick(.64)
    check(input.drain(model),"manual intent executes at the next available boundary")
    check(model.momentum==80 and model.hero_status.has("shield",model.clock),"accepted buffered skill applies real costs and state once")
    check(input.skill=="" and not input.drain(model),"accepted intent cannot execute twice")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.request_action();input.request(model,0)
    var original=model.enemy_hp;model.tick(.64);var after_basic=model.enemy_hp
    check(after_basic<original and input.drain(model),"normal hit resolves before buffered sword skill")
    model.tick(.27);check(model.enemy_hp==after_basic,"buffered skill cannot damage on button press")
    model.tick(.02);check(model.enemy_hp<after_basic,"buffered skill damage occurs at its actual contact time")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.request_action();input.request(model,0);model.tick(1.1)
    check(not input.drain(model) and input.skill=="","stale manual intents expire")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.request_action();input.request(model,0);input.clear();model.tick(.7)
    check(not input.drain(model),"menu/run/input cancellation cannot later spend a skill")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.momentum=100;model.request_action();input.request(model,0)
    check(input.request(model,1)==Buffer.QUEUED and input.skill=="arcane_eye","latest explicit selection replaces the single pending intent")
    model.momentum=0;model.tick(.7)
    check(not input.drain(model) and model.pending.is_empty(),"resources are revalidated before actual acceptance")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.request_action();input.request(model,0);model.outcome="defeat"
    check(not input.drain(model) and input.skill=="","defeat cancels pending intent")
    check(input.request(model,0)==Buffer.REJECTED,"defeat cannot enqueue")
    model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
    check(input.request(model,-1)==Buffer.REJECTED and input.request(model,4)==Buffer.REJECTED,"invalid skill IDs cannot enter the buffer")
    print("Combat input 6.4: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
