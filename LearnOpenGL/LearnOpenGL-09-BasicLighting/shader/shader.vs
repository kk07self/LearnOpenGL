// 顶点着色器

#version 330 core
layout (location = 0) in vec3 aPos;     // 顶点值
layout (location = 1) in vec3 aNormal;  // 法向量值

out vec3 Normal;                        // 传递给片段着色器的法向量
out vec3 FragPos;                       // 光源位置

uniform mat4 model;                     // 模型矩阵
uniform mat4 view;                      // 观察矩阵
uniform mat4 projection;                // 投影矩阵

void main()
{
    // 注意乘法要从右向左读
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    // 计算片段位置向量 --- 世界空间中
    FragPos = vec3(model * vec4(aPos, 1.0));
    // 法向量 --- 世界空间中
    Normal = mat3(transpose(inverse(model))) * aNormal;
}
