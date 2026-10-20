extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const QA=preload("res://scripts/systems/admin_qa.gd")
const Inventory=preload("res://scripts/systems/inventory_view.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error(label)
func _initialize():call_deferred("run")
func run():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());var book=m.Bestiary
    check(book.catalog().size()==15,"all world and event variants have stable entries")
    check(book.discovered(m.profile)==0,"no historical kills are invented")
    check(not book.can_claim(m.profile,"cloud_slime"),"unearned mastery cannot be claimed")
    m._damage_enemy(100000,"basic",false)
    check(book.count(m.profile,"cloud_slime")==1,"real awarded kill discovers current enemy")
    m._damage_enemy(100000,"basic",false)
    check(book.count(m.profile,"cloud_slime")==1,"duplicate death cannot count again")
    for i in 4:book.record(m.profile,"gold_vault:cloud_slime")
    check(book.count(m.profile,"cloud_slime")==5,"dungeon aliases count towards stable monster identity")
    var gold=m.gold;var shards=m.profile.shards
    check(book.claim(m.profile,"cloud_slime"),"first mastery can be claimed")
    check(m.gold==gold+20 and m.profile.shards==shards+1,"exact first reward")
    check(not book.claim(m.profile,"cloud_slime"),"same mastery cannot be claimed twice")
    var snapshot=m.snapshot();snapshot.profile.unrelated_future={"kept":true}
    var restored=Session.new(JSON.parse_string(JSON.stringify(snapshot)))
    check(not restored.read_only and restored.profile.unrelated_future.kept,"round trip preserves unknown profile fields")
    check(book.rank(restored.profile,"cloud_slime")==1 and not book.can_claim(restored.profile,"cloud_slime"),"reload does not reset receipts")
    for i in 25:book.record(restored.profile,"cloud_slime")
    check(book.claim(restored.profile,"cloud_slime") and book.claim(restored.profile,"cloud_slime"),"higher ranks unlock in order")
    check(book.rank(restored.profile,"cloud_slime")==3 and not book.claim(restored.profile,"cloud_slime"),"rank cap cannot be bypassed")
    var bad=restored.snapshot();bad.profile.bestiary.claimed.cloud_slime=4
    check(Session.new(bad).read_only,"future mastery ranks are protected")
    bad=restored.snapshot();bad.profile.bestiary.kills.cloud_slime=1
    check(Session.new(bad).read_only,"inconsistent claimed rewards are protected")
    bad=restored.snapshot();bad.profile.bestiary.kills.cloud_slime=1.5
    check(Session.new(bad).read_only,"fractional progress is rejected")
    bad=restored.snapshot();bad.profile.bestiary.kills.unknown_monster=3
    check(Session.new(bad).read_only,"unknown monster identity is protected")
    for id in book.catalog():check(ResourceLoader.exists(book.art(id)),"monster art available "+id)
    for op in ["gold","shards","level","world"]:QA.apply(restored,op)
    restored.unlock_hero("runenpaladin");restored.unlock_hero("schattenjager")
    for id in restored.Roster.playable_catalog():
        restored.select_hero(id);var before=restored.snapshot();var values=restored.hero_preview_stats(id)
        check(values.hp==restored.player_max_hp and values.attack==restored.hero_damage() and values.defense==restored.defense and values.power==restored.power,"preview matches actual hero stats "+id)
        check(restored.snapshot()==before,"preview has no combat or economy side effects "+id)
    var items=Inventory.items(restored.profile)
    for item in items:
        check(ResourceLoader.exists(item.icon),"owned item has loadable artwork "+item.id)
        if item.kind=="weapon" and item.active:check(not item.better,"equipped weapon is not its own upgrade")
    print("Bestiary and polish 706: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
