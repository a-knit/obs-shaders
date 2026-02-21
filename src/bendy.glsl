// Animating a work by https://www.instagram.com/jgbentley10/ who you should check out!
// #define AMPLITUDE 0.1
// #define SPEED 1.5

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
    float fl = floor(p);
    float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord;

    float AMPLITUDE = 0.1;
    float SPEED = 1.5;

    float amp = (1. + sin(builtin_elapsed_time * SPEED)) * .5 * AMPLITUDE;
    //amp = noise(builtin_elapsed_time * SPEED) * AMPLITUDE; 
    uv.y += noise(builtin_elapsed_time + uv.x * 50.) * amp;
    uv.x += noise(builtin_elapsed_time + uv.y * 25.) * amp;

    uv = clamp(uv, 0., 1.);
    
    fragColor = image.Sample(builtin_texture_sampler, uv);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}