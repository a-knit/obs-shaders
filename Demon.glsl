//Modified from: iq's "Integer Hash - III" (https://www.shadertoy.com/view/4tXyWN)
//Faster than "full" xxHash and good quality
uint baseHash(uvec2 p)
{
    p = 1103515245U*((p >> 1U)^(p.yx));
    uint h32 = 1103515245U*((p.x)^(p.y>>3U));
    return h32^(h32 >> 16);
}

//--------------------------------------------------

float old_hash12(vec2 x)
{
    uint n = baseHash(floatBitsToUint(x));
    
    return float(n & 0x7fffffffU)/float(0x7fffffff);
}

float hash12(vec2 x)
{
    return mod(13.3 + 201.1 * sin(302.2 * x.x + 123.7 * x.y + 11.1), 1.0);
}


float noise_term(in vec2 x, in float scale_val) {
    vec2 s = vec2(scale_val);
    vec2 x00 = x - mod(x, s);
    vec2 x01 = x + vec2(0.0, scale_val);
    x01 = x01 - mod(x01, s);
    vec2 x10 = x + vec2(scale_val, 0.0);
    x10 = x10 - mod(x10, s);
    vec2 x11 = x + s;
    x11 = x11 - mod(x11, s);
    
    float v00 = hash12(x00);
    float v01 = hash12(x01);
    float v10 = hash12(x10);
    float v11 = hash12(x11);
    
    vec2 uv = mod(x, s) / s;
    
    float yweight = smoothstep(0.0, 1.0, uv.y);
    float v1 = mix(v10, v11, yweight);
    float v0 = mix(v00, v01, yweight);
    
    float xweight = smoothstep(0.0, 1.0, uv.x);
    
    return mix(v0, v1, xweight);
}

float noise(in vec2 x, in float base_scale, in float space_decay, in float height_decay,
           in float shift_by) {
	float h = 1.0;
    float s = base_scale;

    float summation = 0.0;
    
    for (int i = 0; i < 4; ++i) {
    	summation = summation + h * noise_term(x + vec2(0.0, s * shift_by), s);
        s *= space_decay;
        h *= height_decay;
    }
    return summation;
}

float simple_noise(in vec2 uv, in float shift_by) {
  return noise(uv * 10.0, 5.0, 0.75, 0.75, shift_by);
}

vec2 noise2(in vec2 uv, in float shift_by) {
    return vec2(simple_noise(uv, shift_by),
                simple_noise(uv + vec2(0.0, 101.0), shift_by));
}

// const float EDGE_OR_CORNER_DETECT = 0.1; // 0 for corner, 1 for edge

// const float WINDOW_WIDTH = 4.0; // max 6.0

// const float SHOW_BACKGROUND = 0.25; // 0.0 for no background, 1.0 for all background

// const vec2 webcam_resolution = vec2(320.0, 240.0);

vec3 YUV(in vec2 fragCoord) {
    const mat3 to_yuvish = mat3(0.299, -0.14713, 0.615,
                          0.587, -0.28886, -0.51499,
                          0.114, 0.436, -0.10001);
    // return to_yuvish * texture(iChannel0, fragCoord / iResolution.xy).rgb;
    // return to_yuvish * image.Sample(builtin_texture_sampler, fragCoord / builtin_uv_size.xy).rgb;
    return to_yuvish * image.Sample(builtin_texture_sampler, fragCoord).rgb;
}

float Yval(in vec2 fragCoord) {
    return YUV(fragCoord).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    // vec2 uv = fragCoord/iResolution.xy;
    vec2 uv = fragCoord.xy;
    
    mat2 M = mat2(0.0);

    vec2 webcam_resolution = vec2(1920.0, 1080.0);
    float EDGE_OR_CORNER_DETECT = 0.1; // 0 for corner, 1 for edge
    float WINDOW_WIDTH = 4.0; // max 6.0
    float SHOW_BACKGROUND = 0.7; // 0.0 for no background, 1.0 for all background

    // vec2 scale = iResolution.xy / min(iResolution.xy, webcam_resolution.xy);
    // vec2 scale = builtin_uv_size.xy / min(builtin_uv_size.xy, webcam_resolution.xy);
    // vec2 scale = vec2(1.0);
    // vec2 scale = vec2(1.0, 1.0);
    vec2 scale = builtin_uv_size.xy;
    
    vec2 off = vec2(-4.0);
    for (int i = 0; i < 9; ++i) {
        off.y = -4.0;
        off.x += 1.0;
        for (int j = 0; j < 9; ++j) {
            off.y += 1.0;
            
            float weight = smoothstep(WINDOW_WIDTH, 0.0, length(off));
    
            float Ix = 0.5 * (Yval(fragCoord*builtin_uv_size + scale * (off + vec2(1.0, 0.0))) - 
                              Yval(fragCoord*builtin_uv_size + scale * (off - vec2(1.0, 0.0))));
            float Iy = 0.5 * (Yval(fragCoord*builtin_uv_size + scale * (off + vec2(0.0, 1.0))) - 
                              Yval(fragCoord*builtin_uv_size + scale * (off - vec2(0.0, 1.0))));
        
            M += weight * mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy);
        }
    }

   // mat2 M = mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy);
    
    float A = 1.0;
    float B = -M[0][0] - M[1][1];
    float C = M[0][0] * M[1][1] - M[0][1] * M[1][0];

    float l1 = (-B + sqrt(B * B - 4.0 * A * C)) / (2.0 * A);
    float l2 = (-B - sqrt(B * B - 4.0 * A * C)) / (2.0 * A);
    
    float min_eig = min(abs(l1), abs(l2));
    float max_eig = max(abs(l1), abs(l2));
//  float min_eig = min(l1, l2);
    
    float eig_to_use = mix(min_eig, max_eig, EDGE_OR_CORNER_DETECT);

    // Time varying pixel color
    vec3 col = smoothstep(vec3(0.0), 0.5 * vec3(0.1, 0.2, 0.3), vec3(eig_to_use));
    // vec3 raw_color = texture(iChannel0, fragCoord / iResolution.xy).rgb;
    // vec3 raw_color = image.Sample(builtin_texture_sampler, fragCoord / builtin_uv_size.xy).rgb;
    vec3 raw_color = image.Sample(builtin_texture_sampler, fragCoord).rgb;
    
    const float speed = 10.0;
    
    // float time = speed * iTime;
    float time = speed * builtin_elapsed_time;
    
    // uv = (2.0 * fragCoord -iResolution.xy) / iResolution.y;
    // uv = (2.0 * fragCoord -builtin_uv_size.xy) / builtin_uv_size.y;
    uv = (2.0 * fragCoord*builtin_uv_size.xy -builtin_uv_size.xy) / builtin_uv_size.y;

    // Time varying pixel color
    vec2 flame_col = noise2(uv + noise2(1.5 * uv + noise2(2.0 * uv, -0.2 * time), -0.13 * time), -0.1 * time) - 0.75;

    flame_col.g = min(0.5 * flame_col.g, flame_col.r);
    flame_col *= smoothstep(-0.25, -0.5, uv.y - 0.2 + flame_col.r - 1.0 * min(1.0, uv.x * uv.x));

    // Output to screen
    fragColor = vec4(
                     mix(mix(raw_color, col, 1.0 - SHOW_BACKGROUND),
                     vec3(flame_col, 0.0),
                     flame_col.r),
                1.0);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}