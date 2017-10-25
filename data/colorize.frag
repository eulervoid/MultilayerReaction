precision highp float;

#define PROCESSING_TEXTURE_SHADER

uniform vec2 resolution;
uniform sampler2D texture;

uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
float scale = 1.;

float map(float value, float inMin, float inMax, float outMin, float outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

void main(void)
{
  float invScale = 1.0/scale;
  vec2 uv = (gl_FragCoord.xy / resolution / scale) + ((1.0/scale*0.5 + (0.5 - 1.0/scale)));

  vec3 black = vec3(0.0, 0.0, 0.0);
  vec3 targetColor = vec3(0.0, 0.0, 0.0);
  float sourceRamp = texture2D( texture, uv ).g;

  if (sourceRamp < 0.1)
  {
  	// targetColor = black;

  	float ramp = map(sourceRamp, 0.0, 0.1, 0.0, 1.0);
  	targetColor = mix( black, color3, min( ramp, 1.0 ) );
  }
  else if (sourceRamp < 0.45)
  {
  	float ramp = map(sourceRamp, 0.1, 0.45, 0.0, 1.0);
  	targetColor = mix( color3, color2, min( ramp, 1.0 ) );
  }
  else
  {
  	float ramp = map(sourceRamp, 0.45, 1.0, 0.0, 1.0);
  	targetColor = mix( color2, color1, min( ramp, 1.0 ) );
  }

  // vec3 targetColor = mix( color1, color2, min( sourceRamp, 1.0 ) );
  // targetColor = mix( color1, color2, min( sourceRamp, 1.0 ) );

  gl_FragColor = vec4( targetColor, 1.0);
}
