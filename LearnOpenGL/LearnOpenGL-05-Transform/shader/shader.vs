// 顶点着色器，位置信息、颜色信息、纹理信息获取，
// 并将颜色信息和纹理信息给片段着色器
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec2 TexCoord;
out vec3 vertexColor;

uniform mat4 transform;

void main() {
    gl_Position = transform * vec4(aPos, 1.0);
    vertexColor = aColor;
    // 让图片纹理一开始上下颠倒
//    TexCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
    TexCoord = aTexCoord;
}
