extends "res://scripts/ui/game_sheet708.gd"
signal local_changed
signal restore_requested(save:Dictionary)
var model
var net
var selected="Konto"
var _poll=0.0
var nickname=""
var password=""
var server=""
var guild_name=""
var guild_tag=""
var _restore_pending:Dictionary={}
func configure(value,client) -> void:
    model=value;net=client;server=net.endpoint;setup_sheet("Gemeinschaft");net.changed.connect(_online_changed);net.backup_received.connect(_confirm_restore);_build()
func _online_changed() -> void:
    if selected=="Raid" and net.connected and is_instance_valid(scroll) and find_child("RaidAttack",true,false):
        var boss=net.state.boss
        find_child("SharedBossHP",true,false).value=boss.hp
        find_child("RaidSummary",true,false).text="%d / %d HP · %d Spieler anwesend"%[boss.hp,boss.max_hp,net.state.online.size()]
        find_child("RaidAttack",true,false).disabled=int(boss.hp)<=0 or (net.busy and net._route!="state")
        find_child("RaidContributors",true,false).text="\n".join(boss.contributions.map(func(item):return str(item.name)+" · %d Schaden"%item.damage))
        find_child("ConnectionMessage",true,false).text=net.message
    else:_build()
func _process(delta:float) -> void:
    if not visible or selected!="Raid" or not net.connected:return
    _poll+=delta
    if _poll>=2:_poll=0;net.refresh()
func _select(value:String) -> void:selected=value;scroll.scroll_vertical=0;_build()
func _build() -> void:
    var offset=clear_sheet()
    var hero=section(content,"hero")
    label_at(hero,"REALM ALLIANCE",25,Color("#ffd16b"))
    label_at(hero,net.message,22,Color("#7fdda5") if net.connected else Color("#a9bdd1")).name="ConnectionMessage"
    for names in [["Konto","Familie","Arena"],["Titel","Rangliste","Raid"]]:
        var row=HBoxContainer.new();row.add_theme_constant_override("separation",8);content.add_child(row)
        for caption in names:
            var b=button_at(row,caption,func():_select(caption));b.name="Community_"+caption;b.add_theme_stylebox_override("normal",Kit.box("primary" if selected==caption else "slot"))
    if selected=="Titel":_titles()
    elif selected=="Konto":_account()
    elif not net.connected:
        art_at(content,"res://assets/work708/ui/guild_banner.tres",200)
        label_at(content,"Gemeinsam durch die Reiche",28,Color("#ffd16b"))
        label_at(content,"Verbinde dein Konto für Familien, echte Arena-Duelle, Ranglisten und den gemeinsamen Himmelstitan.",23)
        button_at(content,"Zum Konto",func():_select("Konto")).name="CommunityConnect"
    elif selected=="Familie":_guild()
    elif selected=="Arena":_arena()
    elif selected=="Rangliste":_ranking()
    elif selected=="Raid":_raid()
    if net.connected and selected!="Raid":button_at(content,"Aktualisieren",func():net.refresh(),not net.busy).name="CommunityRefresh"
    finish_sheet(offset)
func _field(placeholder:String,value:String,fn:Callable,secret:bool=false) -> LineEdit:
    var input=field_at(content,placeholder,secret);input.text=value;input.text_changed.connect(fn);return input
