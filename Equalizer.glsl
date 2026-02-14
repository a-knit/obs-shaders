uniform texture2d builtin_texture_fft_main;
// Configure builtin uniforms
// These macros are optional, but improve the user experience
#pragma shaderfilter set main__mix__description Main Mix/Track
#pragma shaderfilter set main__channel__description Main Channel
#pragma shaderfilter set main__dampening_factor_attack 0.0
#pragma shaderfilter set main__dampening_factor_release 0.0
// Define configurable variables
// These macros are optional, but improve the user experience
#pragma shaderfilter set fft_color__description FFT Color
#pragma shaderfilter set fft_color__default 7FFF00FF
uniform float4 fft_color;

#define NB_BARS		32
#define NB_SAMPLES	16
// WARNING : NB_BARS x NB_SAMPLES must be 512

// space between bars (relative to bar width)
#define SPACE		0.15

// space without bars, left and right (relative to window size)
#define SIDE_SPACE  0.04

// from here: www.shadertoy.com/view/XtjBzG
vec3 heatColorMap(float t)
{
    t *= 4.;
    return clamp(vec3(min(t-1.5, 4.5-t), 
                      min(t-0.5, 3.5-t), 
                      min(t+0.5, 2.5-t)), 
                 0., 1.);
}

void mainImage( out vec4 O, in vec2 I ) {
    
    // vec2 uv = I/iResolution.xy;
    vec2 uv = I;
    
    uv.x = (uv.x-SIDE_SPACE)/(1.-2.*SIDE_SPACE);
    
    if(uv.x<0. || uv.x > 1.)
    {
    	O = vec4(0.);
        return;
    }
    
    float NB_BARS_F = float(NB_BARS);
    int bar = int(floor(uv.x * NB_BARS_F));
    
    float f = 0.;
    f = 0.;
    
    for(int t=0; t<NB_SAMPLES; t++)
    {
    	// f += texelFetch(iChannel0, ivec2(bar*NB_SAMPLES+t, 0), 0).r;
        f += builtin_texture_fft_main.Sample(builtin_texture_sampler, ivec2(bar*NB_SAMPLES+t, 0), 0).r;
    }
    f /= float(NB_SAMPLES);
    
    f *= 0.85;
    f += 0.02;
    
    vec3 c = heatColorMap(f);
    
    
    float bar_f = float(bar)/NB_BARS_F;
    
    // c *= 1.-step(f, uv.y);
    // c *= 1.-step(1.-SPACE*.5, (uv.x-bar_f)*NB_BARS);
    // c *= 1.-step(1.-SPACE*.5, 1.-(uv.x-bar_f)*NB_BARS);
    
    // c *= mix(1.,0., clamp((uv.y-f)*iResolution.y,0.,1.));
    // c *= clamp((min((uv.x-bar_f)*NB_BARS_F, 1.-(uv.x-bar_f)*NB_BARS_F)-SPACE*.5)/NB_BARS_F*iResolution.x, 0., 1.);
    c *= mix(1.,0., clamp((uv.y-f)*builtin_uv_size.y,0.,1.));
    c *= clamp((min((uv.x-bar_f)*NB_BARS_F, 1.-(uv.x-bar_f)*NB_BARS_F)-SPACE*.5)/NB_BARS_F*builtin_uv_size.x, 0., 1.);
    

    O = vec4(c, 1.0);
}
float remap(float x, float2 from, float2 to) {
    float normalized = (x - from[0]) / (from[1] - from[0]);
    return normalized * (to[1] - to[0]) + to[0];
}

float4 render(float2 uv) {
    float fft_frequency = uv.x;
    float fft_amplitude = builtin_texture_fft_main.Sample(builtin_texture_sampler, float2(fft_frequency, 0.5)).r;
    float fft_db = 20.0 * log(fft_amplitude / 0.5) / log(10.0);
    float fft_db_remapped = remap(fft_db, float2(-50, -0), float2(0, 1));
    float value = float(1.0 - uv.y < fft_db_remapped);

    // float3 color = image.Sample(builtin_texture_sampler, uv).rgb;
    // float4 output = float4(lerp(color, fft_color.rgb, fft_color.a * value), 1.0);

    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}