void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    vec2 xy = fragCoord.xy;
    
    
    // xy.x = xy.x / iResolution.x;
    // xy.y = xy.y / iResolution.y;
    // xy.x = xy.x / builtin_uv_size.x;
    // xy.y = xy.y / builtin_uv_size.y;
    
    // vec4 texColor = texture(iChannel0,xy);
    vec4 texColor = image.Sample(builtin_texture_sampler, fragCoord.xy);
    
    float origRed = texColor.r;
    float origGreen = texColor.g;
    float origBlue = texColor.b;
    
    
    texColor.r *= 0.3;
    texColor.g *= 0.59;
    texColor.b *= 0.11;
    
    float grey = texColor.r + texColor.g + texColor.b;
    
    
    
    // fragColor.r = ((origRed - grey)/2.0)*(sin(iTime*5.0)) + ((grey+origRed)/2.0);
    // fragColor.g = ((origGreen - grey)/2.0)*(sin(iTime*5.0)) + ((grey+origGreen)/2.0);
    // fragColor.b = ((origBlue - grey)/2.0)*(sin(iTime*5.0)) + ((grey+origBlue)/2.0);
    fragColor.r = ((origRed - grey)/2.0)*(sin(builtin_elapsed_time)) + ((grey+origRed)/2.0);
    fragColor.g = ((origGreen - grey)/2.0)*(sin(builtin_elapsed_time)) + ((grey+origGreen)/2.0);
    fragColor.b = ((origBlue - grey)/2.0)*(sin(builtin_elapsed_time)) + ((grey+origBlue)/2.0);
    fragColor.a = 1.;
    
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}