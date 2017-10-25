

	        uniform vec2 res;
	        uniform sampler2D bufferTexture;
	        uniform vec3 brush;
	        uniform float time;

	        uniform float dA;
	        uniform float dB;
	        uniform float feed;
	        uniform float k;

	        uniform float brushSize;
	        uniform float flow;

	        uniform int clear;
	        uniform int seedRandom;
	        uniform float seedScale;
	        uniform float seedThreshold;

	        int count = 0;

	  		vec3 mod289(vec3 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			vec2 mod289(vec2 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			vec3 permute(vec3 x) {
			  return mod289(((x*34.0)+1.0)*x);
			}

			float snoise(vec2 v) {
			  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
			                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
			                     -0.577350269189626,  // -1.0 + 2.0 * C.x
			                      0.024390243902439); // 1.0 / 41.0
			// First corner
			  vec2 i  = floor(v + dot(v, C.yy) );
			  vec2 x0 = v -   i + dot(i, C.xx);

			// Other corners
			  vec2 i1;
			  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
			  //i1.y = 1.0 - i1.x;
			  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
			  // x0 = x0 - 0.0 + 0.0 * C.xx ;
			  // x1 = x0 - i1 + 1.0 * C.xx ;
			  // x2 = x0 - 1.0 + 2.0 * C.xx ;
			  vec4 x12 = x0.xyxy + C.xxzz;
			  x12.xy -= i1;

			// Permutations
			  i = mod289(i); // Avoid truncation effects in permutation
			  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
					+ i.x + vec3(0.0, i1.x, 1.0 ));

			  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
			  m = m*m ;
			  m = m*m ;

			// Gradients: 41 points uniformly over a line, mapped onto a diamond.
			// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

			  vec3 x = 2.0 * fract(p * C.www) - 1.0;
			  vec3 h = abs(x) - 0.5;
			  vec3 ox = floor(x + 0.5);
			  vec3 a0 = x - ox;

			// Normalise gradients implicitly by scaling m
			// Approximation of: m *= inversesqrt( a0*a0 + h*h );
			  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

			// Compute final noise value at P
			  vec3 g;
			  g.x  = a0.x  * x0.x  + h.x  * x0.y;
			  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			  return 130.0 * dot(m, g);
			}

	        void main()
	        {
	            // load current values for a and b
	            vec4 currentColor = texture2D(bufferTexture, gl_FragCoord.xy / res.xy);
	            float a = currentColor.r;
	            float b = currentColor.g;

	            //Get the distance of the current pixel from the brush
	            float dist = distance(brush.xy, gl_FragCoord.xy);
	            if (dist < brushSize)  {
	            	float ratio = 1.0 - dist/brushSize;
	            	b += 0.5 * ratio * brush.z;
	            }

	            if (clear == 1) {
	            	a = 1.0;
	            	b = 0.0;
	            }

	            if (seedRandom == 1) {
	            	a = 0.0;
	            	b = snoise(vec2((gl_FragCoord.x + time*100.0) * seedScale, (gl_FragCoord.y + time*100.0) * seedScale));
	            	if (b < seedThreshold) b = 0.0;
	            }

	            float offset = 1.0;

	            // get pixels from surrounding grid
	            vec4 N = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x, gl_FragCoord.y/res.y - offset/res.y));
	            vec4 S = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x, gl_FragCoord.y/res.y + offset/res.y));
	            vec4 E = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x + offset/res.x, gl_FragCoord.y/res.y));
	            vec4 W = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x - offset/res.x, gl_FragCoord.y/res.y));

	            vec4 NE = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x + offset/res.x, gl_FragCoord.y/res.y + offset/res.y));
	            vec4 NW = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x - offset/res.x, gl_FragCoord.y/res.y + offset/res.y));
	            vec4 SE = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x + offset/res.x, gl_FragCoord.y/res.y - offset/res.y));
	            vec4 SW = texture2D(bufferTexture, vec2(gl_FragCoord.x/res.x - offset/res.x, gl_FragCoord.y/res.y - offset/res.y));

	            // diffusion values
	            float diff1 = 0.2*flow;
	            float diff2 = 0.05*flow;

	            // calculate laplace of A
	            float lapA = 0.0;
	            lapA += a * -1.0;
	            lapA += N.r * diff1;
	            lapA += S.r * diff1;
	            lapA += E.r * diff1;
	            lapA += W.r * diff1;
	            lapA += NE.r * diff2;
	            lapA += NW.r * diff2;
	            lapA += SE.r * diff2;
	            lapA += SW.r * diff2;


	            // calculate laplace of B
	            float lapB = 0.0;
	            lapB += b * -1.0;
	            lapB += N.g * diff1;
	            lapB += S.g * diff1;
	            lapB += E.g * diff1;
	            lapB += W.g * diff1;
	            lapB += NE.g * diff2;
	            lapB += NW.g * diff2;
	            lapB += SE.g * diff2;
	            lapB += SW.g * diff2;


	            // calculate diffusion reaction
	            a += ((dA * lapA) - (a*b*b) + (feed * (1.0-a))) * 1.0;
	            b += ((dB * lapB) + (a*b*b) - ((k + feed) * b)) * 1.0;


	            a = clamp(a, 0.0, 1.0);
	            b = clamp(b, 0.0, 1.0);


	            vec4 newColor = vec4(a, b, 0.0, 1.0);
	            gl_FragColor = newColor;
			}



	    
