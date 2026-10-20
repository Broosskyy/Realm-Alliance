extends RefCounted
class_name RACharacterAppearance710
# Future basic creation contract only. 710 never replaces an owned hero or save.
const SCHEMA=1
const BODY_VARIANTS=["male","female"]
const NATURAL_COLORS=["blond","black","brown","copper"]
const SPECIAL_COLORS=["white","silver","blue","red","violet"]
const LAYERS=["body","hair","face","torso","legs","head","hands","boots","weapon","wings","costume","accessories","effects"]
static func basic(body:String="male",hair:String="brown") -> Dictionary:
    if body not in BODY_VARIANTS or hair not in NATURAL_COLORS:return {}
    return {"schema":SCHEMA,"body_variant":body,"hair_color":hair,"unlocked_hair_colors":NATURAL_COLORS.duplicate(),"face_style":"realm_mask_glowing_eyes","class_id":"adventurer","equipment_layers":{}}
static func valid(value:Dictionary) -> bool:
    if value.get("schema")!=SCHEMA or value.get("body_variant") not in BODY_VARIANTS:return false
    if value.get("face_style")!="realm_mask_glowing_eyes" or not value.get("equipment_layers") is Dictionary:return false
    var colors=value.get("unlocked_hair_colors")
    if not colors is Array:return false
    for color in colors:
        if color not in NATURAL_COLORS+SPECIAL_COLORS:return false
    for color in NATURAL_COLORS:
        if color not in colors:return false
    if value.get("hair_color") not in colors:return false
    return str(value.get("class_id","")) in ["adventurer","swordsman","archer","mage"]
