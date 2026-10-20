extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error(label)
func settle():
    for i in 5:await process_frame
func run():
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model;scene._refresh()
    var original=scene.model.profile.duplicate(true)
    for viewport in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=viewport;await settle();scene._layout()
        for tab in ["Wesen","Mehr"]:
            scene._on_hud_action(tab);await settle()
            if tab=="Wesen":scene.hud.collection_page.detail="realmwachter";scene.hud.collection_page._reload();await settle()
            var scroll=scene.hud.collection_page if tab=="Wesen" else scene.hud.shell_scroll
            check(scroll.visible,"scroll visible "+tab+str(viewport))
            var nav=scene.hud.buttons.Kampf.get_global_rect()
            scroll.scroll_vertical=10000;await settle()
            check(scroll.scroll_vertical>0 or scroll.get_v_scroll_bar().max_value<=scroll.get_v_scroll_bar().page,"overflow can scroll "+tab+str(viewport))
            check(scene.hud.buttons.Kampf.get_global_rect()==nav,"navigation stays fixed")
            var action=scene.hud.buttons.combat_options
            if tab=="Wesen":
                for node in scene.hud.collection_page.find_children("*","Button",true,false):
                    if node.text=="Skins":action=node
            var rect=action.get_global_rect();var visible_rect=scroll.get_global_rect()
            check(visible_rect.encloses(rect),"bottom action reachable "+tab+str(viewport)+str(rect)+str(visible_rect))
            check(not nav.intersects(rect),"bottom action clear of navigation")
        for kind in ["weapon","roster","talents","combat_options","journey"]:
            scene._on_hud_action("Wesen" if kind=="roster" else "Mehr");scene._on_hud_action("item:weapon:steel" if kind=="weapon" else kind);await settle()
            var dialogs=[]
            for child in scene.get_children():
                if child is Window and child.visible:dialogs.append(child)
            check(dialogs.size()==1,"dialog opened "+kind)
            for dialog in dialogs:
                check(dialog.size.x<=root.get_visible_rect().size.x and dialog.size.y<=root.get_visible_rect().size.y,"dialog fits "+kind+str(viewport)+str(dialog.size))
                var ok=dialog.get_ok_button()
                check(ok.position.y+ok.size.y<=dialog.size.y,"close action in dialog "+kind)
                dialog.queue_free()
            await settle()
    check(scene.model.profile==original,"navigation preserves progress")
    scene.queue_free();await settle();print("Scroll UI 7.0: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
func _initialize():call_deferred("run")
