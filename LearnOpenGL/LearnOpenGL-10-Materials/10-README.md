# LearnOpenGL-09-BasicLighting

<br/>

>  此示例学习资源来自于[材质](https://learnopengl-cn.github.io/02%20Lighting/03%20Materials/)，感谢！关于理论的部分可以直接阅读这篇文章。
<br/>

有了上一示例的铺垫，这一示例相对来说十分简单。

## 物体的材质
现实世界中，不同的物体会对光产生不同的反应，比如钢铁和木头。这一因素我们归纳为`材质`属性。这一篇的第一部分我们就研究通过控制材质的设置来控制物体的颜色呈现。

### 定义材质
上一示例中，我们知道，影响颜色的有三种光照，那这里针对`材质`属性我们也设置三个不同的属性与其对应：
```
// 材质
struct Material {
    vec3 ambient;       // 环境光照分量影响
    vec3 diffuse;       // 漫反射光照分量影响
    vec3 specular;      // 镜面光照分量影响
    float shininess;    // 影响镜面高光的散射/半径
};

uniform Material material;
```
在`片段着色器`中，我们定义了一个结构体，然后其中包含三个属性分别对应三种光照的分量：`ambient`、`diffuse`和`specular`，另外，我们也把影响镜面高光的散射也放在了里面（上一示例中提到的，32次幂是高光的反光度）。

### 设置和使用材质
上一步我们完成了`材质`的定制，这一步我们就将其应用。
```
void main() {    
    // 环境光
    vec3 ambient = lightColor * material.ambient;

    // 漫反射 
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = lightColor * (diff * material.diffuse);

    // 镜面光
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);  
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = lightColor * (spec * material.specular);  

    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0);
}
```
可以看到，我们现在在需要的地方访问了材质结构体中的所有属性，并且这次是根据材质的颜色来计算最终的输出颜色的。物体的每个材质属性都乘上了它们对应的光照分量。
然后我们在外面设置这些材质属性：
```
lightingShader.setVec3("material.ambient",  1.0f, 0.5f, 0.31f);
lightingShader.setVec3("material.diffuse",  1.0f, 0.5f, 0.31f);
lightingShader.setVec3("material.specular", 0.5f, 0.5f, 0.5f);
lightingShader.setFloat("material.shininess", 32.0f);
```
以上，我们就完成了材质维度的影响。

## 光的强度
上一步我们设置了材质，但是物体的光过亮。物体过亮的原因是环境光、漫反射和镜面光这三个颜色对任何一个光源都会去全力反射。光源对环境光、漫反射和镜面光分量也具有着不同的强度。前面的教程，我们通过使用一个强度值改变环境光和镜面光强度的方式解决了这个问题。我们想做一个类似的系统，但是这次是要为每个光照分量都指定一个强度向量。如果我们假设lightColor是vec3(1.0)，代码会看起来像这样：
```
vec3 ambient  = vec3(1.0) * material.ambient;
vec3 diffuse  = vec3(1.0) * (diff * material.diffuse);
vec3 specular = vec3(1.0) * (spec * material.specular);
```
所以物体的每个材质属性对每一个光照分量都返回了最大的强度。对单个光源来说，这些vec3(1.0)值同样可以分别改变，而这通常就是我们想要的。现在，物体的环境光分量完全地影响了立方体的颜色，可是环境光分量实际上不应该对最终的颜色有这么大的影响，所以我们会将光源的环境光强度设置为一个小一点的值，从而限制环境光颜色：
```
vec3 ambient = vec3(0.1) * material.ambient;
```

这里我们可以通过和设置材质一样的方式修改这些强度。
这里我们定义一个光强度的结构体
```
// 光强度及光颜色
struct Light {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform Light light;
```
然后将光强度进行运用到分量值得计算中：
```
// 环境光照的影响分量
vec3 ambient = light.ambient * material.ambient;
// 最终的漫反射影响分量
vec3 diffuse =  light.diffuse * (diff * material.diffuse);
// 计算镜面分量：高光强度*影响值*光源色
vec3 specular = light.specular * (spec * material.specular);
```
最后，在外面的渲染循环体中，进行设置：
```
ourShader.setVec3("light.ambient",  0.2f, 0.2f, 0.2f);
ourShader.setVec3("light.diffuse",  0.5f, 0.5f, 0.5f); // 将光照调暗了一些以搭配场景
ourShader.setVec3("light.specular", 1.0f, 1.0f, 1.0f); 
```
完成，运行项目，即可观察到调整后的效果。

## 光源变话
以上，我们已经完成了`材质`和`光强度`对光的控制，为了更加酷炫，我们可以进一步将光源颜色进行不断变化。
在外面的渲染循环体中，我们调整给`片段着色器`中`光强度及颜色`的赋值：
```
// 光源颜色及强度 --- 变化的
glm::vec3 lightColor;
lightColor.x = sin(glfwGetTime() * 2.0f);
lightColor.y = sin(glfwGetTime() * 0.7f);
lightColor.z = sin(glfwGetTime() * 1.3f);
glm::vec3 diffuseColor = lightColor   * glm::vec3(0.5f); // decrease the influence
glm::vec3 ambientColor = diffuseColor * glm::vec3(0.2f); // low influence
ourShader.setVec3("light.ambient", ambientColor);
ourShader.setVec3("light.diffuse", diffuseColor);
ourShader.setVec3("light.specular", 1.0f, 1.0f, 1.0f);
```

运行项目，我们即将看到不断变化色彩的立方体了。


## 总结
上一项目我们将控制了影响光色的三个光照：`环境光照`、`漫反射光照`和`镜面光照`。这一步我们进一步加强对光照颜色的控制，从物体的`材质`和`光照强度`两个维度进行控制，从而实现对物体颜色在光照下的完全掌控。
