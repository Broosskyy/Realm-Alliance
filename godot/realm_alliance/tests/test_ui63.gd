extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Layout=preload("res://scripts/combat_layout.gd")
const Modal=preload("res://scripts/ui/modal_dialog.gd")
const Session=preload("res://scripts/systems/combat_session.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false
    scene.audio.enabled=false
    scene.model=Session.new();scene.hud.model=scene.model
    scene._show_encounter();scene._sync_hero();scene._refresh()
    await process_frame
    check(Kit.box("panel")==Kit.box("panel"),"shared panel style is cached")
    check(Kit.box("panel") is StyleBoxTexture,"compact panels use actual texture assets")
    check(Kit.box("hero_ornate").texture!=Kit.box("panel").texture,"large hero card has its own material")
    check(scene.hud.toast is NinePatchRect,"live notification is a reusable nine-patch component")
    for id in ["skill0","skill1","locked","skill2"]:
        check(scene.hud.buttons[id] is RASkillOrb,"live action uses SkillOrb: "+id)
    scene._refresh();scene.hud._skill(0,Vector2.ZERO)
    check(scene.hud.buttons.skill0.cooldown==0,"initial orb has no fictitious cooldown")
    scene._on_skill(0);scene.hud._skill(0,Vector2.ZERO)
    check(scene.hud.buttons.skill0.cooldown>0,"orb reads actual skill runtime deadline")
    scene._on_hud_action("Wesen")
    for id in scene.model.Equipment.IDS:
        var b=scene.hud.buttons["equip_"+id]
        check(b is RAEquipmentSlot and b.paint_card,"real equipment slot component: "+id)
        check(b.owned==scene.model.profile.inventory.has(id),"slot ownership reflects saved inventory: "+id)
    scene._on_hud_action("Beute")
    check(not scene.hud.buttons.equip_steel.paint_card,"loot overlay cannot cover real item text")
    scene._on_hud_action("Mehr");scene.hud.notify("Prüfung","Nachricht",3);scene.hud.update_buttons()
    check(scene.hud.toast.visible and scene.hud.toast.title_label.text.contains("Prüfung"),"notification receives live event text")
    var modal=Modal.new();scene.add_child(modal)
    check(modal.theme.get_stylebox("panel","AcceptDialog") is StyleBoxTexture,"import modal uses shared fantasy theme")
    modal.queue_free()
    for v in [Vector2(360,800),Vector2(720,1280),Vector2(720,1560),Vector2(1280,720)]:
        var m=Layout.solve(v)
        var ratio=(m.stage_origin.y-m.hud_bottom)/(m.controls_top-m.hud_bottom)
        check(absf(ratio-.84)<.001,"locked shared ground line: "+str(v))
        for id in ["skill0","skill1","locked","skill2"]:
            var b=scene.hud.buttons[id]
            check(b.size.x*m.ui_scale>=44,"skill touch target at "+str(v))
    for role in ["panel","boss","hero","primary","secondary","slot"]:
        check(Kit.TEXTURES[role]!=null,"catalogued material loads: "+role)
    scene.queue_free();await process_frame
    print("UI 6.3: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
