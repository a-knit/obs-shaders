float nonlinearity(in float x) {
     x = mod(2.0 * x, 1.0);
     return x + 0.1 * x * x * (1.1 + 0.01 * x);
}

float hash12(vec2 x)
{
    return mod(13.3 + 201.1 * nonlinearity(302.2 * x.x + 123.7 * x.y + 11.1), 1.0);
}


float noise_term(in vec2 x, in float scale_val) {
    vec2 s = vec2(scale_val);
    vec2 x00 = x - mod(x, s);
    vec2 x01 = x + vec2(0.0, scale_val);
    x01 = x01 - mod(x01, s);
    vec2 x10 = x + vec2(scale_val, 0.0);
    x10 = x10 - mod(x10, s);
    vec2 x11 = x + s;
    x11 = x11 - mod(x11, s);
    
    float v00 = hash12(x00);
    float v01 = hash12(x01);
    float v10 = hash12(x10);
    float v11 = hash12(x11);
    
    vec2 uv = mod(x, s) / s;
    
    float yweight = smoothstep(0.0, 1.0, uv.y);
    float v1 = mix(v10, v11, yweight);
    float v0 = mix(v00, v01, yweight);
    
    float xweight = smoothstep(0.0, 1.0, uv.x);
    
    return mix(v0, v1, xweight);
}

float noise(in vec2 x, in float base_scale, in float space_decay, in float height_decay,
           in float shift_by) {
	float h = 1.0;
    float s = base_scale;

    float summation = 0.0;
    
    for (int i = 0; i < 3; ++i) {
    	summation = summation + h * noise_term(x + vec2(0.0, s * shift_by), s);
        s *= space_decay;
        h *= height_decay;
    }
    return summation;
}

float simple_noise(in vec2 uv, in float shift_by) {
  return noise(uv * 10.0, 5.0, 0.75, 0.75, shift_by);
}

vec2 noise2(in vec2 uv, in float shift_by) {
    return vec2(simple_noise(uv, shift_by),
                simple_noise(uv + vec2(0.0, 101.0), shift_by));
}