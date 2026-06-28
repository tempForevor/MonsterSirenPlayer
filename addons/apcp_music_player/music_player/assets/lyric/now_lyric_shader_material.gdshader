shader_type canvas_item;

uniform float max_value = 1.0;
uniform float now_value = 0.0;
uniform vec4 raw_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 alt_color = vec4(0.0,0.1,1.0,1.0);

uniform vec2 size=vec2(1.0,1.0);
varying vec2 vertex_pos;


void vertex(){
	vertex_pos = VERTEX/size;
}

void fragment() {
	vec4 color;
	vec2 uv=vertex_pos;
	if(uv.x<now_value/max_value){
		color = alt_color;
	}
	else{
		color = raw_color;
	}
	COLOR = color * COLOR;
}
