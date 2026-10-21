extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const QA=preload("res://scripts/systems/admin_qa.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error(label)
func settle():
    for i in 6:await process_frame
func _initialize():call_deferred("run")
func run():
    var scene=Scene.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model
    for op in ["gold","shards","level","world"]:QA.apply(scene.model,op)
    scene._refresh();scene._on_hud_action("Wesen")
    var page=scene.hud.collection_page;page.detail="realmwachter";page._reload();await settle()
    check(page.find_child("EquippedSlot_chest",true,false).get_meta("equipped_item")=="","empty chest slot contains no sample armor")
    scene.model.change_gear("eclipse_plate","acquire");scene.model.change_gear("eclipse_plate");scene._refresh();await settle()
    check(page.find_child("EquippedSlot_chest",true,false).get_meta("equipped_item")=="eclipse_plate","slot follows equipped eclipse armor")
    scene.model.change_gear("chest","unequip");scene._refresh();await settle()
    check(page.find_child("EquippedSlot_chest",true,false).get_meta("equipped_item")=="","unequip clears illustrated slot")
    var run_id=scene.model.run_id;var hp=scene.model.enemy_hp
    for viewport in [Vector2i(320,568),Vector2i(390,844),Vector2i(430,932),Vector2i(1280,720)]:
        root.size=viewport;await settle();scene._layout()
        for kind in ["quests","talents","activities","hero_skill_0","equipment:head"]:
            scene._on_hud_action("Wesen" if kind.begins_with("hero_skill") or kind.begins_with("equipment:") else "Mehr")
            var profile=scene.model.profile.duplicate(true)
            scene._on_hud_action(kind);await settle()
            var window
            for node in scene.get_children():
                if node is Window and node.visible and not node.is_queued_for_deletion():window=node
            check(window!=null,"page opens "+kind)
            if not window:continue
            var area=window.get_parent().get_viewport().get_visible_rect().size
            check(window.position.x>=0 and window.position.y>=0 and window.position.x+window.size.x<=area.x+1 and window.position.y+window.size.y<=area.y+1,"page fits viewport "+kind+str(viewport))
            var back=window.find_child("SheetBack",true,false)
            check(back!=null and back.size.x>=88 and back.size.y>=88,"accessible back target "+kind)
            if back:back.pressed.emit()
            await settle()
            check(not is_instance_valid(window) or not window.visible,"back closes page "+kind)
            check(scene.model.profile==profile,"navigation does not spend resources "+kind)
    check(scene.model.run_id==run_id and scene.model.enemy_hp==hp,"navigation preserves current encounter")
    scene.queue_free();await settle();print("Mockup 705 reconstruction: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
