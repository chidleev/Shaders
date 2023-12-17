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

vec3 star(in vec3 ray_direction, float size) {
    vec3 color = vec3(0.0, 0.0, 0.0);

    float angle = acos(dot(ray_direction, vec3(0., -1, 0.)));

    for (int y = -5; y <= 5; y++) {
        for (int x = -5; x <= 5; x++) {
            vec2 offset = vec2(x, y);

            vec3 position_on_floor = floor(2. * ray_direction * tan(angle)) + 0.5;
            position_on_floor.x += offset.x;
            position_on_floor.z += offset.y;
            position_on_floor.y = -2. + .5* sin((u_time + position_on_floor.x) / 2.) * cos((u_time + position_on_floor.z) / 2.);

            float distance_to_ray = length(position_on_floor - ray_direction * dot(position_on_floor, ray_direction));
            
            vec3 clr = vec3(Hash21(position_on_floor.xx),
                            Hash21(position_on_floor.xz),
                            Hash21(position_on_floor.zz));

            color += clr * vec3(pow(size / (distance_to_ray * length(position_on_floor)), 2.5));
        }
    }

    /*color *= vec3(star_rays(position, 3./size, angle + PI_TWO) + 
                  star_rays(position, 3./size, angle + PI_TWO / 2.));

    color *= vec3(star_rays(position, 1./(2. * size), angle + (PI_TWO + sin(u_time * 2.)) / 4.) +
                  star_rays(position, 1./(2. * size), angle - (PI_TWO + sin(u_time * 2.)) / 4.));*/

    return color;
}

vec3 star_layer() {
    vec3 color = vec3(0.);

    float FOV = uv.x * PI/6., D = 0.5;
    //vec3 origin_position = vec3(0., 1., 0.);
    vec3 view_direction = rotateY(normalize(vec3(0., 0., 1.)), u_time / 50.);
    vec3 right = cross(vec3(0., 1., 0.), view_direction);
    vec3 top = cross(view_direction, right);
    vec3 ray_direction = normalize(D * view_direction + FOV * right + 0.5 * uv.y * top);
    
    color = star(ray_direction, 0.5);
    color *= vec3(smoothstep(0.05, 0.5, abs(uv.y)));

    return color;
}

void main() {
    vec3 color = star_layer();
    outColor = vec4(color, 1.0);
}