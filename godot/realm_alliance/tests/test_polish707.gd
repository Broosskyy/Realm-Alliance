extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Preview=preload("res://scripts/systems/equipment_preview707.gd")
const Scene=preload("res://scenes/main.tscn")
const Effects=preload("res://scripts/presentation/combat_vfx_controller.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func run() -> void:
    var model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());model.gold=100000;model.profile.shards=1000
    for id in model.Equipment.IDS:
        for level in [1,2,3,19,20]:
            model.profile.inventory[id]={"level":level}
            var before=JSON.stringify(model.profile)
            var quote=Preview.weapon(model.profile,id)
            check(JSON.stringify(model.profile)==before,"weapon preview is pure "+id+str(level))
            var copy=model.profile.duplicate(true);var gold=int(copy.gold);var shards=int(copy.shards)
            var result=model.Equipment.upgrade_item(copy,id)
            check(result==(level<20),"weapon cap "+id+str(level))
            check(model.Equipment.item_damage(copy,id)==int(quote.next),"weapon next value matches actual upgrade "+id+str(level))
            if result:check(gold-int(copy.gold)==int(quote.cost.gold) and shards-int(copy.shards)==int(quote.cost.shards),"exact quoted weapon price "+id+str(level))
    for id in model.HeroEquipment.IDS:
        for level in [1,9,10]:
            model.profile.hero_equipment.owned[id]={"level":level}
            var before=JSON.stringify(model.profile);var quote=Preview.gear(model.profile,id)
            check(JSON.stringify(model.profile)==before,"gear preview is pure "+id+str(level))
            var copy=model.profile.duplicate(true);var result=model.HeroEquipment.upgrade(copy,id)
            check(result==(level<model.HeroEquipment.max_level(id)),"gear cap "+id+str(level))
            check(model.HeroEquipment.item_stats(copy,id)==quote.next,"gear next values match actual upgrade "+id+str(level))
    model.profile.inventory.steel.level=3;model.gold=53;model.profile.shards=0
    check(not Preview.weapon(model.profile,"steel").affordable,"insufficient gold and shards rejected")
    model.gold=54;model.profile.shards=1
    check(Preview.weapon(model.profile,"steel").affordable,"exact threshold accepted")
    var fx=Effects.new();root.add_child(fx)
    var impact=fx.emit_effect("blade_impact",Vector2.ZERO,100,.4)
    for i in 4:
        impact.age=i*.1+.001;check(impact.frame_index()==i,"animation frame "+str(i))
        check(impact.frames[i].get_size()==Vector2(512,512),"shared square atlas "+str(i))
    impact.age=99;check(impact.frame_index()==3,"clamped final frame")
    fx.intensity=0;check(fx.emit_effect("blade_impact",Vector2.ZERO)==null,"reduced effects suppress new animation")
    fx.queue_free()
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model;scene._on_hud_action("Wesen");await process_frame
    var page=scene.hud.collection_page;page.category="Helden";page.detail="realmwachter";page._reload();await process_frame
    var before=JSON.stringify(scene.model.snapshot());page.find_child("HeroPreviewAttack",true,false).pressed.emit()
    var heroes=page.find_children("*","Node2D",true,false);var busy=false
    for node in heroes:
        if node is RAProductionHero:busy=node._busy
    check(busy,"hero preview plays an attack")
    check(JSON.stringify(scene.model.snapshot())==before,"hero preview leaves encounter and profile untouched")
    page.category="Begleiter"
    for id in scene.model.Companions.catalog():
        page.detail=id;page._reload();await process_frame
        var pet=page.find_child("CompanionPreview",true,false)
        before=JSON.stringify(scene.model.snapshot())
        page.find_child("CompanionPreviewCast",true,false).pressed.emit();pet._process(.5)
        check(pet.sprite.texture.resource_path.ends_with("base_cast.png"),"locked companion can preview cast "+id)
        page.find_child("CompanionPreviewForm",true,false).pressed.emit()
        check(pet.preview_evolved and pet.sprite.texture.resource_path.ends_with("evolved_cast.png"),"evolved cast preview "+id)
        page.find_child("CompanionPreviewForm",true,false).pressed.emit()
        check(not pet.preview_evolved,"return to base form "+id)
        check(JSON.stringify(scene.model.snapshot())==before,"pet preview cannot acquire/evolve/equip "+id)
    var damage={"action_id":"707-chain","subhit":true,"amount":7,"critical":false,"source":"chain"}
    before=JSON.stringify(scene.model.snapshot())
    for i in 4:scene._damage_popup(damage)
    var numbers=[]
    for child in scene.stage.get_children():
        if child is Label and child.has_meta("damage_action"):numbers.append(child)
    check(numbers.size()==1 and numbers[0].text=="4 TREFFER\n28","same chain is summed into one readable number")
    damage.action_id="707-next";scene._damage_popup(damage)
    check(JSON.stringify(scene.model.snapshot())==before,"number aggregation changes no damage or profile state")
    scene.model.gold=1000
    for id in scene.model.Equipment.IDS:scene.model.profile.inventory[id]={"level":1}
    scene._open_gear_slot("weapon")
    for i in 4:await process_frame
    var equipment
    for child in scene.get_children():
        if child is Window and child.title=="Ausrüstung":equipment=child
    equipment.scroll.scroll_vertical=64
    await process_frame
    var offset=equipment.scroll.scroll_vertical
    print("707 scroll fixture: ",offset," / ",equipment.scroll.get_v_scroll_bar().max_value," page ",equipment.scroll.get_v_scroll_bar().page)
    var level=int(scene.model.profile.inventory.steel.level)
    for control in equipment.find_children("*","Button",true,false):
        if control.text.begins_with("Verbessern"):control.pressed.emit();break
    for i in 5:await process_frame
    check(int(scene.model.profile.inventory.steel.level)==level+1,"equipment control performs actual upgrade")
    check(offset>0 and equipment.scroll.scroll_vertical==offset,"upgrading preserves scroll position")
    scene.queue_free();await process_frame;await process_frame
    print("707 previews and polish: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
func _initialize() -> void:call_deferred("run")
