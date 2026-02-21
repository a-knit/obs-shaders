

#define MAIN_TRIANGLE_HEIGHT .5f
#define TWOPI 6.28318530718f
#define AA 0.001f
#define SIXTY_DEGREES 1.0471975512f

#define u_TimeScaleModifier 0.1f
#define u_HexRadius .8f
#define u_HexBorderThickness 0.f
#define u_HexTriangleThickness 0.f
#define u_HexCenterRadius 0.0f
#define u_KaleidoscopeLevels 3
#define u_BorderColor vec4(1.f, 1.f, 1.f, 1.f)
#define u_TriangleColor vec4(1.f, 1.f, 1.f, 1.f)
#define u_HexCenterColor vec4(1.f, 1.f, 1.f, 1.f)

// from https://www.shadertoy.com/view/4djSRW
float hash(vec2 p)
{
    float val = sin(dot(p, vec2(12.9898f, 78.233f))) * 43758.5453f;
    return val - floor(val);
}

struct AspectRatioData {
    mat2x2 scaleMatrix;
    mat2x2 inverseScaleMatrix;
    float aspectRatio;
};

AspectRatioData getAspectRatioData(vec2 uvSize) {
    float aspectRatio = uvSize.x / uvSize.y;
    AspectRatioData aspectRatioData;
    aspectRatioData.aspectRatio = aspectRatio;
    aspectRatioData.scaleMatrix = mat2x2(
        aspectRatio, 0.f,
        0.f, 1.f
    );
    
    aspectRatioData.inverseScaleMatrix = mat2x2(
        1.f / aspectRatio, 0.f,
        0.f, 1.f
    );

    return aspectRatioData;
}

bool isHexCenter(vec2 pos, float hexXIncrement, float hexYIncrement) {
    float columnIndex = round(pos.x / hexXIncrement);
    float rowIndex = round(pos.y / hexYIncrement);
    return int(round(mod(abs(columnIndex), 2.f))) == int(round(mod(abs(rowIndex), 2.f)));
}

float getOffsetAngle(vec2 first, vec2 second) {
    vec2 offsetVec = second - first;
    float angle = atan(offsetVec.y / offsetVec.x);
    
    
    if (first.x < second.x) {
        angle = TWOPI / 2.f + angle;
    } else if (first.y > second.y) {
        angle = TWOPI + angle;
    }
    
    return angle;
}

mat2x2 createRotationMatrix(float rotation) {
    return mat2x2(
        cos(rotation), -sin(rotation),
        sin(rotation), cos(rotation)
    );
}

vec3 vec2Tovec3(vec2 vec) {
    return vec3(vec.x, vec.y, 0.f);
}

struct KaleidSampleData {
    vec4 color;
    vec2 uv;
};

