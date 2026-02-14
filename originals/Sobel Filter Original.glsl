mat3 k1 = mat3( 1,  2,  1,
                0,  0,  0,
               -1, -2, -1);

mat3 k2 = mat3( 0,  1,  2,
               -1,  0,  1,
               -2, -1,  0);

mat3 k3 = mat3(-1,  0,  1,
               -2,  0,  2,
               -1,  0,  1);

mat3 k4 = mat3(-2, -1,  0,
               -1,  0,  1,
                0,  1,  2);

mat3 k5 = mat3(-1, -2, -1,
                0,  0,  0,
                1,  2,  1);

mat3 k6 = mat3( 0, -1, -2,
                1,  0, -1,
                2,  1,  0);

mat3 k7 = mat3( 1,  0, -1,
                2,  0, -2,
                1,  0, -1);

mat3 k8 = mat3( 2,  1,  0,
                1,  0, -1,
                0, -1, -2);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 pixelSize = vec2(1,1) / iResolution.xy;
    
    vec3 sum = vec3(0,0,0);
    
    mat3 kernel = k1;
    
    // Modulo operator doesn't work on the iOS version of WebGL
    int fastTime = int(iTime*15.0);
    int floorDivTime = fastTime / 8;
    int modVal = fastTime - (floorDivTime * 8);
    
    if (modVal==1) {
        kernel = k2;
    } else if (modVal==2) {
        kernel = k3;
    } else if (modVal==3) {
        kernel = k4;
    } else if (modVal==4) {
        kernel = k5;
    } else if (modVal==5) {
        kernel = k6;
    } else if (modVal==6) {
        kernel = k7;
    } else if (modVal==7) {
        kernel = k8;
    } 
    
    for (int dy = -1; dy<=1; dy++) {
	    for (int dx = -1; dx<=1; ++dx) {
            vec2 pixelOff = pixelSize * vec2(dx, dy);
            vec2 tex_uv = uv + pixelOff;
            vec3 textureValue = texture(iChannel0, tex_uv).rgb;
            sum += (kernel[dx+1][dy+1] * textureValue);
        }
    }
    
	vec3 col = sum;
	
    
    
	fragColor = vec4(col,1.);
}