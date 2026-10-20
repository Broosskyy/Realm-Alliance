extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const Card=preload("res://scripts/ui/inventory_card.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func descendants(node: Node) -> Array:
    var result=[]
    for c in node.get_children():result.append(c);result.append_array(descendants(c))
    return result
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model;scene._sync_hero();scene._show_encounter();scene._refresh()
    var profile=JSON.stringify(scene.model.profile)
    for tab in ["Abenteuer","Beute","Wesen","Mehr","Kampf"]:
        scene._on_hud_action(tab);await process_frame
    check(JSON.stringify(scene.model.profile)==profile,"visiting pages never grants items, stars or currency")
    scene._on_hud_action("Abenteuer");await process_frame
    var pages=scene.hud.rpg_pages
    var map
    for c in descendants(pages):
        if c is RAWorldMap:map=c
    check(map!=null,"actual world map component is integrated")
    var nodes=[]
    for i in 5:nodes.append(map.find_child("Stage_wolkgarten_"+str(i),true,false))
    check(not nodes[0].disabled,"first stage selectable")
    for i in range(1,5):check(nodes[i].disabled,"unearned stage locked "+str(i))
    for i in nodes.size():
        for j in range(i+1,nodes.size()):check(not Rect2(nodes[i].position,nodes[i].size).intersects(Rect2(nodes[j].position,nodes[j].size)),"stage nodes do not overlap")
    var before=scene.model.snapshot()
    nodes[0].pressed.emit();await process_frame
    check(scene.model.snapshot()==before,"stage selection cannot restart run before confirmation")
    for c in scene.get_children():
        if c is Window:c.queue_free()
    await process_frame
    scene._on_hud_action("Beute");await process_frame
    var cards=[]
    for c in descendants(pages):
        if c is Card:cards.append(c)
        if c is GridContainer:check(c.columns==3,"readable three-column inventory retained from 709")
    check(cards.size()==1 and cards[0].item.id=="steel","only actual starter inventory is shown")
    scene._on_hud_action("Wesen");await process_frame
    var key=scene.hud._preview_key
    scene.hud.update_buttons();check(scene.hud._preview_key==key,"appearance cache stable")
    scene.model.profile.look="astral";scene.hud.update_buttons()
    check(scene.hud._preview_key!=key and scene.hud.preview._look=="astral","cosmetic changes invalidate cache")
    scene.hud.effect_level=2;scene._on_hud_action("Mehr");await process_frame
    check(scene.hud._veil.modulate.a==0,"effects off skips menu transition")
    scene.hud.buttons.mail.pressed.emit();await process_frame
    var actual_quests=false
    for c in scene.get_children():
        if c is RAQuestDialog:actual_quests=true;c.queue_free()
    check(actual_quests,"header utility opens actual quests")
    for v in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout();scene._on_hud_action("Beute");await process_frame
        var scale=root.get_final_transform().get_scale().x*scene.hud.scale.x
        for c in descendants(pages):
            if c is Card:check(c.size.x*scale>=44 and c.size.y*scale>=44,"inventory target >=44 pixels "+str(v))
    scene.queue_free();await process_frame
    print("Master UI 6.5.1: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
