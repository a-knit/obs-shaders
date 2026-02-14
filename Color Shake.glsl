// original - https://www.shadertoy.com/view/Xt2SWK

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
    
    float s = sin(builtin_elapsed_time * 12.);
	float l = .01;
    
    float r = image.Sample(builtin_texture_sampler, uv).x;
    float g = image.Sample(builtin_texture_sampler, uv + vec2(l*s,0.)).y;
    float b = image.Sample(builtin_texture_sampler, uv - vec2(0.,l*s)).z;
   
    fragColor = vec4(r,g,b,1.);
    
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}