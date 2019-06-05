precision highp float;

varying vec2 TexCoord;

uniform sampler2D texture1;

uniform float Time;

const float PI = 3.1415926;

float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
    float maxJitter = 0.06;
    float duration = 0.3;
    float colorOffsetR = 0.01;
    float colorOffsetB = -0.025;
    
    float time = mod(Time, duration * 2.0);
    float amplitude = max(sin(time * (PI / duration)), 0.0);
    
    float jitter = rand(TexCoord.y) * 2.0 - 1.0; // -1 ~ 1
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = TexCoord.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    vec2 texCoords = vec2(textureX, TexCoord.y);
    
    vec4 maskR = texture2D(texture1, texCoords + vec2(colorOffsetR * amplitude, 0.0));
    vec4 mask  = texture2D(texture1, texCoords);
    vec4 maskB = texture2D(texture1, texCoords + vec2(colorOffsetB * amplitude, 0.0));
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
