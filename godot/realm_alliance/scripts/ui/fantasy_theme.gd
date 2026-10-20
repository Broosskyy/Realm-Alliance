extends RefCounted
class_name RAFantasyTheme
const FONT=preload("res://assets/ui/work61/fonts/DejaVuSans.ttf")
const BOLD=preload("res://assets/ui/work61/fonts/DejaVuSans-Bold.ttf")
const INK=Color("#eaf3ff")
const CYAN=Color("#41cfff")
const TEXTURES={"panel":preload("res://assets/work708/ui/panel.svg"),"boss":preload("res://assets/ui/work651/boss.svg"),"hero":preload("res://assets/work708/ui/hero.svg"),"primary":preload("res://assets/work708/ui/primary.svg"),"secondary":preload("res://assets/work708/ui/secondary.svg"),"slot":preload("res://assets/work708/ui/slot.svg"),"hero_ornate":preload("res://assets/work708/ui/hero.svg"),"boss_ornate":preload("res://assets/ui/work651/boss.svg")}
static var _styles: Dictionary={}
static var _theme: Theme
static func box(role: String="panel") -> StyleBoxTexture:
    if not _styles.has(role):
        var s=StyleBoxTexture.new();s.texture=TEXTURES.get(role,TEXTURES.panel)
        for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
            s.set_texture_margin(side,20)
            s.set_content_margin(side,16)
        _styles[role]=s
    return _styles[role]
static func native_theme() -> Theme:
    if _theme:return _theme
    _theme=Theme.new();_theme.default_font=FONT;_theme.default_font_size=28
    _theme.set_stylebox("panel","AcceptDialog",box("panel"))
    var window_frame=box("hero").duplicate()
    window_frame.set_expand_margin(SIDE_TOP,36)
    _theme.set_stylebox("embedded_border","Window",window_frame)
    _theme.set_stylebox("embedded_unfocused_border","Window",window_frame)
    _theme.set_color("title_color","Window",INK)
    _theme.set_font("title_font","Window",BOLD)
    _theme.set_font_size("title_font_size","Window",28)
    for state in ["normal","hover","pressed","disabled","focus"]:_theme.set_stylebox(state,"Button",box("panel" if state in ["normal","disabled"] else "hero"))
    _theme.set_font("font","Button",BOLD)
    _theme.set_font_size("font_size","Button",24)
    _theme.set_constant("outline_size","Button",3)
    _theme.set_color("font_outline_color","Button",Color("#020815"))
    _theme.set_color("font_color","Label",INK);_theme.set_color("font_color","Button",INK)
    _theme.set_stylebox("normal","LineEdit",box("slot"));_theme.set_stylebox("focus","LineEdit",box("hero"))
    _theme.set_color("font_color","LineEdit",INK);_theme.set_color("caret_color","LineEdit",CYAN);_theme.set_color("selection_color","LineEdit",Color("#62348d"));_theme.set_font_size("font_size","LineEdit",24)
    _theme.set_stylebox("panel","TabContainer",box("panel"))
    for state in ["tab_selected","tab_unselected","tab_hovered","tab_disabled"]:
        var tab_style=box("primary" if state=="tab_selected" else "panel").duplicate()
        tab_style.set_content_margin(SIDE_TOP,32);tab_style.set_content_margin(SIDE_BOTTOM,32)
        tab_style.set_content_margin(SIDE_LEFT,18);tab_style.set_content_margin(SIDE_RIGHT,18)
        _theme.set_stylebox(state,"TabBar",tab_style)
        _theme.set_stylebox(state,"TabContainer",tab_style)
    _theme.set_font_size("font_size","TabBar",22)
    _theme.set_font_size("font_size","TabContainer",22)
    _theme.set_color("font_selected_color","TabBar",INK)
    _theme.set_constant("buttons_min_height","AcceptDialog",88)
    return _theme
