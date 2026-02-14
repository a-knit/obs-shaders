//change the number of taps
#define taps 5.0

//uncomment below to toggle between light and dark
//#define light

//click and drag the mouse too!

#define tau 6.28

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	// vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv = fragCoord.xy;
    // vec4 c  = texture(iChannel0,uv);
    vec4 c  = image.Sample(builtin_texture_sampler,uv);
    // float t = iTime;
    float t = builtin_elapsed_time;
    // float d = .01+sin(t)*.01+iMouse/iResolution.x*.1;
    float d = .01+sin(t)*.01+10./builtin_uv_size.x*.1;
    for(float i = 0.; i<tau;i+=tau/taps){
        float a = i+t;
        // vec4 c2 = texture(iChannel0,vec2(uv.x+cos(a)*d,uv.y+sin(a)*d));
        vec4 c2 = image.Sample(builtin_texture_sampler,vec2(uv.x+cos(a)*d,uv.y+sin(a)*d));
        #ifdef light
        	c = max(c,c2);
        #else
        	c = min(c,c2);
        #endif
    }
	fragColor = c;
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}