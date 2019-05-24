precision mediump float;

varying vec2 TexCoord;

uniform sampler2D texture1;

void main() {
    vec4 mask = texture2D(texture1, TexCoord);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
