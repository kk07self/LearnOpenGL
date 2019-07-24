precision highp float;
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform float opacityPercent;

void main()
{
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}
