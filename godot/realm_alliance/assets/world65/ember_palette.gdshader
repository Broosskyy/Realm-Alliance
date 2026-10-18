shader_type canvas_item;
void fragment(){
    vec4 c=COLOR;
    float glow=smoothstep(0.03,0.28,c.b-max(c.r,c.g));
    vec3 stone=c.rgb*vec3(0.91,0.77,0.72);
    COLOR=vec4(mix(stone,vec3(max(c.b,0.6),c.b*0.40,c.b*0.12),glow),c.a);
}
