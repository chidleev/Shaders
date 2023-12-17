#version 300 es
precision highp float;

out vec4 outColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform vec2[10] u_trails;

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
    p *= vec2(1.0, 1.0);
    return p;
}
#define rx 1.0 / min(u_resolution.x, u_resolution.y)
#define uv gl_FragCoord.xy / u_resolution.xy
#define st coord(gl_FragCoord.xy)
#define mx coord(u_mouse)

vec2 cplx_mult(in vec2 a, in vec2 b)
{
	return vec2(a.x * b.x - a.y * b.y, a.y * b.x + a.x * b.y);
}

vec2 cplx_div(in vec2 a, in vec2 b)
{
	return cplx_mult(a, vec2(b.x, -b.y)) / (b.x * b.x + b.y * b.y);
}

vec2 cplx_pow(in vec2 a, int p)
{
	vec2 temp = vec2(1, 0);
	for (int i = 0; i < abs(p); i++)
		temp = cplx_mult(temp, a);
	if (p < 0) temp = cplx_div(vec2(1, 0), temp);
	return temp;
}

vec3 palette(float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d){
	return a + b * cos(TWO_PI*(c*t + d));
}

float IterateMandelbrot( in vec2 c )
{
    const float B = 256.0;

    float n = 0.0;
    vec2 z  = vec2(0.0);
    for( int i=0; i<200; i++ )
    {
        z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c; // z = z² + c
        if( dot(z,z)>(B*B) ) break;
        n += 1.0;
    }

    //float sn = n - log(log(length(z))/log(B))/log(2.0); // smooth iteration count
    float sn = n - log2(log2(dot(z,z))) + 4.0;  // equivalent optimized smooth iteration count
    
    return sn;
}

void main() {
    vec2
    time_number = vec2(cos(u_time/1.), sin(u_time/1.)),
    pixel = 6. * st + vec2(0., 0.),
    current_number = pixel + vec2(0., 0.),
    last_number = current_number;

    int
    iterations = 0,
    max_iterations = 250;

    const float max_distance = 10.0;

    for (;(iterations < max_iterations); iterations++) {
        last_number = current_number;
        current_number = cplx_pow(current_number, -2) + mx;
        if (dot(current_number, current_number) > (max_distance * max_distance) ) break;
    }

    float iterations_mask = float(iterations)/float(max_iterations);
    float smooth_iterations_mask = float(iterations) - log(log(length(current_number))/log(max_distance))/log(2.0);

    float color_speed = 1./10.;
    vec3 color_offset = vec3(0.2, 0.35, 0.4);
    vec3 color_palette = palette(smooth_iterations_mask / 125. + u_time * color_speed, vec3(0.5), vec3(0.5), vec3(0.5), color_offset);
    
    outColor = vec4(color_palette, 1.);
}