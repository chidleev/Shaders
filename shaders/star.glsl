#version 300 es
precision highp float;
out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI_TWO			1.570796326794897
#define PI				3.141592653589793
#define TWO_PI			6.283185307179586

/* Coordinate and unit utils */
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
#define uv ((gl_FragCoord.xy - .5 * u_resolution.xy)/u_resolution.y)
#define st coord(gl_FragCoord.xy)
#define mx coord(u_mouse)

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34, 456.21));
    p += dot(p, p+45.32);
    return fract(p.x*p.y);
}

/* Math 3D Transformations */
vec3 rotateY(vec3 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    mat4 r = mat4(
        vec4(c, 0, s, 0),
        vec4(0, 1, 0, 0),
        vec4(-s, 0, c, 0),
        vec4(0, 0, 0, 1)
    );
    return (vec4(p, 1.0) * r).xyz;
}

mat2 rotate2d(in float angle){
    return mat2(cos(angle),-sin(angle), sin(angle), cos(angle));
}

float star_rays(in vec3 position, float size, float angle) {
    vec2 position_on_screen = st - position.xy / position.z;
    position_on_screen.xy *= rotate2d(angle);
    return 2. * pow(1. - abs(position_on_screen.x * position_on_screen.y), size * position.z * position.z);
}

vec3 star(in vec3 position, float size, float angle) {
    vec3 color = vec3(0.0, 0.0, 0.0);

    float D = 15.;
    D /= (0.7 - uv.y);
    vec2 coords_on_floor = D * rotateY(vec3(0., 0., 1.), uv.x * PI/6.).xz / cos(uv.x * PI/6.);

    vec2 position_on_screen = (fract(coords_on_floor) - 0.5) - (position.xy);

    color += vec3(pow(size / (length(position_on_screen) * position.z), 1.5));
    /*color *= vec3(star_rays(position, 3./size, angle + PI_TWO) + 
                  star_rays(position, 3./size, angle + PI_TWO / 2.));

    color *= vec3(star_rays(position, 1./(2. * size), angle + (PI_TWO + sin(u_time * 2.)) / 4.) +
                  star_rays(position, 1./(2. * size), angle - (PI_TWO + sin(u_time * 2.)) / 4.));*/

    return color;
}

vec3 star_layer() {
    vec3 color = vec3(0.);

    float D = 20., FOV = PI/3.;
    D /= (.8 - uv.y);
    vec2 coords_on_floor = D * rotateY(vec3(0., 0., 1.), 0.5 * uv.x * FOV + u_time / 10.).xz / cos(0.5 * uv.x * FOV) + vec2(u_time);
    vec2 ID = floor(coords_on_floor);
    vec2 fract_coords = fract(coords_on_floor);

    for (int y = -2; y <= 2; y++) {
        for (int x = -2; x <= 2; x++) {
            vec2 offset = vec2(x, y);
            color += step(distance(ID + offset, coords_on_floor), 0.5);
        }
    }
        
    //color += vec3(0.4, 0.6, 1.0) * star(vec3(floor(coords_on_floor.x), -0.5, floor(coords_on_floor.y)), 5.2, 0.);

    /*for (int z = 1; z <= 50; z++)
        for (int y = -1; y <= -1; y++)
            for (int x = -1; x <= 1; x++) {
                vec3 offset = vec3(float(-x) / 10., float(y) + 0.1 * sin(6.*float(z)+u_time) + 1., float(z)/10.);
                color += vec3(0.4, 0.6, 1.0) * star(offset, .002, 0.);
            }
    */

    
    return color;
}

void main() {
    vec3 color = star_layer();
    outColor = vec4(color, 1.0);
}