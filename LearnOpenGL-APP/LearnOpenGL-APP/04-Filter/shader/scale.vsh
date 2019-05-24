
attribute vec3 aPos;
attribute vec2 aTexCoord;

varying vec2 TexCoord;

uniform float Time;
const float PI = 3.1415926;

void main() {
    
    float duration = 0.6;
    float maxAmplitude = 0.3;
    float time = mod(Time, duration);
    
    float amplitude = 1.0 + time;
    
    gl_Position = vec4(aPos.x * amplitude, aPos.y * amplitude, aPos.z, 1.0);
    TexCoord = aTexCoord;
}