func _account() -> void:
    if not net.connected:
        label_at(content,"Konto verbinden",27,Color("#ffd16b"))
        label_at(content,"Dein lokales Abenteuer bleibt ohne Anmeldung spielbar.",21,Color("#a9bdd1"))
        _field("Realm-Server · HTTPS oder lokaler Testserver",server,func(v):server=v).name="RealmServer"
        _field("Spielername",nickname,func(v):nickname=v).name="RealmUsername"
        _field("Passwort · mindestens 10 Zeichen",password,func(v):password=v,true).name="RealmPassword"
        var row=HBoxContainer.new();row.add_theme_constant_override("separation",12);content.add_child(row)
        button_at(row,"Anmelden",func():_auth("login"),not net.busy).name="RealmLogin"
        button_at(row,"Konto erstellen",func():_auth("register"),not net.busy).name="RealmRegister"
        button_at(content,"Als Gast verbinden",func():_auth("guest"),not net.busy).name="RealmGuest"
        label_at(content,"Das Webpaket enthält einen startbaren Realm-Dienst. In der APK kannst du die Adresse deines Realm-Servers verbinden.",20,Color("#a9bdd1"))
        return
    var me=net.state.me
    art_at(content,"res://assets/work708/ui/guild_banner.tres",150)
    label_at(content,str(me.name)+(" · Gast" if bool(me.guest) else " · Konto gesichert"),27,Color("#ffd16b"))
    label_at(content,"Online-Level %d · Arena %d · %d Raidpunkte"%[me.level,me.rating,me.raid_points],22)
    label_at(content,"Arena und Raid verwenden deinen Online-Fortschritt. Deine Abenteuersicherung bleibt privat.",21,Color("#a9bdd1"))
    if bool(me.guest):
        _field("Dauerhafter Spielername",nickname,func(v):nickname=v).name="RealmUsername"
        _field("Neues Passwort · mindestens 10 Zeichen",password,func(v):password=v,true).name="RealmPassword"
        button_at(content,"Gastkonto dauerhaft sichern",func():net.send("account/upgrade",{"name":nickname,"password":password});password="",not net.busy).name="RealmUpgradeGuest"
    var backup=net.state.get("backup",{"revision":0})
    label_at(content,"Cloud-Sicherung · Version %d"%int(backup.revision),24)
    button_at(content,"Abenteuer in der Cloud sichern",func():net.send("backup",{"revision":int(backup.revision),"save":model.snapshot()}),not net.busy and not model.read_only).name="RealmBackup"
    button_at(content,"Cloud-Sicherung laden",func():net.send("backup",{},HTTPClient.METHOD_GET),not net.busy and int(backup.revision)>0).name="RealmRestore"
    button_at(content,"Abmelden",func():net.send("logout"),not net.busy).name="RealmLogout"
    button_at(content,"Server wechseln",func():net.token="";net.state.clear();net.connected=false;net._store();_build(),not net.busy)
func _auth(kind:String) -> void:
    if not net.set_endpoint(server):return
    net.send(kind,{"name":nickname if not nickname.strip_edges().is_empty() else "Wanderer","password":password});password=""
func _guild() -> void:
    art_at(content,"res://assets/work708/ui/guild_banner.tres",150)
    label_at(content,"Familie / Gilde",28,Color("#ffd16b"))
    var guild=net.state.get("guild")
    if guild is Dictionary:
        label_at(content,"[%s] %s"%[guild.tag,guild.name],27)
        label_at(content,"%d / 30 Mitglieder"%guild.members.size(),22,Color("#a9bdd1"))
        for member in guild.members:label_at(content,str(member.name)+(" · Anführer" if member.role=="owner" else " · Mitglied"),22)
        button_at(content,"Zum gemeinsamen Boss",func():_select("Raid"))
        button_at(content,"Familie verlassen",func():_confirm_leave(),not net.busy).name="GuildLeave"
    else:
        _field("Familienname",guild_name,func(v):guild_name=v).name="GuildName"
        _field("Kürzel · 3–5 Zeichen",guild_tag,func(v):guild_tag=v).name="GuildTag"
        button_at(content,"Familie gründen",func():net.send("guild/create",{"name":guild_name,"tag":guild_tag}),not net.busy).name="GuildCreate"
        label_at(content,"Offene Familien",24,Color("#ffd16b"))
        if net.state.guilds.is_empty():label_at(content,"Noch keine Familie gegründet. Sei der Anfang.",22)
        for item in net.state.guilds:
            button_at(content,"[%s] %s · %d/30 · Beitreten"%[item.tag,item.name,item.members],func():net.send("guild/join",{"id":item.id}),not net.busy).name="GuildJoin_"+str(item.id)
func _confirm_leave() -> void:
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new();get_parent().add_child(dialog);dialog.title="Familie verlassen?";dialog.dialog_text="Du verlässt deine Familie. Die Führung geht an das nächste Mitglied über.";dialog.ok_button_text="Verlassen";dialog.cancel_button_text="Bleiben";dialog.confirmed.connect(func():net.send("guild/leave");dialog.queue_free());dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(620,400))
func _arena() -> void:
    art_at(content,"res://assets/work708/ui/ascension.tres",130)
    label_at(content,"Arena · PvP",28,Color("#ffd16b"))
    label_at(content,"Wertung %d · %d Siege · %d Niederlagen"%[net.state.me.rating,net.state.me.wins,net.state.me.losses],23)
    label_at(content,"Asynchrone automatische Duelle gegen echte Konten. Ein Duell alle 15 Sekunden; beide Wertungen werden aktualisiert.",21,Color("#a9bdd1"))
    if net.last_result.has("won"):
        label_at(content,("SIEG" if net.last_result.won else "NIEDERLAGE")+" · %+d Wertung"%net.last_result.rating_delta,27,Color("#ffd16b"))
        label_at(content,"%d Aktionen im Duell"%net.last_result.rounds.size(),21)
    if net.state.opponents.is_empty():label_at(content,"Noch kein anderer Spieler auf diesem Realm. Öffne eine zweite Spielsitzung oder lade Mitspieler auf denselben Realm ein.",22)
    for item in net.state.opponents:
        var card=section(content)
        label_at(card,"%s · Lv. %d · Wertung %d"%[item.name,item.level,item.rating],24)
        button_at(card,"Herausfordern",func():net.send("arena/fight",{"opponent":item.id,"nonce":net.nonce()}),not net.busy).name="ArenaFight_"+str(item.id)
