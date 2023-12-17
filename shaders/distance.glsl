#version 300 es
precision highp float;

out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI_TWO			1.570796326794897
#define PI				3.141592653589793
#define TWO_PI			6.283185307179586

vec2 coord(in vec2 p) {
    p = p / u_resolution.xy;
    // correct aspect ratio
    if (u_resolution.x > u_resolution.y) {
        p.x *= u_resolution.x / u_resolution.y;
        p.x += (u_resolution.y - u_resolution.x) / u_resolution.y / 2.0;
    } else {
        p.y *= u_resolution.y / u_resolution.x;
        p.y += (u_resolution.x - u_resolution.y) / u_resolution.x / 2.0;
    }
    // centering
    p -= 0.5;
    p *= vec2(-1.0, 1.0);
    return p;
}
#define rx (1.0 / min(u_resolution.x, u_resolution.y))
#define uv (gl_FragCoord.xy / u_resolution.xy)
#define st coord(gl_FragCoord.xy)
#define mx coord(u_mouse)

float N21(vec2 p) {
	vec3 a = fract(vec3(p.xyx) * vec3(213.897, 653.453, 253.098));
    a += dot(a, a.yzx + 79.76);
    return fract((a.x + a.y) * a.z);
}

mat2 rotate2d(in float angle){
    return mat2(cos(angle),-sin(angle), sin(angle), cos(angle));
}

float light_rays(in vec2 pos, float size, float brightness, float angle) {
    pos *= rotate2d(angle);
    return brightness * pow(1. - abs(pos.x * pos.y), size);
}

vec3 light_point(in vec2 pos, float size, float brightness, float angle) {
    float count = 5.;
    vec2 fract_st = (fract(st * count) - 0.5) / count;
    
    //if (fract_pos.x < 0.0001 || fract_pos.y < 0.0001) return vec3(1.);

    
    float point = 0., rays = 0.;

    for (int x = -1; x <= 1; x++)
        for (int y = -1; y <= 1; y++) {
            vec2 fract_pos = vec2(N21(floor((st + vec2(x, y)) * count)));
            vec2 star_pos = fract_st - fract_pos ;
            point += pow(size/length(star_pos), brightness);
            rays += light_rays(star_pos, 10. * brightness/size, brightness, angle);
            rays += light_rays(star_pos, 20. * brightness/size, brightness, angle + PI_TWO/3.);
            rays += light_rays(star_pos, 40. * brightness/size, brightness, angle + 2. * PI_TWO/3.);
        }
    rays *= point;
    return vec3(point + rays);
}

void main() {
    vec3 light = vec3(0.4, 0.6, 0.9) * light_point(mx, 0.002, 1.5, 0.);
    
    outColor = vec4(light, 1.);
}