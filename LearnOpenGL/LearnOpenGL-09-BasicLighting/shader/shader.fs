// 片段着色器

#version 330 core
out vec4 FragColor;

in vec3 Normal;             // 法向量
in vec3 FragPos;            // 片段位置向量

uniform vec3 lightPos;      // 光源位置向量

uniform vec3 viewPos;       // 观察位置向量

uniform vec3 objectColor;   // 物体颜色
uniform vec3 lightColor;    // 光源颜色

void main() {
    
    // 环境光照的影响分量
    // 先给个很小的常量环境因子
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;
    
    // 满反射光照的影响分量
    // 标准话的法向量
    vec3 norm = normalize(Normal);
    // 标准化的光源方向向量: 光源位置向量与片段位置向量的差值
    vec3 lightDir = normalize(lightPos - FragPos);
    // 影响值：法向量与光源方向向量的点乘的非负数值
    float diff = max(dot(norm, lightDir), 0.0);
    // 最终的漫反射影响分量
    vec3 diffuse = diff * lightColor;
    
    // 镜面光照的影响分量
    // 给个高光强度，我们选中等亮度的
    float specularStrength = 0.5;
    // 视线方向向量: 观察位置向量与片段位置向量的差值
    vec3 viewDir = normalize(viewPos - FragPos);
    // 反射向量：沿着法线轴的反射向量
    // 反射函数reflect：
    // 要求第一个向量是从光源指向片段位置的向量，但是这里lightDir刚好相反，是片段指向光源
    // 要求第二个向量是法向量，这里提供norm法向量
    vec3 reflectDir = reflect(-lightDir, norm);
    // 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
    // 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    // 计算镜面分量：高光强度*影响值*光源色
    vec3 specular = specularStrength * spec * lightColor;
    
    vec3 result = (ambient + diffuse + specular) * objectColor;
    FragColor = vec4(result, 1.0);
}
