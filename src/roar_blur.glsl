#define ST 0.1
#define PI 3.141592

vec4 colrat(vec2 uv){
	// return texture(iChannel0,uv);
    return image.Sample(builtin_texture_sampler,uv);
}
float noise(vec2 n){
    // return texture(iChannel1,vec2(n.x*5.0,0.0)).x;
    // return fract(sin(n.x)*100000.0);
    vec2 st = vec2( dot(n,vec2(127.1,311.7)),
              dot(n,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123).x;
    // return image.Sample(vec4(noise,noise,noise,1),vec2(n.x*5.0,0.0)).x;
}

float atan2(float y, float x){
    if(x>0.0){
        return atan(y,x);
    }
    else if (y>0.0){
    	return PI/2.0-atan(x,y);
    }
    else if (y<0.0){
    	return -PI/2.0-atan(x,y);
    }
    else if (x==0.0 && y==0.0){
        return 0.0;
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    // vec2 uv = fragCoord/iResolution.xy;
    vec2 uv = fragCoord;
    vec2 uv_non_norm = fragCoord * builtin_uv_size;

    //vec4 t = texture(iChannel0,uv);
    
	vec4 col = vec4(0.0);
    
    // vec2 mid = vec2(iResolution.x/2.0,iResolution.y/2.0);
    // vec2 mid = vec2(builtin_uv_size.x/8.0,builtin_uv_size.y/10.0);
    // vec2 mid = vec2(builtin_uv_size.x/2.0,builtin_uv_size.y/2.0);
    vec2 mid = vec2(0.5, 0.5);
    // vec2 mid = vec2(iMouse.x,iMouse.y);
    
    float thet = (atan2(uv_non_norm.y-mid.y,uv_non_norm.x-mid.x));
    float dist = distance(uv_non_norm,mid);
    // float rad = noise(vec2(cos(thet+float(iFrame)/100.0),sin(thet+float(iFrame)/20.0)));
    float rad = noise(vec2(cos(thet+float(builtin_frame)/100.0),sin(thet+float(builtin_frame)/20.0)));
    
    // float r = 2.0*sin(float(iFrame)/30.0);
    float r = 2.0*sin(float(builtin_frame)/30.0);
    //float r = 0.5;
    
    float t = 0.0;
    for(float a0 = 0.0; a0<PI; a0+=ST){
    	col += colrat(uv+vec2(cos(thet),sin(thet))*r*0.0002*dist*dist*0.006*rad*(cos(a0)));
    	t ++;
    }
       
    col /= t;
    
    // Output to screen
    fragColor = vec4(col.xyz,1.0);
}

float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 OUTTT = image.Sample(builtin_texture_sampler, uv);
    mainImage(OUTTT, uv);
    // float x = noise(uv);
    // return vec4(x,x,x,1);
    return OUTTT;
}