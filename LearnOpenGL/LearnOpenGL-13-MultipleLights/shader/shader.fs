// 片段着色器

#version 330 core

// 材质
struct Material {
    sampler2D diffuse;      // 漫反射光照分量影响
    sampler2D specular;     // 镜面光照分量影响
    float shininess;        // 影响镜面高光的散射/半径
};


// 定向光
struct DirLight {
    vec3 direction; // 光源方向向量
    
    vec3 ambient;   // 环境光
    vec3 diffuse;   // 漫反射光
    vec3 specular;  // 镜面光
};

// 点光源
struct PointLight {
    vec3 position;  // 点光源的位置
    
    float constant;         // 衰减度常量
    float linear;           // 衰减度一次项
    float quadratic;        // 衰减度二次项
    
    vec3 ambient;   // 环境光
    vec3 diffuse;   // 漫反射光
    vec3 specular;  // 镜面光
};

// 光强度及光颜色
struct SpotLight {
    vec3 position;          // 光源的位置 / 聚光的位置向量（计算光的方向向量）
    vec3 direction;         // 聚光的方向向量
    float cutOff;           // 切光角 的 余弦值
    float outerCutOff;      // 聚光方向向量和外圆锥向量的夹角余弦值
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    float constant;         // 衰减度常量
    float linear;           // 衰减度一次项
    float quadratic;        // 衰减度二次项
};

// 计算定向光
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);

// 计算点光
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 viewDir, vec3 fragPos);

// 计算聚光
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 viewDir, vec3 fragPos);


out vec4 FragColor;

in vec2 TexCoords;                              // 纹理坐标
in vec3 Normal;                                 // 法向量
in vec3 FragPos;                                // 片段位置向量
uniform vec3 viewPos;                           // 观察位置向量

uniform Material material;                      // 材质
uniform DirLight dirLight;                      // 定向光
#define NR_POINT_LIGHTS 4
uniform PointLight pointLights[NR_POINT_LIGHTS];// 点光源
uniform SpotLight spotLight;                    // 聚光


// 聚光下边缘润滑---外加了一个平滑圆锥
// 在内圆锥内光的强度值是1，在外圆锥外光的强度值是0，在外圆锥内内圆锥外之间的值是0.0-1.0，达到了平滑效果
void main() {
    // 标准化后的法向量
    vec3 normal = normalize(Normal);
    
    // 观察向量
    vec3 viewDir = normalize(viewPos - FragPos);
    
    // 第一阶段：定向光
    vec3 result = CalcDirLight(dirLight, normal, viewDir);
    
    // 第二阶段：点光源
    for (int i = 0; i < NR_POINT_LIGHTS; i++) {
        result += CalcPointLight(pointLights[i], normal, viewDir, FragPos);
    }
    
    // 第三阶段：聚合光源
    result += CalcSpotLight(spotLight, normal, viewDir, FragPos);
    
    FragColor = vec4(result, 1.0);
}



// 计算定向光
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir) {
    
    // 环境光
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
    
    // 漫反射光
    // 光源指向片段的向量
    vec3 lightDir = normalize(-light.direction);
    // 分量影响值
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
    
    // 镜面光
    // 反射向量
    vec3 reflectDir = reflect(light.direction, normal);
    // 镜面光影响值
    float spec = pow(max(dot(viewDir, reflectDir),0.0),material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    
    return (ambient + diffuse + specular);
}


// 计算点光源
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 viewDir, vec3 fragPos) {
    
    // 光源位置
    vec3 lightDir = normalize(light.position - fragPos);
    
    // 环境光着色
    vec3 ambient = light.ambient * vec3(texture(material.diffuse,TexCoords));
    
    // 漫反射着色
    // 分量影响值
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
    
    // 镜面光着色
    // 反射向量
    vec3 reflectDir = reflect(-lightDir, normal);
    // 镜面光影响值
    float spec = pow(max(dot(viewDir, reflectDir),0.0),material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    
    // 衰减
    // 光源与片段位置的距离
    float distance = length(light.position - FragPos);
    // 经过公式计算衰减度
    float attenuation = 1.0 / (light.constant + light.linear * distance +
                               light.quadratic * (distance * distance));
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
    return (ambient + diffuse + specular);
}


// 计算聚光
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 viewDir, vec3 fragPos) {
    
    vec3 lightDir = normalize(light.position - fragPos);

    // 计算平滑度
    float theta = dot(lightDir, normalize(-light.direction));
    float intensity = clamp((theta - light.outerCutOff)/(light.cutOff - light.outerCutOff), 0.0, 1.0);
    
    // 衰减度计算
    // 光源与片段位置的距离
    float distance = length(light.position - fragPos);
    // 经过公式计算衰减度
    float attenuation = 1.0 / (light.constant + light.linear * distance +
                               light.quadratic * (distance * distance));
    
    // 环境光着色
    vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;
    
    // 满反射光着色
    // 影响值：法向量与光源方向向量的点乘的非负数值
    float diff = max(dot(normal, lightDir), 0.0);
    // 最终的漫反射影响分量
    vec3 diffuse =  light.diffuse * diff * texture(material.diffuse, TexCoords).rgb;
    

    // 镜面光着色
    vec3 reflectDir = reflect(-lightDir, normal);
    // 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
    // 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // 计算镜面分量：高光强度*影响值*光源色
    vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;
    
    // 添加平滑度
    diffuse *= intensity;
    specular *= intensity;
    
    // 添加衰减
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    
    return (ambient + diffuse + specular);
}
