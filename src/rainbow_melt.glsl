

// Function to convert RGB to luminance
float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

// Pseudo-random generator
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 getEffectedColor(vec2 baseUv, float time, vec2 resolution, float caAmount) {
    float distortionStrength = 0.012;
    float aspect = resolution.x / resolution.y;

    vec2 distortedUvLocal = baseUv;
    distortedUvLocal.x += sin(baseUv.y * 30.0 + time * 1.5) * distortionStrength / aspect;
    distortedUvLocal.y += cos(baseUv.x * 30.0 * aspect + time * 2.0) * distortionStrength;

    vec3 colorLocal;
    colorLocal.r = image.Sample(builtin_texture_sampler, distortedUvLocal + vec2(caAmount, 0.0)).r;
    colorLocal.g = image.Sample(builtin_texture_sampler, distortedUvLocal).g;
    colorLocal.b = image.Sample(builtin_texture_sampler, distortedUvLocal - vec2(caAmount, 0.0)).b;

    return colorLocal;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float edgeWidth = 3.0; // Neon edge width
    float caAmountBase = 0.003;
    float glAmount = 0.9975;
    float glStrength = 0.99850;
    float colorOffsetStrength = 3.0;

    vec2 uv = fragCoord.xy;
    float time = builtin_elapsed_time;
    float caAmount = caAmountBase * cos(time) * colorOffsetStrength;

    vec3 baseViewColor = getEffectedColor(uv, time, builtin_uv_size.xy, caAmount);
    vec2 pixel = (edgeWidth * sin(time)) / builtin_uv_size.xy;

    float centerLum = luminance(baseViewColor);
    float topLum = luminance(getEffectedColor(uv + vec2(0.0, pixel.y), time, builtin_uv_size.xy, caAmount));
    float leftLum = luminance(getEffectedColor(uv - vec2(pixel.x, 0.0), time, builtin_uv_size.xy, caAmount));
    float rightLum = luminance(getEffectedColor(uv + vec2(pixel.x, 0.0), time, builtin_uv_size.xy, caAmount));
    float bottomLum = luminance(getEffectedColor(uv - vec2(0.0, pixel.y), time, builtin_uv_size.xy, caAmount));

    float dx = -leftLum + rightLum;
    float dy = -topLum + bottomLum;
    float edge = sqrt(dx * dx + dy * dy);

    edge = smoothstep(0.08, 0.30, edge);
    edge *= smoothstep(0.0, 0.1, centerLum);

    vec3 neonColor = 0.5 + 0.5 * cos(time * 1.2 + uv.xyx * 10.0 + vec3(0.0, 2.0, 4.0));

    float glitter = random(uv + mod(time * 0.4, 10.0));
    glitter = smoothstep(glAmount, glStrength, glitter);

    vec3 finalColor = mix(baseViewColor, neonColor, edge);
    finalColor += glitter * neonColor;

    fragColor = vec4(finalColor, 1.0);
}

float4 render(float2 uv) {
    vec4 output = image.Sample(builtin_texture_sampler, uv);
    mainImage(output, uv);
    return output;
}
