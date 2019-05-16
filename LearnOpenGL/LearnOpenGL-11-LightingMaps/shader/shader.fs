// 片段着色器

#version 330 core

// 材质
struct Material {
    sampler2D diffuse;      // 漫反射光照分量影响
    sampler2D specular;     // 镜面光照分量影响
    float shininess;        // 影响镜面高光的散射/半径
};


// 光强度及光颜色
struct Light {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};


out vec4 FragColor;

in vec2 TexCoords;          // 纹理坐标
in vec3 Normal;             // 法向量
in vec3 FragPos;            // 片段位置向量
uniform vec3 lightPos;      // 光源位置向量
uniform vec3 viewPos;       // 观察位置向量

uniform Material material;
uniform Light light;

void main() {
    
    // 环境光照的影响分量
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
    
    // 满反射光照的影响分量
    // 标准话的法向量
    vec3 norm = normalize(Normal);
    // 标准化的光源方向向量: 光源位置向量与片段位置向量的差值
    vec3 lightDir = normalize(lightPos - FragPos);
    // 影响值：法向量与光源方向向量的点乘的非负数值
    float diff = max(dot(norm, lightDir), 0.0);
    // 最终的漫反射影响分量
    vec3 diffuse =  light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
    
    // 镜面光照的影响分量
    // 视线方向向量: 观察位置向量与片段位置向量的差值
    vec3 viewDir = normalize(viewPos - FragPos);
    // 反射向量：沿着法线轴的反射向量
    // 反射函数reflect：
    // 要求第一个向量是从光源指向片段位置的向量，但是这里lightDir刚好相反，是片段指向光源
    // 要求第二个向量是法向量，这里提供norm法向量
    vec3 reflectDir = reflect(-lightDir, norm);
    // 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
    // 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // 计算镜面分量：高光强度*影响值*光源色
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    
    vec3 result = (ambient + diffuse + specular);
    FragColor = vec4(result, 1.0);
}
