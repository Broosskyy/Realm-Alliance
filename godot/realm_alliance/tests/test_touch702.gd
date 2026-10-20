extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func settle():
    for i in 6:await process_frame
func gesture(viewport:Viewport,at:Vector2,delta:Vector2):
    var touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=true;touch.position=at;viewport.push_input(touch,true)
    await process_frame
    for i in range(1,9):
        var drag=InputEventScreenDrag.new();drag.index=0;drag.position=at+delta*i/8.0;drag.relative=delta/8.0;viewport.push_input(drag,true);await process_frame
    touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=false;touch.position=at+delta;viewport.push_input(touch,true);await settle()
func _initialize():call_deferred("run")
func run():
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model;scene._refresh()
    root.size=Vector2i(360,640);await settle();scene._layout()
    for tab in ["Wesen","Mehr"]:
        scene._on_hud_action(tab);await settle()
        var scroll=scene.hud.collection_page if tab=="Wesen" else scene.hud.shell_scroll
        scroll.scroll_vertical=0
        var before=scene.model.profile.duplicate(true)
        var at=scroll.get_global_rect().position+Vector2(160,scroll.size.y*.7)*scene.hud.scale
        await gesture(root,at,Vector2(0,-180))
        check(scroll.scroll_vertical>40 if scroll.get_v_scroll_bar().max_value>scroll.get_v_scroll_bar().page else scene.model.profile==before,"drag scrolls overflow or safely cancels taps in a fitting collection "+tab)
    scene._on_hud_action("Wesen");scene._on_hud_action("roster");await settle()
    var dialog
    for child in scene.get_children():
        if child is Window and child.visible:dialog=child
    check(dialog!=null,"collection sheet opens")
    if dialog:
        var scroll=dialog.tabs.get_child(0);scroll.scroll_vertical=0
        var rect=scroll.get_global_rect()
        var position=dialog.position
        await gesture(dialog,rect.position+Vector2(rect.size.x*.75,rect.size.y*.72),Vector2(0,-200))
        check(scroll.scroll_vertical>40,"touch drag scrolls collection sheet")
        check(dialog.borderless,"sheet has no draggable OS title bar")
        check(dialog.position==position,"content drag cannot move sheet")
        dialog.queue_free();await settle()
    scene.queue_free();await settle();print("Touch 7.0.2: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
