shader_type canvas_item;

uniform sampler2D noise;

void fragment() {
	COLOR = mix(COLOR,vec4(0,0,0,0),texture(noise,UV).r);
}