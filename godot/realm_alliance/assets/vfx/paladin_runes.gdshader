shader_type canvas_item;
varying vec4 rune_modulate;
void vertex(){ rune_modulate=COLOR; }
void fragment(){
    vec4 source=texture(TEXTURE,UV);
    float light=max(source.r,max(source.g,source.b));
    vec3 gold=mix(vec3(0.42,0.13,0.02),vec3(1.0,0.85,0.32),light);
    COLOR=vec4(gold,source.a)*rune_modulate;
}
