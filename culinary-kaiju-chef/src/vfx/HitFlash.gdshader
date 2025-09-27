shader_type canvas_item;

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 final_color = mix(tex_color, flash_color, flash_intensity);
    COLOR = vec4(final_color.rgb, tex_color.a);
}