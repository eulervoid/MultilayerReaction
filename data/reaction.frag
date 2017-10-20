// Conway's game of life

#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;

float dA = .419;
float dB = 0.5;
float kill = 0.092;
float feed = 0.0545;

mat3 kernel = mat3 ( 0.5, 0.2, 0.5,
										 0.2, -1., 0.2,
										 0.5, 0.2, 0.5 );

vec4 laplace() {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 pixel = 1./resolution;
	vec4 sum = vec4(0, 0, 0, 0);
	sum += texture2D(ppixels, position + pixel * vec2(-1., -1.)) * kernel[0][2];
	sum += texture2D(ppixels, position + pixel * vec2(-1., 0.)) * kernel[0][1];
	sum += texture2D(ppixels, position + pixel * vec2(-1., 1.)) * kernel[0][0];
	sum += texture2D(ppixels, position + pixel * vec2(1., -1.)) * kernel[2][2];
	sum += texture2D(ppixels, position + pixel * vec2(1., 0.)) * kernel[2][1];
	sum += texture2D(ppixels, position + pixel * vec2(1., 1.)) * kernel[2][0];
	sum += texture2D(ppixels, position + pixel * vec2(0., -1.)) * kernel[1][2];
	sum += texture2D(ppixels, position + pixel * vec2(0., 1.)) * kernel[1][0];
	sum += texture2D(ppixels, position) * kernel[1][1];
	return sum;
}

vec4 next() {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec4 current = texture2D(ppixels, position);
	vec4 lapl = laplace();
	float a = current.r;
	float lapA = lapl.r;
	float b = current.b;
	float lapB = lapl.b;
	vec4 next = vec4(0);
	next.r = a + ((dA * lapA) - (a * b * b) + (feed * (1. - a)));
	next.g = 0.0;
	next.b = b + ((dB * lapB) + (a * b * b) - ((kill+feed) * b));
	next.a = 1.0;
	return next;
}

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );

	if (length(position-mouse) < 0.04) {
			gl_FragColor = next()+vec4(0, 0, 1., 1.);
	}
  else gl_FragColor = next();

}
