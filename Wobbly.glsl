void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    // vec2 uv = fragCoord/iResolution.xy;
    // vec2 uv = fragCoord/builtin_uv_size.xy;
    vec2 uv = fragCoord;

    // uv.y -= sin(iTime + uv.y * 10.0) * 0.05;
    // uv.x += cos(iTime + uv.x * 10.0) * 0.05;
    uv.y -= sin(builtin_elapsed_time + uv.y * 10.0) * 0.05;
    uv.x += cos(builtin_elapsed_time + uv.x * 10.0) * 0.05;

    // vec4 tex = texture(iChannel0,uv);
    // vec4 tex = image.Sample(builtin_texture_sampler,uv);
    vec4 tex = image.Sample(builtin_texture_sampler,uv);

    // Output to screen
    fragColor = tex;
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}