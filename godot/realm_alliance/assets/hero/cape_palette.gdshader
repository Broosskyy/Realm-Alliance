shader_type canvas_item;
uniform bool modular_outfit = false;
uniform float modular_rear_cut = 0.62;
uniform vec4 modular_cloth_color : source_color = vec4(1.0);
uniform vec4 modular_head_region = vec4(0.0);
uniform float modular_leg_start = 1.0;
uniform int evolution_rank = 0;
uniform int mastery_rank = 0;
uniform bool eclipse_armor = false;
uniform bool emerald = false;
uniform bool astral = false;
uniform bool split_cape = false;
uniform bool cape_pass = false;
uniform vec2 cape_polygon[8];
varying vec4 sprite_modulate;
void vertex() {
    sprite_modulate = COLOR;
}
void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // Palette swap only for the original blue-violet textile pixels.
    // White hair, skin, gold armor, alpha and the independent sword are unchanged.
    float blue = smoothstep(0.035, 0.12, tex.b - max(tex.r, tex.g));
    float purple = smoothstep(0.035, 0.15, tex.b - tex.g) * (1.0 - smoothstep(0.5, 0.8, tex.r));
    float mask = max(blue, purple) * (1.0 - smoothstep(0.49, 0.64, UV.x));
    if (modular_outfit) {
        float cyan = smoothstep(0.025,0.10,min(tex.g,tex.b)-tex.r);
        float textile = max(max(blue,purple),cyan);
        float lightness=dot(tex.rgb,vec3(0.2126,0.7152,0.0722));
        tex.rgb=mix(tex.rgb,modular_cloth_color.rgb*lightness*1.55,textile*0.90);
    }
    if (emerald) {
        vec3 tint = vec3(tex.r * 0.55, tex.b * 0.82 + tex.g * 0.18, tex.b * 0.72);
        tex.rgb = mix(tex.rgb, tint, mask);
    }
    if (astral) {
        vec3 tint = vec3(tex.b * 0.18, tex.b * 0.84, tex.b);
        tex.rgb = mix(tex.rgb, tint, mask);
    }
    // Authored colors remain the base; higher forms add a restrained metal
    // highlight and a bright cloak hem, without changing face/hair pixels.
    float metal = smoothstep(0.10,0.30,tex.r-tex.b)*smoothstep(0.15,0.5,tex.g);
    if (eclipse_armor) {
        float worn = smoothstep(0.49,0.65,UV.x) * (1.0-smoothstep(0.4,0.68,tex.r))*smoothstep(0.1,0.3,tex.b);
        tex.rgb=mix(tex.rgb,vec3(tex.b*0.72,tex.g*0.72,tex.b*1.1),worn*0.7);
    }
    if (mastery_rank > 0) {
        tex.rgb += vec3(.018,.024,.03)*float(mastery_rank)*metal;
        if (mastery_rank >= 3) tex.rgb=mix(tex.rgb,vec3(tex.r*.9+tex.b*.12,tex.g*.92,tex.b),mask*.30);
        if (mastery_rank == 5) tex.rgb += vec3(.08,.045,0.0)*metal;
    }
    if (evolution_rank >= 1) tex.rgb += vec3(0.05,0.035,0.005)*metal;
    if (evolution_rank == 3) {
        tex.rgb = mix(tex.rgb,vec3(tex.r*0.95+tex.b*0.18,tex.g*0.9,tex.b*0.82),mask*0.65);
        tex.rgb += vec3(0.12,0.075,0.005)*metal;
    }
    if (split_cape) {
        bool inside = false;
        for (int i = 0; i < 8; i++) {
            vec2 a = cape_polygon[i];
            vec2 b = cape_polygon[(i + 7) % 8];
            if (((a.y > UV.y) != (b.y > UV.y)) && (UV.x < (b.x-a.x)*(UV.y-a.y)/(b.y-a.y+0.000001)+a.x)) { inside = !inside; }
        }
        if (modular_outfit) {
            bool head = UV.x >= modular_head_region.x && UV.x <= modular_head_region.z && UV.y >= modular_head_region.y && UV.y <= modular_head_region.w;
            bool legs = UV.y >= modular_leg_start;
            float cyan = smoothstep(0.025,0.10,min(tex.g,tex.b)-tex.r);
            float textile = max(max(blue,purple),cyan);
            // Source bodies contain painted armour, hair and skin. A cape mask
            // must never erase those opaque body parts when a pose leans left.
            tex.a *= 1.0-float(inside && !head && !legs)*textile;
        } else {
            tex.a *= cape_pass ? float(inside) : 1.0-float(inside);
        }
    }
    COLOR = tex * sprite_modulate;
}
