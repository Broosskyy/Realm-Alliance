extends Node
# Test-only browser adapter. Excluded from every normal export preset.
var scene
var callback
func _ready():
    Engine.max_fps=20
    scene=preload("res://scenes/main.tscn").instantiate();add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene._qa_active=true
    scene.model=preload("res://scripts/systems/combat_session.gd").new()
    var m=scene.model
    scene.hud.model=m;scene._sync_hero();scene._show_encounter();scene._layout();scene._refresh()
    if OS.has_feature("web"):
        callback=JavaScriptBridge.create_callback(command)
        JavaScriptBridge.get_interface("window").realmQA=callback
func command(args:Array):
    var parts=str(args[0]).split(":",true,1)
    var kind=parts[0];var value=parts[1] if parts.size()>1 else ""
    match kind:
        "impact":
            scene._on_hud_action("Kampf");scene.vfx.clear()
            var fx=scene.vfx.emit_effect("blade_impact",scene.enemy.position+Vector2(-40,-155),145,.4)
            fx.age=float(value);fx.set_process(false);fx.queue_redraw()
        "reveal":
            for node in scene.find_children("ChestRevealStage","Control",true,false):node.age=float(value);node.set_process(false);node.queue_redraw()
        "track":
            var spec=value.split("@")
            scene._on_hud_action("Kampf");scene.hero.revive();scene.hero.external_clock=true
            scene.hero.play_action(spec[0],.28,.38,0)
            scene.hero.sync_clock(float(spec[1]))
        "tab":scene._on_hud_action(value)
        "gear":scene.model.change_gear(value);scene._sync_hero();scene._refresh()
        "hero":scene.model.select_hero(value);scene._sync_hero();scene._refresh()
        "pose":scene.hud.preview.set_process(false);scene.hud.preview._set_pose(value)
        "activity":scene.model.start_activity(value);scene._show_encounter();scene._sync_hero();scene._on_hud_action("Kampf")
        "enemy":scene.model.start_stage("glutkern" if value=="cinder_colossus" else "wolkgarten",4 if value in ["golem","cinder_colossus"] else 2);scene._show_encounter();scene._sync_hero();scene._on_hud_action("Kampf")
        "open":scene._on_hud_action(value)
        "attack":scene._on_hud_action("Kampf");scene.set_process(true);scene._on_tap()
        "pause":scene.set_process(false)
        "fixture709":
            if value=="legacy":scene.model=preload("res://scripts/systems/combat_session.gd").new(preload("res://tests/legacy_fixture709.gd").guardian());scene.model.profile.xp=440
            if value=="rich":
                scene.model.gold=2000;scene.model.profile.shards=100;scene.model.profile.xp=440
            if value=="victory":
                scene.model.World.clear_stage(scene.model.profile,"wolkgarten",4,1)
                scene.model.Chests.grant(scene.model.profile,"qa709-boss")
                scene.model.outcome="victory";scene.model.region="wolkgarten";scene.model.encounter=4
                scene.model.events=[{"type":"level_up","level":5},{"type":"victory"}]
                scene._consume_events()
            scene.hud.model=scene.model;scene._sync_hero();scene._show_encounter();scene._refresh()
        "fixture":
            if value=="mastery":
                scene.model.gold=100000;scene.model.profile.shards=10000;scene.model.profile.economy.materials.forge_dust=10000;scene.model.profile.economy.materials.ember_core=10000
                for id in scene.model.Roster.playable_catalog():scene.model.profile.hero_roster.owned[id].xp=100000
                for region in scene.model.World.IDS:
                    for i in 5:scene.model.World.clear_stage(scene.model.profile,region,i,1)
            elif value=="bestiary":
                for i in 5:scene.model.Bestiary.record(scene.model.profile,"cloud_slime")
            elif value=="loot":
                scene.model.profile.economy.materials.forge_dust=40;scene.model.profile.economy.materials.ember_core=6;scene.model.profile.economy.materials.harvest_token=20
                scene.model.Chests.grant(scene.model.profile,"review706-chest")
            scene._refresh()
        "close":
            for child in scene.get_children():
                if child is Window:child.queue_free()
    await get_tree().process_frame
    await get_tree().process_frame
    var state={"tab":scene.active_tab,"profile":scene.model.profile,"scrolls":[],"buttons":[],"windows":[],"fields":[],"run_id":scene.model.run_id,"enemy_hp":scene.model.enemy_hp,"collection_detail":scene.hud.collection_page.detail,"collection_category":scene.hud.collection_page.category,"viewport":[scene.get_viewport_rect().size.x,scene.get_viewport_rect().size.y]}
    for scroll in get_tree().get_nodes_in_group("realm_touch_scroll"):
        if scroll.is_visible_in_tree():state.scrolls.append({"name":scroll.name,"offset":scroll.scroll_vertical,"max":scroll.get_v_scroll_bar().max_value,"page":scroll.get_v_scroll_bar().page,"x":scroll.get_screen_transform().origin.x,"y":scroll.get_screen_transform().origin.y,"width":scroll.size.x*scroll.get_screen_transform().get_scale().x,"height":scroll.size.y*scroll.get_screen_transform().get_scale().y})
    for child in scene.get_children():
        if child is Window and child.visible:state.windows.append({"title":child.title,"x":child.position.x,"y":child.position.y,"width":child.size.x,"height":child.size.y})
    _buttons(scene,state.buttons)
    for field in scene.find_children("*","LineEdit",true,false):
        if field.is_visible_in_tree():state.fields.append({"name":field.name,"text":"" if field.secret else field.text,"secret":field.secret,"x":field.get_screen_transform().origin.x,"y":field.get_screen_transform().origin.y,"width":field.size.x,"height":field.size.y,"focused":field.has_focus()})
    state.actual_hero=scene.hero.hero_id
    state.banners=scene.hud.find_children("ProgressCelebration","Control",true,false).size()
    state.hero_rigs=[]
    for rig in scene.find_children("*","Node2D",true,false):
        if rig is RAProductionHero and rig.is_visible_in_tree():
            state.hero_rigs.append({"name":rig.name,"hero":rig.hero_id,"wings":rig.attachments.visible_items.get("wings",""),"wings_visible":rig.attachments.wings.visible,"back_layer":rig.z_index+rig.attachments.wing_mount.z_index})
    state.preview={}
    for actor in scene.hud.collection_page.find_children("*","Node2D",true,false):
        if actor is RAProductionHero:state.preview={"kind":"hero","busy":actor._busy,"pose":actor._pose}
        elif actor is RACompanionVisual:state.preview={"kind":"pet","evolved":actor.preview_evolved,"pose":actor.sprite.texture.resource_path}
    state.window_labels=[]
    for child in scene.get_children():
        if child is Window and child.visible:
            for label in child.find_children("*","Label",true,false):state.window_labels.append(label.text)
    state.online={"connected":scene.realm_online.connected,"busy":scene.realm_online.busy,"message":scene.realm_online.message,"state":scene.realm_online.state,"result":scene.realm_online.last_result}
    state.community_tab=""
    for child in scene.get_children():
        if child is Window and child.visible and child.title=="Gemeinschaft":state.community_tab=child.selected
    JavaScriptBridge.eval("window.realmQAState="+JSON.stringify(state),true)

func _buttons(node:Node,out:Array) -> void:
    if node is Button and node.is_visible_in_tree() and _unclipped(node):
        var t=node.get_screen_transform();var extent=node.size*t.get_scale()
        out.append({"name":node.name,"text":node.text,"disabled":node.disabled,"x":t.origin.x,"y":t.origin.y,"width":extent.x,"height":extent.y})
        if node is RAInventoryCard:out.back().item=node.item
    for child in node.get_children(true):_buttons(child,out)

func _unclipped(node:Control) -> bool:
    var transform=node.get_screen_transform()
    var center=transform.origin+node.size*transform.get_scale()*.5
    if not get_tree().root.get_visible_rect().has_point(center):return false
    var view=node.get_viewport()
    if view is Window and view!=get_tree().root and not Rect2(Vector2(view.position),Vector2(view.size)).has_point(center):return false
    var parent=node.get_parent()
    while parent is Control:
        var clip=parent.get_screen_transform()
        if parent.clip_contents and not Rect2(clip.origin,parent.size*clip.get_scale()).has_point(center):return false
        parent=parent.get_parent()
    return true
