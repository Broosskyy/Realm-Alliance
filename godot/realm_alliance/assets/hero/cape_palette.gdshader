shader_type canvas_item;
uniform bool emerald = false;
uniform bool astral = false;
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
    if (emerald) {
        vec3 tint = vec3(tex.r * 0.55, tex.b * 0.82 + tex.g * 0.18, tex.b * 0.72);
        tex.rgb = mix(tex.rgb, tint, mask);
    }
    if (astral) {
        vec3 tint = vec3(tex.b * 0.18, tex.b * 0.84, tex.b);
        tex.rgb = mix(tex.rgb, tint, mask);
    }
    COLOR = tex * sprite_modulate;
}
