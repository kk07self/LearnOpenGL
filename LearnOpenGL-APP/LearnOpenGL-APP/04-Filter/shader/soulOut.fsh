precision mediump float;

varying vec2 TexCoord;

uniform sampler2D texture1;
uniform float Time;

void main() {
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(Time, duration)/duration;
    
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    
    vec4 mask = texture2D(texture1, TexCoord);
    // changed texCoord not postion, can scale to big with getting smaller TexCoord to Postion
    // vec2(0.5 + (TexCoord.x - 0.5)/scale, 0.5 + (TexCoord.y - 0.5) / scale)
    // scale distance of TexCoord to center   this can still soul out from center
    vec4 soul = texture2D(texture1, vec2(0.5 + (TexCoord.x - 0.5)/scale, 0.5 + (TexCoord.y - 0.5) / scale));
    
    
    gl_FragColor = mask * (1.0 - alpha) + soul * alpha;
}
