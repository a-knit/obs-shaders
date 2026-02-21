void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv = fragCoord;
    // vec4 c = texture(iChannel0,uv);
    vec4 c = image.Sample(builtin_texture_sampler,uv);
    // c = sin(uv.x*10.+c*cos(c*6.28+iTime+uv.x)*sin(c+uv.y+iTime)*6.28)*.5+.5;
    c = sin(uv.x*10.+c*cos(c*6.28+builtin_elapsed_time+uv.x)*sin(c+uv.y+builtin_elapsed_time)*6.28)*.5+.5;
    c.b+=length(c.rg);
	fragColor = c;
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}