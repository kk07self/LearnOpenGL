attribute vec2 position;
attribute vec4 inputTextureCoordinate;

varying vec2 textureCoordinate;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
    textureCoordinate = inputTextureCoordinate.xy;
}
