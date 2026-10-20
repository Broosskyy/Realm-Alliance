extends Node2D
var clock=0.0
var _accum=0.0
func _process(delta:float) -> void:
    if not is_visible_in_tree() or int(get_tree().root.get_meta("realm_effect_level",0))==2:return
    clock+=delta;_accum+=delta
    if _accum>.05:_accum=0;queue_redraw()
func _draw() -> void:
    var size:Vector2=get_parent().size
    if size.x<20 or size.y<30:return
    var level=int(get_tree().root.get_meta("realm_effect_level",0))
    if level==2:return
    var amount=.15 if level==1 else .4
    for i in 8:
        var p=Vector2(fposmod(i*71.3+19,size.x-20)+10,fposmod(i*53.7-clock*(5+i%3),size.y-30)+15)
        draw_circle(p,1.5,Color(.5,.8,1,amount*(.5+.3*sin(clock+i))))
