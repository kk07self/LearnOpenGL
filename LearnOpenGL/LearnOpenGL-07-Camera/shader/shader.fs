// 片段着色器
// 顶点着色器传递过来的颜色信息和纹理信息

#version 330 core
out vec4 FragColor;
in  vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;
void main() {
    // 只要纹理
//    FragColor = texture(texture1, TexCoord);
    // 纹理与颜色结合
//    FragColor = texture(texture1, TexCoord) * vec4(vertexColor, 1.0);
    // 多纹理组合, 第一个透明度80，第二个20
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
}
