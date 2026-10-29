shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 5.0) = 1.0;

uniform sampler2D screen_texture : hint_screen_texture,
 filter_linear_mipmap;

void fragment() {
 vec2 px = SCREEN_PIXEL_SIZE * blur_strength;

 vec4 color = vec4(0.0);

 color += textureLod(screen_texture, SCREEN_UV + vec2(-px.x, -px.y), 0.0);
 color += textureLod(screen_texture, SCREEN_UV + vec2(0.0, -px.y), 0.0);
 color += textureLod(screen_texture, SCREEN_UV + vec2(px.x, -px.y), 0.0);

 color += textureLod(screen_texture, SCREEN_UV + vec2(-px.x, 0.0), 0.0);
 color += textureLod(screen_texture, SCREEN_UV, 0.0);
 color += textureLod(screen_texture, SCREEN_UV + vec2(px.x, 0.0), 0.0);

 color += textureLod(screen_texture, SCREEN_UV + vec2(-px.x, px.y), 0.0);
 color += textureLod(screen_texture, SCREEN_UV + vec2(0.0, px.y), 0.0);
 color += textureLod(screen_texture, SCREEN_UV + vec2(px.x, px.y), 0.0);

 COLOR = color / 9.0;
}