void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float s = sin(iTime * 12.);
	float l = .01;
    
    float r = texture(iChannel0, uv).x;
    float g = texture(iChannel0, uv + vec2(l*s,0.)).y;
    float b = texture(iChannel0, uv - vec2(0.,l*s)).z;
   
    fragColor = vec4(r,g,b,1.);
    
}