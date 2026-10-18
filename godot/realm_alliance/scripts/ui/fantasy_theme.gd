extends RefCounted
class_name RAFantasyTheme
const FONT=preload("res://assets/ui/work61/fonts/DejaVuSans.ttf")
const BOLD=preload("res://assets/ui/work61/fonts/DejaVuSans-Bold.ttf")
const INK=Color("#eaf3ff")
const CYAN=Color("#41cfff")
const TEXTURES={"panel":preload("res://assets/ui/work651/panel.svg"),"boss":preload("res://assets/ui/work651/boss.svg"),"hero":preload("res://assets/ui/work651/hero.svg"),"primary":preload("res://assets/ui/work651/primary.svg"),"secondary":preload("res://assets/ui/work651/secondary.svg"),"slot":preload("res://assets/ui/work651/slot.svg"),"hero_ornate":preload("res://assets/ui/work651/hero.svg"),"boss_ornate":preload("res://assets/ui/work651/boss.svg")}
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
    _theme.set_constant("buttons_min_height","AcceptDialog",88)
    return _theme