func _ranking() -> void:
    art_at(content,"res://assets/work708/ui/title_crest.tres",130)
    label_at(content,"Realm-Rangliste",28,Color("#ffd16b"))
    label_at(content,"Nur echte Konten dieses Realms · Arena-Wertung / Raidpunkte",21,Color("#a9bdd1"))
    var number=0
    for item in net.state.leaderboard:
        number+=1;var row=section(content,"hero" if item.id==net.state.me.id else "slot")
        label_at(row,"%d · %s"%[number,item.name],25,Color("#ffd16b") if item.id==net.state.me.id else Kit.INK)
        label_at(row,"%d Wertung · %d Siege · %d Raidpunkte"%[item.rating,item.wins,item.raid_points],22)
func _raid() -> void:
    var boss=net.state.boss
    art_at(content,"res://assets/work704/golem/idle.png",250)
    label_at(content,"Himmelstitan · gemeinsamer Weltboss",27,Color("#ffd16b"))
    var bar=ProgressBar.new();bar.name="SharedBossHP";bar.custom_minimum_size.y=34;bar.max_value=boss.max_hp;bar.value=boss.hp;content.add_child(bar)
    label_at(content,"%d / %d HP · %d Spieler anwesend"%[boss.hp,boss.max_hp,net.state.online.size()],23).name="RaidSummary"
    button_at(content,"Gemeinsam angreifen",func():net.send("boss/attack",{"nonce":net.nonce()}),(not net.busy or net._route=="state") and int(boss.hp)>0).name="RaidAttack"
    label_at(content,"Alle verbundenen Spieler treffen denselben Boss. Bei Sieg erhalten Beteiligte einmalig 50 Raidpunkte. Der nächste Titan erscheint am folgenden UTC-Tag.",21,Color("#a9bdd1"))
    label_at(content,"\n".join(boss.contributions.map(func(item):return str(item.name)+" · %d Schaden"%item.damage)),22).name="RaidContributors"
func _titles() -> void:
    art_at(content,"res://assets/work708/ui/title_crest.tres",150)
    label_at(content,"Abenteuertitel",28,Color("#ffd16b"))
    for id in model.Titles.CATALOG:
        var item=model.Titles.CATALOG[id];var earned=model.Titles.earned(model.profile,id);var active=model.profile.titles.active==id;var box=section(content)
        label_at(box,item.name,25,Color(model.Economy.RARITIES[item.rarity].color));label_at(box,item.description,21)
        button_at(box,"Angelegt" if active else "Anlegen" if earned else "Noch nicht verdient",func():
            if not model.read_only and model.Titles.equip(model.profile,id):local_changed.emit();_build()
        ,earned and not active and not model.read_only).name="TitleEquip_"+id
    if net.connected:
        label_at(content,"Online-Titel",27,Color("#ffd16b"))
        for item in [["wanderer","Weltenwanderer",true],["duelist","Arena-Duellist · 5 Siege",int(net.state.me.wins)>=5],["titan_slayer","Titanenbezwinger · 50 Raidpunkte",int(net.state.me.raid_points)>=50]]:
            button_at(content,item[1],func():net.send("title",{"title":item[0]}),not net.busy and bool(item[2])).name="OnlineTitle_"+item[0]
func _confirm_restore(save:Dictionary) -> void:
    var parsed=preload("res://scripts/save_transfer.gd").parse_import(JSON.stringify(save))
    if parsed.is_empty():net.message="Cloud-Sicherung ist nicht kompatibel. Lokaler Stand bleibt erhalten.";_build();return
    _restore_pending=parsed
    var dialog=preload("res://scripts/ui/modal_dialog.gd").new();get_parent().add_child(dialog);dialog.title="Cloud-Abenteuer laden?";dialog.dialog_text="Ersetzt dein lokales Abenteuer durch die gewählte Cloud-Sicherung. Arena und Familie bleiben unverändert.";dialog.ok_button_text="Cloud-Stand laden";dialog.cancel_button_text="Behalten";dialog.confirmed.connect(func():restore_requested.emit(_restore_pending);dialog.queue_free());dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(620,440))
