shader_type canvas_item;

uniform float grayscale = 1.0;

void fragment() {
	COLOR = texture(TEXTURE,UV);
	float gray = COLOR.r + COLOR.g + COLOR.b;
    vec4 gray_color = vec4(gray/3.0,gray/3.0,gray/3.0,COLOR.a);
	COLOR = (1.0 - grayscale) * COLOR + grayscale*gray_color;
}