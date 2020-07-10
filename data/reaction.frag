// Conway's game of life

precision highp float;

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;
uniform sampler2D tex;
uniform int clear;

uniform float dA;
uniform float dB;
uniform float kill;
uniform float feed;
uniform float noiseamt;
uniform float noisemv;
uniform float noisesize;
uniform float flow;
uniform bool brush;

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v) {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
  }


float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                * 43758.5453123);
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( random( i + vec2(0.0,0.0) ),
                     random( i + vec2(1.0,0.0) ), u.x),
                mix( random( i + vec2(0.0,1.0) ),
                     random( i + vec2(1.0,1.0) ), u.x), u.y);
}

mat3 kernel = mat3 ( 0.05, 0.2, 0.05,
										 0.2,  -1., 0.2,
										 0.05, 0.2, 0.05 );

vec4 laplace() {
	vec4 sum = vec4(0);
	for(int i=0; i<3; i++) {
		for(int j=0; j<3; j++) {
			vec2 pos = (gl_FragCoord.xy + vec2((float(i)-1.), (float(j)-1.)))/resolution.xy;
			sum += texture2D(ppixels, pos) * kernel[j][i] * flow;
		}
	}
	return sum;
}

vec2 warpedPos(vec2 offset) {
  return vec2(gl_FragCoord.xy + offset)/resolution.xy;
}

vec4 next() {
  //vec2 texcoord = vec2(1.,1.)-(gl_FragCoord.xy/resolution.xy);
  //texcoord.x = 1.-texcoord.x;
  //vec4 texpoint = texture2D(tex, vec2(1., 1.)-(gl_FragCoord.xy/resolution.xy));
  //if(texpoint.g >= .2) return vec4(0., 0., 0., 1.);
	vec4 current = texture2D(ppixels, (gl_FragCoord.xy/resolution.xy));
	vec4 lapl = laplace();
	float a = current.r;
	float lapA = lapl.r;
	float b = current.g;
	float lapB = lapl.g;
	float nfeed = feed + snoise(vec3(noisesize*.5*gl_FragCoord.xy/resolution.xy, time*noisemv)) * noiseamt;
	float nkill = kill + sin(time*noisemv/100.) * 0.03;
	//float ndB = clamp(dB - texpoint.g, 0., 1.);
	a = a + ((dA * lapA) - (a * b * b) + (nfeed * (1. - a)));
	b = b + ((dB * lapB) + (a * b * b) - ((nkill+nfeed) * b));
	a = clamp(a, 0.0, 1.0);
	b = clamp(b, 0.0, 1.0);
	return vec4(a, b, 0.0, 1.);
}

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	if (brush && length(position-mouse) < 0.02) {
			gl_FragColor = vec4(0., 1., 0, 1.);
	}
  else
	    gl_FragColor = next();

}
