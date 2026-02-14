float4 render(float2 uv) {
    // sample the source texture and return its color to be displayed
    vec4 fragColor = image.Sample(builtin_texture_sampler, uv);
    // uv -= 0.5;

	vec3 colorA = vec3(2, 2, 0);
	vec3 colorB = vec3(0, 2, 2);

	// if (uv.y < .5) {
	// 	fragColor = vec4(colorA, 1);
	// } else {
	// 	fragColor = vec4(colorB, 1);
	// }

	uv.x *= 0.0005 * (int(builtin_frame) % 2000);
	uv.y *= 0.0005 * (int(builtin_frame) % 2000);

	if (uv.x < 1) {
		fragColor = image.Sample(builtin_texture_sampler, uv);	
	} else {
		fragColor = vec4(colorA, 1);
	}
	// vec3 pixel = vec3(1);
	// const float tickWidth = 0.1;
	// for(float i=-2.0; i<2.0; i+=tickWidth) {
	// 	// "i" is the line coordinate.
	// 	if(abs(uv.x - i)<0.004) pixel = colorA;
	// 	if(abs(uv.y - i)<0.004) pixel = colorA;
	// }
	// // Draw the axes
	// if( abs(uv.x)<0.006 ) pixel = colorB;
	// if( abs(uv.y)<0.007 ) pixel = colorB;
	
	// fragColor = vec4(pixel, 1.0);
    return fragColor;
}