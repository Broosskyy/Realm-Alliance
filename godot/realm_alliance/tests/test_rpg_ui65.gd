extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const QuestDialog=preload("res://scripts/ui/quest_dialog.gd")
const WeaponDialog=preload("res://scripts/ui/weapon_dialog.gd")
const Card=preload("res://scripts/ui/inventory_card.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func descendants(node: Node) -> Array:
    var result=[]
    for c in node.get_children(true):result.append(c);result.append_array(descendants(c))
    return result
func button(node: Node,caption: String):
    for c in descendants(node):
        if c is Button and c.text==caption:return c
    return null
func dialog_of(scene,type_name: String):
    for c in scene.get_children():
        if c is Window and not c.is_queued_for_deletion() and c.get_script() and c.get_script().resource_path.ends_with(type_name+".gd"):return c
    return null
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new();scene.hud.model=scene.model;scene._show_encounter();scene._refresh()
    scene._on_hud_action("Abenteuer");await process_frame
    var pages=scene.hud.rpg_pages
    check(pages.visible and is_instance_valid(pages.content),"real scrollable adventure page is integrated")
    var stages=[]
    for c in descendants(pages):
        if c is Button and c.name.begins_with("Stage_"):stages.append(c)
    check(stages.size()==5 and not stages[0].disabled and stages[1].disabled,"world page stage buttons reflect actual unlocks")
    button(pages,"Glutkern").pressed.emit();await process_frame
    check(pages.selected_region=="glutkern","map region selection is functional")
    var locked=pages.content.find_child("Stage_glutkern_0",true,false)
    check(locked!=null and locked.disabled,"locked region cannot launch through UI")
    for i in 5:scene.model.World.clear_stage(scene.model.profile,"wolkgarten",i,1)
    scene._refresh();await process_frame
    pages.content.find_child("Stage_glutkern_0",true,false).pressed.emit()
    var stage_dialog=dialog_of(scene,"modal_dialog");check(stage_dialog!=null,"stage entry is a concrete confirmed run change")
    stage_dialog.get_ok_button().pressed.emit();await process_frame
    check(scene.model.region=="glutkern" and scene.active_tab=="Kampf" and scene.enemy._visual=="boar","confirmed stage launches actual new enemy and returns to combat")
    check(scene.world_backdrop.texture.resource_path.ends_with("glutkern.webp"),"selected region changes actual combat backdrop")
    for pose in ["idle","attack","hit","defeated"]:
        var texture:Texture2D=scene.enemy._frames[pose];var image=texture.get_image()
        check(image.get_size()==Vector2i(512,512) and image.get_format()==Image.FORMAT_RGBA8,"separate normalized alpha enemy pose "+pose)
    check(scene.enemy._ground==Vector2(256,480),"boar uses authored feet pivot")
    scene._on_hud_action("Beute");await process_frame
    var cards=[]
    for c in descendants(pages):
        if c is Card:cards.append(c)
    check(cards.size()==1 and cards[0].item.id=="steel","inventory grid displays exact starter ownership")
    cards[0].pressed.emit();var weapon=dialog_of(scene,"weapon_dialog")
    check(weapon!=null and weapon.get_ok_button().disabled,"owned equipped weapon has real detail/compare dialog")
    weapon.get_cancel_button().pressed.emit();await process_frame
    scene.model.gold=2000;scene.model.profile.shards=100;scene.model.profile.xp=1000
    scene.model.profile.kills=5;scene.model.Quests.record(scene.model.profile,"skills")
    scene._on_hud_action("Mehr");scene.hud.buttons.quests.pressed.emit()
    var quests=dialog_of(scene,"quest_dialog")
    check(quests!=null and quests.title=="Aufgaben","More opens real quest UI")
    var claim=button(quests,"Belohnung abholen")
    check(claim!=null and not claim.disabled,"actual kill objective is claimable")
    var gold=scene.model.gold;claim.pressed.emit();await process_frame
    check(scene.model.gold==gold+40 and scene.model.profile.quests.claimed.has("first_five"),"native quest claim gives actual reward once")
    scene.hud.buttons.quests.pressed.emit();quests=dialog_of(scene,"quest_dialog")
    check(button(quests,"Abgeholt").disabled,"claimed objective cannot be collected twice")
    quests.get_ok_button().pressed.emit();await process_frame
    scene._on_hud_action("Wesen");scene.hud.buttons.hero_skill_0.pressed.emit()
    var skill=dialog_of(scene,"modal_dialog");var improve=button(skill,"Skill +1")
    check(improve!=null and not improve.disabled,"native skill upgrade validates actual rank/currency")
    gold=scene.model.gold
    if improve:improve.pressed.emit()
    else:quit(1);return
    await process_frame
    check(scene.model.Advancement.rank(scene.model.profile,"sky_blade")==2 and scene.model.gold==gold-30,"native skill upgrade changes saved runtime definition")
    scene.hud.buttons.talents.pressed.emit();var talents=dialog_of(scene,"talent_dialog")
    var hp=scene.model.player_max_hp;talents.find_child("Train_vitality",true,false).pressed.emit();await process_frame
    check(scene.model.player_max_hp==hp+8,"native talent changes real HP")
    scene.model.Chests.grant(scene.model.profile,"ui-boss-proof")
    scene._on_hud_action("Beute");scene._open_inventory_item("item:chest:boss_chest")
    var chest=dialog_of(scene,"modal_dialog");chest.get_ok_button().pressed.emit();await process_frame
    check(scene.model.profile.chests.opened.has("ui-boss-proof") and scene.model.profile.chests.sealed.is_empty(),"native chest consumes a genuine saved entry once")
    var reveal=dialog_of(scene,"reward_dialog")
    check(reveal!=null and reveal.title=="Wächtertruhe geöffnet","actual chest reward has a native reveal")
    if reveal:reveal.get_ok_button().pressed.emit()
    await process_frame
    for v in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout()
        scene._on_hud_action("Wesen");scene._refresh();await process_frame
        var physical_scale=root.get_final_transform().get_scale().x*scene.hud.scale.x
        check(scene.hud.buttons.talents.size.x*physical_scale>=44 and scene.hud.buttons.talents.size.y*physical_scale>=44,"talent target remains mobile-sized "+str(v))
        var slots=["gear_astral_plate","gear_eclipse_plate","gear_sentinel_circlet","gear_sky_wings","evolve","talents"]
        var overlap=false
        for i in slots.size():
            for j in range(i+1,slots.size()):
                var a=scene.hud.buttons[slots[i]];var b=scene.hud.buttons[slots[j]]
                if Rect2(a.position,a.size).intersects(Rect2(b.position,b.size)):overlap=true
        check(not overlap,"hero equipment and talent controls cannot overlap "+str(v))
        for tab in ["Abenteuer","Beute"]:
            scene._on_hud_action(tab);scene._refresh();await process_frame
            var scale=root.get_final_transform().get_scale().x*scene.hud.scale.x
            check(pages.position.y+pages.size.y<scene.hud.buttons["return"].position.y,"RPG viewport clears fixed navigation "+str(v)+tab)
            for c in descendants(pages):
                if c is Button:check(c.size.x*scale>=44 and c.size.y*scale>=44,"RPG target >=44 physical pixels "+str(v)+str(c.name))
        check(not scene._on_tap(),"RPG menus cannot cause combat hits "+str(v))
        scene._open_talents();var talent_window=dialog_of(scene,"talent_dialog");await process_frame
        var available=root.get_visible_rect().size
        check(talent_window.size.x<=available.x and talent_window.size.y<=available.y,"talent dialog stays within visible viewport "+str(v))
        talent_window.get_ok_button().pressed.emit();await process_frame
        var reward_window=load("res://scripts/ui/reward_dialog.gd").new();scene.add_child(reward_window)
        reward_window.configure({"item":{"id":"sky_shard","kind":"material","name":"Himmelssplitter","rarity":"common"},"gold":44,"shards":5},0)
        reward_window.popup_centered(Vector2i(620,460));await process_frame;await process_frame
        check(reward_window.size.x<=available.x and reward_window.size.y<=available.y,"reward dialog stays within visible viewport "+str(v))
        reward_window.get_ok_button().pressed.emit();await process_frame
    scene._on_hud_action("Kampf");scene.vfx.clear()
    var catalog=scene.model.enemy_definition
    scene.model.enemy_definition=scene.model.World.encounter("glutkern",4);scene.model.behavior.second=false
    check(scene.hud.enemy_attack_cue()=="Eruption","HUD names actual first boss strike")
    scene.model.behavior.second=true;check(scene.hud.enemy_attack_cue()=="Nachbeben","HUD distinguishes actual aftershock")
    scene.model.enemy_definition=catalog
    check(scene.hud.buttons.skill0.tooltip_text.contains("Stufe 2"),"skill tooltip uses actual saved rank")
    scene.vfx.enemy_warning(scene.model,"eruption",1.5,Vector2.ZERO)
    var warning
    for c in scene.vfx.get_children():
        if c is RASkillVFX:warning=c
    check(warning!=null and warning.model_deadline==scene.model.clock+1.5,"boss warning binds to actual model deadline")
    warning._process(1.0)
    check(warning.age==0,"hitstop/presentation frames cannot advance boss warning")
    scene.model.clock+=.75;scene.vfx.sync(scene.model,Vector2.ZERO,Vector2.ZERO)
    check(absf(warning.age-.75)<.0001,"boss warning follows simulation clock exactly")
    scene.queue_free();await process_frame
    print("RPG UI 6.5: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
