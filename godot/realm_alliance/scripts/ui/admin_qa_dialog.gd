extends "res://scripts/ui/modal_dialog.gd"
class_name RAAdminQADialog
signal operation_requested(id:String)
var summary:Label

func configure(session) -> void:
    title="QA-Testlabor · NUR DEBUG"
    dialog_text="TEMPORÄRER TESTSPIELSTAND\nAlle Änderungen gelten nur bis zum Verlassen des QA-Modus.\nDein normaler Spielstand bleibt unverändert."
    ok_button_text="Im Testspiel weitermachen"
    get_cancel_button().hide()
    confirmed.connect(queue_free)
    var scroll=preload("res://scripts/ui/touch_scroll.gd").new()
    scroll.custom_minimum_size=Vector2(540,570)
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    add_child(scroll)
    var content=VBoxContainer.new()
    content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation",12)
    scroll.add_child(content)
    summary=Label.new()
    summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size",20)
    content.add_child(summary)
    _section(content,"Ressourcen & Fortschritt")
    _button(content,"+10.000 Gold","gold")
    _button(content,"+500 Himmelssplitter","shards")
    _button(content,"Account + aktiver Held auf mindestens Level 12","level")
    _button(content,"Alle derzeitigen Regionen/Stages öffnen","world")
    _section(content,"Helden und Begleiter")
    _button(content,"Beide Begleiter freischalten","pets")
    _button(content,"Himmelsfuchs entwickeln","evolve")
    _button(content,"SHOWCASE: Realmwächter + Himmelsfuchs aktivieren","showcase")
    _section(content,"Kampftests")
    _button(content,"Direkt zum Wolkgarten-Boss","boss")
    _section(content,"Sitzung")
    _button(content,"QA verlassen · Originalstand wiederherstellen","leave")
    refresh(session)

func _section(parent:Control,label_text:String) -> void:
    var l=Label.new()
    l.text=label_text
    l.add_theme_font_size_override("font_size",24)
    l.add_theme_color_override("font_color",Color("#ffd16b"))
    parent.add_child(l)

func _button(parent:Control,caption:String,id:String) -> void:
    var b=Button.new()
    b.text=caption
    b.custom_minimum_size.y=76
    b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    b.pressed.connect(func():operation_requested.emit(id))
    parent.add_child(b)

func refresh(session) -> void:
    if summary==null or session==null:return
    summary.text="AKTIV: %s (Lv. %d) · Pet: %s\nGold: %d · Splitter: %d · Region: %s"%[
        session.hero_name,session.hero_level,
        str(session.Companions.catalog()[session.profile.companions.active].name) if session.profile.companions.active!="" else "keiner",
        session.gold,int(session.profile.shards),session.World.NAMES[session.region]]
