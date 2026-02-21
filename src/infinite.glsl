// float resolution_x = 600.0;
// float resolution_y = 300.0;

// /*
// current (transverse mercator) version
// 2020 2/19
#define PI 3.141592653589793238462643383279502884197169399375105820974944592307816406286
// i know more

float sech (float x) {
    return 2.*cosh(x)/(cosh(2.*x)+1.);
}
vec2 inv_f (vec2 z) {
    // inverse transverse mercator
    // thanks wikipedia
    // z = vec2(z.y, z.x+iTime*.2)*3.;
    z = vec2(z.y, z.x+builtin_elapsed_time*.1)*3.;
    z = vec2(
        atan(sinh(z.x)/cos(z.y)),
        asin(sech(z.x)*sin(z.y))
    )/PI*4.;
    z = vec2(z.x+z.y, z.x-z.y);
    return vec2(fract(z.x), fract(z.y));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord) {
    // vec2 screen = (fragCoord-iResolution.xy/2.)/iResolution.y*2.;
    // vec2 uv_size = vec2(resolution_x, resolution_y);
    // vec2 screen = (fragCoord-uv_size.xy/2.)/uv_size.y*2.;
    // vec2 screen = (fragCoord-builtin_uv_size.xy/resolution_x)/builtin_uv_size.y*resolution_y;
    // vec2 screen = (fragCoord-builtin_uv_size.xy/600. + 0.3)/builtin_uv_size.y*300.;
    vec2 screen = (fragCoord*builtin_uv_size - builtin_uv_size/2.)/builtin_uv_size.y*2;
    vec2 z = inv_f(screen);
    // vec3 retina = vec3(min(z.x, z.y), z.x, max(z.x, z.y));
    // vec3 retina = texture(iChannel0, inv_f(screen)).rgb;
    vec3 retina = image.Sample(builtin_texture_sampler, inv_f(screen)).rgb;
    fragColor = vec4(retina, 1.);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    mainImage(OUTTT, uv);
    return OUTTT;
}