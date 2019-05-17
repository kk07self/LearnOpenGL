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


out vec4 FragColor;

in vec2 TexCoords;          // 纹理坐标
in vec3 Normal;             // 法向量
in vec3 FragPos;            // 片段位置向量
uniform vec3 viewPos;       // 观察位置向量

uniform Material material;
uniform Light light;


// 聚光下边缘润滑---外加了一个平滑圆锥
// 在内圆锥内光的强度值是1，在外圆锥外光的强度值是0，在外圆锥内内圆锥外之间的值是0.0-1.0，达到了平滑效果
void main() {
    
    vec3 lightDir = normalize(light.position - FragPos);
    
    // 聚光强度值计算：(θ-γ)/ϵ，
    // θ片段指向光源的向量和聚光所指向的向量间的夹角---的余弦值
    // γ是外圆锥切光角余弦值
    // ϵ是内圆锥切光角余弦值与外圆锥切光角余弦值的差（cutOff - outCutOff）
    // 片段指向光源的向量和聚光所指向的向量间的夹角---的余弦值（两个向量之间的点积即是他们的余弦值）
    float theta = dot(lightDir, normalize(-light.direction));
    //
//    float epsilon = (light.cutOff - light.outerCutOff);
    // (θ-γ)/ϵ , 通过clamp函数让intensity值在[0.0,1.0]之间
    float intensity = clamp((theta - light.outerCutOff)/(light.cutOff - light.outerCutOff), 0.0, 1.0);
    
    // 衰减度计算
    // 光源与片段位置的距离
    float distance = length(light.position - FragPos);
    // 经过公式计算衰减度
    float attenuation = 1.0 / (light.constant + light.linear * distance +
                               light.quadratic * (distance * distance));
    
    // 环境光照的影响分量
    vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;
    
    // 满反射光照的影响分量
    // 标准话的法向量
    vec3 norm = normalize(Normal);
    // 影响值：法向量与光源方向向量的点乘的非负数值
    float diff = max(dot(norm, lightDir), 0.0);
    // 最终的漫反射影响分量
    vec3 diffuse =  light.diffuse * diff * texture(material.diffuse, TexCoords).rgb;
    
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
    vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;
    
    // 不对环境光做平滑度是让其总能有一点光
    diffuse *= intensity;
    specular *= intensity;
    
    
    ambient *= attenuation;
    
    diffuse *= attenuation;
    specular *= attenuation;
    
    vec3 result = (ambient + diffuse + specular);
    FragColor = vec4(result, 1.0);
}


// 聚光
//void main() {
//
//    vec3 lightDir = normalize(light.position - FragPos);
//
//    // 片段指向光源的向量和聚光所指向的向量间的夹角---的余弦值（两个向量之间的点积即是他们的余弦值）
//    float theta = dot(lightDir, normalize(-light.direction));
//
//    // 查看有没有在聚光范围内：大的余弦值角度反而下，说明在范围内
//    if (theta > light.cutOff) {
//        // 衰减度计算
//        // 光源与片段位置的距离
//        float distance = length(light.position - FragPos);
//        // 经过公式计算衰减度
//        float attenuation = 1.0 / (light.constant + light.linear * distance +
//                                   light.quadratic * (distance * distance));
//
//        // 环境光照的影响分量
//        vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;
//
//        // 满反射光照的影响分量
//        // 标准话的法向量
//        vec3 norm = normalize(Normal);
//        // 影响值：法向量与光源方向向量的点乘的非负数值
//        float diff = max(dot(norm, lightDir), 0.0);
//        // 最终的漫反射影响分量
//        vec3 diffuse =  light.diffuse * diff * texture(material.diffuse, TexCoords).rgb;
//
//        // 镜面光照的影响分量
//        // 视线方向向量: 观察位置向量与片段位置向量的差值
//        vec3 viewDir = normalize(viewPos - FragPos);
//        // 反射向量：沿着法线轴的反射向量
//        // 反射函数reflect：
//        // 要求第一个向量是从光源指向片段位置的向量，但是这里lightDir刚好相反，是片段指向光源
//        // 要求第二个向量是法向量，这里提供norm法向量
//        vec3 reflectDir = reflect(-lightDir, norm);
//        // 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
//        // 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
//        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
//        // 计算镜面分量：高光强度*影响值*光源色
//        vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;
//
//        //
////        ambient *= attenuation; 对环境光照不做处理，保持有一点光
//        diffuse *= attenuation;
//        specular *= attenuation;
//
//        vec3 result = (ambient + diffuse + specular);
//        FragColor = vec4(result, 1.0);
//    } else {
//        // 用环境光照环境+漫反射光照环境
//        FragColor = vec4(light.ambient * vec3(texture(material.diffuse, TexCoords)), 1.0);
//    }
//}

// 之前的--- 点光源
//void main() {
//
//    // 衰减度计算
//    // 光源与片段位置的距离
//    float distance = length(light.position - FragPos);
//    // 经过公式计算衰减度
//    float attenuation = 1.0 / (light.constant + light.linear * distance +
//                               light.quadratic * (distance * distance));
//
//    // 环境光照的影响分量
//    vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;
//
//    // 满反射光照的影响分量
//    // 标准话的法向量
//    vec3 norm = normalize(Normal);
//    vec3 lightDir = normalize(light.position - FragPos);
//    // 影响值：法向量与光源方向向量的点乘的非负数值
//    float diff = max(dot(norm, lightDir), 0.0);
//    // 最终的漫反射影响分量
//    vec3 diffuse =  light.diffuse * diff * texture(material.diffuse, TexCoords).rgb;
//
//    // 镜面光照的影响分量
//    // 视线方向向量: 观察位置向量与片段位置向量的差值
//    vec3 viewDir = normalize(viewPos - FragPos);
//    // 反射向量：沿着法线轴的反射向量
//    // 反射函数reflect：
//    // 要求第一个向量是从光源指向片段位置的向量，但是这里lightDir刚好相反，是片段指向光源
//    // 要求第二个向量是法向量，这里提供norm法向量
//    vec3 reflectDir = reflect(-lightDir, norm);
//    // 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
//    // 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
//    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
//    // 计算镜面分量：高光强度*影响值*光源色
//    vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;
//
//    ambient *= attenuation;
//    diffuse *= attenuation;
//    specular *= attenuation;
//
//    vec3 result = (ambient + diffuse + specular);
//    FragColor = vec4(result, 1.0);
//}
