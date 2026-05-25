// Sample transition shader: fades through black.
// progress 0→1 with invert=false: black overlay fades away (reveals loading screen).
// progress 0→1 with invert=true:  black overlay fades in  (covers loading screen).
// Copy and modify this to create your own transition effects.
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool invert = false;

void fragment() {
	float p = invert ? 1.0 - progress : progress;
	COLOR = vec4(0.0, 0.0, 0.0, 1.0 - p);
}
