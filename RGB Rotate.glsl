// original - https://www.shadertoy.com/view/wstGRS

vec4 colorShift(vec4 tex,vec2 uv){
	vec4 frag;
    float intensity = 0.1;
    float time = 1.0;
    frag.r = image.Sample(builtin_texture_sampler,vec2(uv.x + sin(builtin_elapsed_time * time) * intensity,uv.y + cos(builtin_elapsed_time * time)  * intensity)).r;
    frag.g = tex.g;
    frag.b = image.Sample(builtin_texture_sampler,vec2(uv.x - sin(builtin_elapsed_time * time)  * intensity,uv.y - cos(builtin_elapsed_time * time)  * intensity)).b;
    frag.a = tex.a;
    return frag;                
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord;

    vec4 tex = image.Sample(builtin_texture_sampler,uv); 
    

    // Output to screen
    fragColor = colorShift(tex,uv);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}