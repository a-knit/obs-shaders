#define TESTS 50.0
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv = fragCoord.xy;
    // float t = iTime;
    float t = builtin_elapsed_time;
    vec4 c = vec4(0.0);
    for(float i = 0.; i< TESTS; i++){
        c.rgb = max(c.rgb,
                sin(i/40.+
                    6.28*(vec3(0.,.33,.66)+
                       image.Sample(
                            builtin_texture_sampler,vec2(
                                // uv.x,uv.y-(i/iResolution.y))
                                uv.x,uv.y-(i/builtin_uv_size.y))
                        ).rgb
                    ))*.5+.5);   
    }
    c.rgb = sin(( vec3(0.,.33,.66)+c.rgb+uv.y)*6.28)*.5+.5;
    c.a = 1.0;
    fragColor = c;
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    if (OUTTT[3] > 0.1)
    mainImage(OUTTT, uv);
    return OUTTT;
}