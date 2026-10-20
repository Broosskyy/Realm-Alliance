extends RefCounted
class_name RAWingProgression710
# Wing level is the original paid level, never replaced or reset.
const MAX_PLUS=15
static func valid_level(value:Variant,maximum:int) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and float(value)==floor(float(value)) and int(value)>=1 and int(value)<=maximum
static func cost(level:int) -> Dictionary:
    # Every 709 upgrade keeps its original price; only newly reachable steps grow.
    return {"gold":25*level,"shards":1+maxi(0,int((level-9)/3))}
static func visual(plus:int) -> Dictionary:
    var p=clampi(plus,0,MAX_PLUS)
    return {"plus":p,"scale":.34+.046*p,"feathers":p,"crystals":int(p/5),"second_fan":p>=8,"rim":p>=10,"crown":p>=12,"final":p==MAX_PLUS}
