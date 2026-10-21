shader_type canvas_item;
uniform vec4 hair_tint : source_color = vec4(.55,.35,.2,1.0);
void fragment(){
 vec4 tex=texture(TEXTURE,UV);
 if(UV.x>.073 && UV.x<.867 && UV.y>.025 && UV.y<.582){
  float warm=smoothstep(.02,.10,tex.r-tex.b)*(1.0-smoothstep(.60,.80,tex.r));
  float eye=step(.54,tex.r)*step(.29,tex.g)*(1.0-step(.30,tex.b));
  tex.rgb=mix(tex.rgb,hair_tint.rgb*dot(tex.rgb,vec3(.2126,.7152,.0722))*2.6,warm*(1.0-eye));
 }
 COLOR=tex*COLOR;
}
