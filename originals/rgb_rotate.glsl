vec4 colorShift(vec4 tex,vec2 uv){
	vec4 frag;
    float intensity = 0.1;
    float time = 1.0;
    frag.r = texture(iChannel0,vec2(uv.x + sin(iTime * time) * intensity,uv.y + cos(iTime * time)  * intensity)).r;
    frag.g = tex.g;
    frag.b = texture(iChannel0,vec2(uv.x - sin(iTime * time)  * intensity,uv.y - cos(iTime * time)  * intensity)).b;
    frag.a = tex.a;
    return frag;                
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec4 tex = texture(iChannel0,uv); 
    

    // Output to screen
    fragColor = colorShift(tex,uv);
}