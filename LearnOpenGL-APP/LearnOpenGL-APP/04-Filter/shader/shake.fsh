precision mediump float;

varying vec2 TexCoord;

uniform sampler2D texture1;
uniform float Time;

void main() {
    
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(Time, duration)/duration;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    // offset
    vec2 offsetCoord = vec2(offset, offset) * progress;
    
    // scale, distance/scale for bigger,  TexCoord smaller than smaller image bigger
//    vec2 scaleCoord = vec2(0.5, 0.5) + (TexCoord - vec2(0.5, 0.5))/scale;
    vec2 scaleCoord = vec2(0.5 + (TexCoord.x - 0.5)/scale, 0.5 + (TexCoord.y - 0.5)/scale);
    vec4 maskR = texture2D(texture1, scaleCoord + offsetCoord);
    vec4 mask = texture2D(texture1, scaleCoord);
    vec4 maskB = texture2D(texture1, scaleCoord - offsetCoord);
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