vec2 getHexCenter(vec2 aspectUV, 
                    vec2 leftBottom, 
                    vec2 leftTop, 
                    vec2 rightBottom, 
                    vec2 rightTop,
                    float aspectHexGridXIncrement, 
                    float hexGridYIncrement,
                    float aspectHexRadius) {
    vec2 hexCenter = vec2(-1.f, -1.f); 

    // // if uv is close to hexCenter -> hexDiagRight || hexDiagLeft, return border color
    if (isHexCenter(leftBottom, aspectHexGridXIncrement, hexGridYIncrement)) {
        vec2 hexDiagRight = leftBottom + vec2(aspectHexRadius, 0.f);
        vec2 hexDiagLeft = leftTop + vec2(aspectHexRadius / 2.f, 0.f);
        vec2 sharedEdgeVector = normalize(vec2(hexDiagLeft - hexDiagRight));
        vec2 sharedToRightTopVector = normalize(vec2(rightTop - hexDiagRight));
        vec2 sharedToUVVector = normalize(vec2(aspectUV - hexDiagRight));

        vec3 crossRightTop = cross(vec2Tovec3(sharedEdgeVector), 
                                    vec2Tovec3(sharedToRightTopVector));
        vec3 crossUV = cross(vec2Tovec3(sharedEdgeVector), 
                                vec2Tovec3(sharedToUVVector));

        hexCenter = (crossRightTop.z == crossUV.z) || 
            (crossRightTop.z < 0.f && crossUV.z < 0.f) || 
            (crossRightTop.z > 0.f && crossUV.z > 0.f) ? rightTop : leftBottom;
    } else {
        vec2 hexDiagRight = leftTop + vec2(aspectHexRadius, 0.f);
        vec2 hexDiagLeft = rightBottom - vec2(aspectHexRadius, 0.f);
        vec2 sharedEdgeVector = normalize(vec2(hexDiagRight - hexDiagLeft));
        vec2 sharedToRightBottomVector = normalize(vec2(rightBottom - hexDiagLeft));
        vec2 sharedToUVVector = normalize(vec2(aspectUV - hexDiagLeft));

        vec3 crossRightBottom = cross(vec2Tovec3(sharedEdgeVector), 
                                        vec2Tovec3(sharedToRightBottomVector));
        vec3 crossUV = cross(vec2Tovec3(sharedEdgeVector), 
                                vec2Tovec3(sharedToUVVector));

        hexCenter = crossRightBottom.z == crossUV.z || 
            (crossRightBottom.z < 0.f && crossUV.z < 0.f) || 
            (crossRightBottom.z > 0.f && crossUV.z > 0.f) ? rightBottom : leftTop;
    }

    return hexCenter;
}

