const float EDGE_OR_CORNER_DETECT = 0.7; // 0 for corner, 1 for edge

const float WINDOW_FILTER_WIDTH = 2.0; // max 6.0

#define WINDOW_SIZE 3 // needs to be int

#define HALF_WINDOW_SIZE_MINUS_ONE 1.0 // needs to be float

const float SHOW_BACKGROUND = 0.25; // 0.0 for no background, 1.0 for all background

const vec2 webcam_resolution = vec2(320.0, 240.0);
const mat3 to_yuvish = mat3(0.299, -0.14713, 0.615,
                          0.587, -0.28886, -0.51499,
                          0.114, 0.436, -0.10001);
const mat3 from_yuvish = mat3(1.0, 1.0, 1.0,
                              0.0, -0.39465, 2.03211,
                              1.13983, -0.58060, 0.0);
vec3 YUV(in vec2 fragCoord) {
    
    return to_yuvish * texture(iChannel0, fragCoord / iResolution.xy).rgb;
}

float Yval(in vec2 fragCoord) {
    return YUV(fragCoord).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // mirror flip (sorry this is before variable declarations)
    
    fragCoord.x = iResolution.x - fragCoord.x;
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    
    mat2 M = mat2(0.0);
    
    vec2 scale = iResolution.xy / min(iResolution.xy, webcam_resolution.xy);
    
    vec2 off = vec2(-1.0 * HALF_WINDOW_SIZE_MINUS_ONE);
    for (int i = 0; i < WINDOW_SIZE; ++i) {
        off.y = -1.0 * HALF_WINDOW_SIZE_MINUS_ONE;
        off.x += 1.0;
        for (int j = 0; j < WINDOW_SIZE; ++j) {
            off.y += 1.0;
            
            float weight = smoothstep(WINDOW_FILTER_WIDTH, 0.0, length(off));
    
	    	float Ix = 0.5 * (Yval(fragCoord + scale * (off + vec2(1.0, 0.0))) - 
            	              Yval(fragCoord + scale * (off - vec2(1.0, 0.0))));
    		float Iy = 0.5 * (Yval(fragCoord + scale * (off + vec2(0.0, 1.0))) - 
            	              Yval(fragCoord + scale * (off - vec2(0.0, 1.0))));
        
         	M += weight * mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy);
        }
    }

//    mat2 M = mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy);
    
    float A = 1.0;
    float B = -M[0][0] - M[1][1];
    float C = M[0][0] * M[1][1] - M[0][1] * M[1][0];

    float l1 = (-B + sqrt(B * B - 4.0 * A * C)) / (2.0 * A);
    float l2 = (-B - sqrt(B * B - 4.0 * A * C)) / (2.0 * A);
    
    float min_eig = min(abs(l1), abs(l2));
    float max_eig = max(abs(l1), abs(l2));
//	float min_eig = min(l1, l2);
    
    float eig_to_use = mix(min_eig, max_eig, EDGE_OR_CORNER_DETECT);

    // Time varying pixel color
    vec3 col = smoothstep(vec3(0.0), 0.1 * vec3(0.1, 0.2, 0.3), vec3(eig_to_use));
    vec3 raw_color = texture(iChannel0, uv).rgb;
    
    float col_mag = (dot(vec3(1.0), raw_color) / 3.0);
    col_mag = smoothstep(0.0, 1.0, col_mag);
    col_mag = smoothstep(0.0, 1.0, col_mag);
    raw_color = vec3(1.0) * col_mag;
    
    // col = vec3(1.0, 0.5, 0.0); uncomment to debug noise
    
    

    if (length(col) > 0.01) {
    float theta = 12.0 * simple_noise(0.5 * uv * iResolution.xy/iResolution.y, 2.0 * sin(0.5 * iTime));
    float ct = cos(theta);
    float st = sin(theta);
    mat3 color_mat = from_yuvish *
                     mat3(1.0, 0.0, 0.0,
                          0.0, ct, st,
                          0.0, -st, ct) *
                     to_yuvish;
    col = color_mat * col;
    }
    
    // raw_color += theta;
    // Output to screen
    fragColor = vec4(mix(raw_color, col, 1.0 - SHOW_BACKGROUND),1.0);
}