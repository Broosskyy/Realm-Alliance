extends RefCounted
class_name RAHeroCape
# Exact source UV polygons isolate ONLY trailing rear cloth, never face/weapon.
# The same artwork is folded about a pose-local shoulder; no new painted hero.
const SHAPES={
    "idle":[Vector2(112,208),Vector2(265,207),Vector2(341,245),Vector2(335,312),Vector2(302,371),Vector2(241,437),Vector2(128,423),Vector2(102,302)],
    "ready":[Vector2(89,158),Vector2(257,158),Vector2(354,243),Vector2(352,284),Vector2(284,335),Vector2(213,406),Vector2(106,370),Vector2(78,263)],
    "windup":[Vector2(77,155),Vector2(246,155),Vector2(346,220),Vector2(344,267),Vector2(268,347),Vector2(217,402),Vector2(108,382),Vector2(67,271)],
    "attack_contact":[Vector2(40,144),Vector2(268,144),Vector2(371,235),Vector2(369,283),Vector2(294,323),Vector2(230,369),Vector2(74,349),Vector2(33,250)],
    "recovery":[Vector2(93,199),Vector2(246,192),Vector2(340,251),Vector2(338,296),Vector2(287,350),Vector2(214,427),Vector2(109,379),Vector2(83,295)],
    "hit":[Vector2(95,199),Vector2(240,191),Vector2(280,240),Vector2(270,277),Vector2(260,310),Vector2(212,365),Vector2(130,365),Vector2(83,280)]}
var cloth: Sprite2D
var material: ShaderMaterial
var folded=false
func attach(hero) -> void:
    cloth=Sprite2D.new();cloth.name="PoseCompatibleCape";cloth.centered=false;cloth.z_index=-1
    material=ShaderMaterial.new();material.shader=hero._palette.shader;material.set_shader_parameter("cape_pass",true)
    cloth.material=material;hero._art.add_child(cloth)
func set_folded(hero,value: bool) -> void:
    value=value and hero.hero_id=="realmwachter"
    folded=value;hero._palette.set_shader_parameter("split_cape",value);cloth.visible=value
    material.set_shader_parameter("split_cape",value)
    sync(hero,hero._pose)
func sync(hero,pose: String) -> void:
    if hero.hero_id!="realmwachter":
        hero._palette.set_shader_parameter("split_cape",false);cloth.visible=false;return
    var polygon=PackedVector2Array()
    for point in SHAPES[pose]:polygon.append(point/Vector2(640,512))
    hero._palette.set_shader_parameter("cape_polygon",polygon)
    material.set_shader_parameter("cape_polygon",polygon)
    material.set_shader_parameter("emerald",hero._look=="emerald");material.set_shader_parameter("astral",hero._look=="astral")
    cloth.texture=hero._body.texture
    cloth.scale=Vector2(.42,.90)
    var shoulder=hero.VISUAL_SOCKETS[pose].back+Vector2(-12,-8)
    cloth.position=shoulder-hero.PIVOT-shoulder*cloth.scale
