/*
 * "Toon webcam" by Ben Wheatley - 2018
 * License MIT License
 * Contact: github.com/BenWheatley
 */


vec3 posterize(vec3 col, int rCount, int gCount, int bCount) {
    float fColR = float(rCount);
    float fColG = float(gCount);
    float fColB = float(bCount);
    int r = int(fColR*col.r);
    int g = int(fColG*col.g);
    int b = int(fColB*col.b);
    return vec3( float(r)/fColR, float(g)/fColG, float(b)/fColB );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // float time = iTime;
    float time = builtin_elapsed_time;
    // vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv = fragCoord.xy;
    
    // vec2 pixelSize = vec2(1,1) / iResolution.xy;
    vec2 pixelSize = vec2(1,1) / builtin_uv_size;
    
    vec3 sum = vec3(0,0,0);
    
    mat3 kernel = mat3( -1,  -1,  -1,
                -1, 8,  -1,
                -1,  -1,  -1);
    
    for (int dy = -1; dy<=1; dy++) {
	    for (int dx = -1; dx<=1; ++dx) {
            vec2 pixelOff = pixelSize * vec2(dx, dy);
            vec2 tex_uv = uv + pixelOff;
            // vec3 textureValue = texture(iChannel0, tex_uv).rgb;
            vec3 textureValue = image.Sample(builtin_texture_sampler, tex_uv).rgb;
            sum += (kernel[dx+1][dy+1] * textureValue);
        }
    }
    
    vec3 edge = sum;
    // vec3 cam = posterize(texture(iChannel0, uv).rgb, 4, 4, 2);
    vec3 cam = posterize(image.Sample(builtin_texture_sampler, uv).rgb, 4, 4, 2);
    
    fragColor = vec4(cam + 5.0*edge,1.);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}