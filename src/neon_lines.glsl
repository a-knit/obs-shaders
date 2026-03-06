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

#define WINDOW_SIZE 3
#define HALF_WINDOW_SIZE_MINUS_ONE 1.0

vec3 YUV(in vec2 pixelCoord) {
    mat3 to_yuvish = mat3(0.299, -0.14713, 0.615,
                          0.587, -0.28886, -0.51499,
                          0.114, 0.436, -0.10001);
    vec2 uv = pixelCoord / builtin_uv_size.xy;
    return to_yuvish * image.Sample(builtin_texture_sampler, uv).rgb;
}

float Yval(in vec2 pixelCoord) {
    return YUV(pixelCoord).x;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float EDGE_OR_CORNER_DETECT = 0.7;
    float WINDOW_FILTER_WIDTH = 2.0;
    float SHOW_BACKGROUND = 0.25;
    vec2 webcam_resolution = vec2(320.0, 240.0);
    mat3 from_yuvish = mat3(1.0, 1.0, 1.0,
                            0.0, -0.39465, 2.03211,
                            1.13983, -0.58060, 0.0);
    mat3 to_yuvish = mat3(0.299, -0.14713, 0.615,
                          0.587, -0.28886, -0.51499,
                          0.114, 0.436, -0.10001);

    vec2 pixelCoord = fragCoord * builtin_uv_size.xy;
    vec2 uv = pixelCoord / builtin_uv_size.xy;

    mat2 M = mat2(0.0);
    vec2 scale = builtin_uv_size.xy / min(builtin_uv_size.xy, webcam_resolution.xy);

    vec2 off = vec2(-1.0 * HALF_WINDOW_SIZE_MINUS_ONE);
    for (int i = 0; i < WINDOW_SIZE; ++i) {
        off.y = -1.0 * HALF_WINDOW_SIZE_MINUS_ONE;
        off.x += 1.0;
        for (int j = 0; j < WINDOW_SIZE; ++j) {
            off.y += 1.0;

            float weight = smoothstep(WINDOW_FILTER_WIDTH, 0.0, length(off));

            float Ix = 0.5 * (Yval(pixelCoord + scale * (off + vec2(1.0, 0.0))) -
                              Yval(pixelCoord + scale * (off - vec2(1.0, 0.0))));
            float Iy = 0.5 * (Yval(pixelCoord + scale * (off + vec2(0.0, 1.0))) -
                              Yval(pixelCoord + scale * (off - vec2(0.0, 1.0))));

            M += weight * mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy);
        }
    }

    float A = 1.0;
    float B = -M[0][0] - M[1][1];
    float C = M[0][0] * M[1][1] - M[0][1] * M[1][0];

    float l1 = (-B + sqrt(B * B - 4.0 * A * C)) / (2.0 * A);
    float l2 = (-B - sqrt(B * B - 4.0 * A * C)) / (2.0 * A);

    float min_eig = min(abs(l1), abs(l2));
    float max_eig = max(abs(l1), abs(l2));
    float eig_to_use = mix(min_eig, max_eig, EDGE_OR_CORNER_DETECT);

    vec3 col = smoothstep(vec3(0.0), 0.1 * vec3(0.1, 0.2, 0.3), vec3(eig_to_use));
    vec3 raw_color = image.Sample(builtin_texture_sampler, uv).rgb;

    float col_mag = dot(vec3(1.0), raw_color) / 3.0;
    col_mag = smoothstep(0.0, 1.0, col_mag);
    col_mag = smoothstep(0.0, 1.0, col_mag);
    raw_color = vec3(1.0) * col_mag;

    if (length(col) > 0.01) {
        float theta = 12.0 * simple_noise(0.5 * uv * builtin_uv_size.xy / builtin_uv_size.y,
                                          2.0 * sin(0.5 * builtin_elapsed_time));
        float ct = cos(theta);
        float st = sin(theta);
        mat3 color_mat = from_yuvish *
                         mat3(1.0, 0.0, 0.0,
                              0.0, ct, st,
                              0.0, -st, ct) *
                         to_yuvish;
        col = color_mat * col;
    }

    fragColor = vec4(mix(raw_color, col, 1.0 - SHOW_BACKGROUND), 1.0);
}

float4 render(float2 uv) {
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}
