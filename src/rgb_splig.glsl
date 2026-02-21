float rounding = 0.0;
float sharpness = 0.02;
// float INNER = (1./3.);
float INNER = 5.3333;

float rand(float x)
{
	return fract(sin(x)*100000.0);
}

float noise1D(float x)
{
    float i = floor(x);  // integer
	float f = fract(x);  // fraction
	float u = f*f*f*(f*(f*6.-15.)+10.); // custom cubic curve
	return mix(rand(i), rand(i + 1.0), u); // using it in the interpolation
}

vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

// Gradient Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/XdXGW8
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // vec2 uv = fragCoord/iResolution.xy;
    vec2 uv = fragCoord;
#define PI 3.1415926
    // distance
    
	// float t = (1.0/5.0)*iTime*(2.0*3.1415936);
    float t = (1.0/5.0)*builtin_elapsed_time*(2.0*PI);
    float WIGGLE = 1.03;
    float COLOR_OFFSET = 1.0;
    float N = WIGGLE*1.0;//(sin(t));
    vec2 uvR = uv + N*vec2(noise(uv+t), noise(312.0+uv+t));
    vec2 uvG = uv + N*vec2(noise(uv+COLOR_OFFSET+t), noise(312.0+uv+COLOR_OFFSET+t));
    vec2 uvB = uv + N*vec2(noise(uv-COLOR_OFFSET+t), noise(312.0+uv-COLOR_OFFSET+t));
    
    // float G = texture(iChannel0, uvG).g;
    // float R = texture(iChannel0, uvR).r;
    // float B = texture(iChannel0, uvB).b;
	float R = image.Sample(builtin_texture_sampler, uvR).r;
	float G = image.Sample(builtin_texture_sampler, uvG).g;
	float B = image.Sample(builtin_texture_sampler, uvB).b;
    
	fragColor = vec4(R,G,B, 1.0);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    mainImage(OUTTT, uv);
    return OUTTT;
}