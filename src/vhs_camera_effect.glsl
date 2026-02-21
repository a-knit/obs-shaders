void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    //vec2 uv = fragCoord/iResolution.xy;
    vec2 uv = fragCoord;
    
    //vec2 pos=vec2(0.5+0.5*sin(iTime),uv.y);
    //vec3 col=vec3(texture(iChannel0,uv));
    //vec3 col2=vec3(texture(iChannel0,pos))*0.2;
    vec2 pos=vec2(0.5+0.5*sin(builtin_elapsed_time),uv.y);
    vec3 col=vec3(image.Sample(builtin_texture_sampler, uv));
    vec3 col2=vec3(image.Sample(builtin_texture_sampler, pos))*0.2;
    col+=col2;
    
    
    // Output to screen
    fragColor = vec4(col,1.0);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    mainImage(OUTTT, uv);
    return OUTTT;
}