KaleidSampleData getKaleidoscopedUV(vec2 uv, 
                        AspectRatioData aspectRatioData, 
                        float hexRadius, 
                        float shortRadius, 
                        float angle,
                        float hexGridXIncrement,
                        float hexGridYIncrement) 
{
    vec2 aspectUV = uv * aspectRatioData.scaleMatrix;

    float aspectHexGridXIncrement = hexGridXIncrement;

    float leftEdge = floor(aspectUV.x / aspectHexGridXIncrement) * aspectHexGridXIncrement;
    float rightEdge = leftEdge + aspectHexGridXIncrement;
    float bottomEdge = floor(aspectUV.y / hexGridYIncrement) * hexGridYIncrement;
    float topEdge = bottomEdge + hexGridYIncrement;

    KaleidSampleData kaleidSampleData;
    kaleidSampleData.color = vec4(0.f, 0.f, 0.f, 0.f);
    kaleidSampleData.uv = vec2(0.f, 0.f);
    
    vec2 leftBottom = vec2(leftEdge, bottomEdge);
    vec2 leftTop = vec2(leftEdge, topEdge);
    vec2 rightTop = vec2(rightEdge, topEdge);
    vec2 rightBottom = vec2(rightEdge, bottomEdge);

    float aspectHexRadius = hexRadius;
    vec2 hexCenter = getHexCenter(aspectUV,
                            leftBottom, 
                            leftTop, 
                            rightBottom, 
                            rightTop, 
                            aspectHexGridXIncrement, 
                            hexGridYIncrement,
                            aspectHexRadius);

    float offsetAngle = getOffsetAngle(hexCenter, aspectUV);
    // mulitplying by 5 rotates the uv so the default orientation (0 radians) is facing downward
    offsetAngle = mod(TWOPI - offsetAngle + 5.f * TWOPI / 6.f, TWOPI);
    
    int offsetIndex = int(round(floor(offsetAngle / angle)));
         
    //kaleidSampleData.color = vec4(float(offsetIndex) / 6.f, 0.f, 0.f, 1.f);

    float rotation = float(offsetIndex) * angle;
    
    mat2x2 rotationMatrix = createRotationMatrix(rotation);

    vec2 kaleidUV = (aspectUV - hexCenter) * rotationMatrix;
    // kaleidUV is below 0,0 (upper left) with the perfect triangle inverted below 
    // (y flipped in hlsl)

    float aspectRatio = aspectRatioData.aspectRatio;
    float sampleY = kaleidUV.y / shortRadius;
    // this identifies where it is in the triangle, not the image
    float triangleXCoord = (kaleidUV.x + hexRadius / 2.f) / hexRadius; 

    float imageWidthAtScale = shortRadius * aspectRatio;
    float imageTriangleDelta = imageWidthAtScale - hexRadius;
    float sampleX = (imageTriangleDelta / 2.f + triangleXCoord * hexRadius) / imageWidthAtScale;

    if (offsetIndex % 2 == 1) {
        sampleX = 1.f - sampleX;
    }

    kaleidSampleData.uv = vec2(clamp(sampleX, 0.f, 1.f), clamp(sampleY, 0.f, 1.f));

    if (u_HexTriangleThickness > .0001f) {
        mat2x2 triangleTestRotationMatrix = createRotationMatrix(SIXTY_DEGREES / 2.f);
        float thicknessCheck = u_HexTriangleThickness * .25f;

        vec2 relocatedUV = kaleidUV * createRotationMatrix(SIXTY_DEGREES / 2.f);
        float colorVal = smoothstep(thicknessCheck + AA, thicknessCheck - AA, abs(relocatedUV.x));
        kaleidSampleData.color = mix(kaleidSampleData.color, u_TriangleColor, colorVal);

        relocatedUV = kaleidUV * createRotationMatrix(-SIXTY_DEGREES / 2.f);
        colorVal = smoothstep(thicknessCheck + AA, thicknessCheck - AA, abs(relocatedUV.x));
        kaleidSampleData.color = mix(kaleidSampleData.color, u_TriangleColor, colorVal);
    }

    if (u_HexBorderThickness > .0001f) {
        float borderThickness = 1.f - u_HexBorderThickness * .5f;
        float borderVal = smoothstep(borderThickness - AA, borderThickness + AA, kaleidSampleData.uv.y);
        kaleidSampleData.color = mix(kaleidSampleData.color, u_BorderColor, borderVal);
    }   

    if (u_HexCenterRadius > .0001f) {
        float centerDist = distance(aspectUV, hexCenter);
        float colorVal = smoothstep(u_HexCenterRadius * .5f + AA, 
                                            u_HexCenterRadius * .5f - AA, centerDist);

        kaleidSampleData.color = mix(kaleidSampleData.color, u_HexCenterColor, colorVal);
    }

    return kaleidSampleData;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // AspectRatioData aspectRatioData = getAspectRatioData(iResolution.xy);
    // vec2 ar = vec2(1920,1440);
    AspectRatioData aspectRatioData = getAspectRatioData(builtin_uv_size.xy/300.0);

    KaleidSampleData kaleidSampleData;
    // kaleidSampleData.uv = fragCoord/iResolution.xy;
    kaleidSampleData.uv = fragCoord;

    float shortRadius = u_HexRadius * sin(SIXTY_DEGREES);

    float hexGridXIncrement = 1.5f * u_HexRadius;
    float hexGridYIncrement = shortRadius;

    // float timeScale = iTime * .5f * u_TimeScaleModifier;
    float timeScale = builtin_elapsed_time * .5f * u_TimeScaleModifier;

    vec4 borderColorAgg = vec4(0.f, 0.f, 0.f, 0.f);
    float borderColorVal = 0.f;

    for (int i=0; i<u_KaleidoscopeLevels; i++) {
        float noiseVal = hash(vec2(float(i), 0.f));
        kaleidSampleData.uv += vec2(sin(timeScale + noiseVal), timeScale);
        kaleidSampleData = getKaleidoscopedUV(
            kaleidSampleData.uv, 
            aspectRatioData, 
            u_HexRadius, 
            shortRadius, 
            SIXTY_DEGREES,
            hexGridXIncrement,
            hexGridYIncrement);

        borderColorAgg += kaleidSampleData.color;
    }
  
    // vec4 outColor = mix(texture(iChannel0, kaleidSampleData.uv), borderColorAgg, borderColorAgg.a);
    vec4 outColor = mix(image.Sample(builtin_texture_sampler, kaleidSampleData.uv), borderColorAgg, borderColorAgg.a);

    outColor.a = 1.f;
    fragColor = outColor;
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    mainImage(OUTTT, uv);
    return OUTTT;
}