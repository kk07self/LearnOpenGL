precision mediump float;

varying vec2 TexCoord;

uniform sampler2D texture1;
uniform float Time;

const float PI = 3.1415926;

void main() {
    float maxAlpha = 1.0;
    float alpha = mod(Time, maxAlpha);
    
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    
    vec4 mask = texture2D(texture1, TexCoord);
    gl_FragColor = mask * (1.0 - alpha) + whiteMask * alpha;
}
