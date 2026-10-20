shader_type canvas_item;
uniform float motion_strength=0.0;
void vertex() {
    float free_edge=pow(1.0-UV.x,2.0);
    VERTEX.x+=sin(TIME*2.1+UV.x*4.0)*motion_strength*free_edge;
    VERTEX.y+=sin(TIME*1.7+UV.x*4.0)*motion_strength*free_edge*0.6;
}
