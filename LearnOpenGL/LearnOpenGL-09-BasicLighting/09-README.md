# LearnOpenGL-09-BasicLighting

<br/>

>  此示例学习资源来自于[基础光照](https://learnopengl-cn.github.io/02%20Lighting/02%20Basic%20Lighting/)，感谢！关于理论的部分可以直接阅读这篇文章。
<br/>


## 环境光照
`环境光照(Ambient Lighting)`：即使在黑暗的情况下，世界上通常也仍然有一些光亮（月亮、远处的光），所以物体几乎永远不会是完全黑暗的。为了模拟这个，我们会使用一个环境光照常量，它永远会给物体一些颜色。

把环境光照添加到场景里非常简单。我们用光的颜色乘以一个很小的常量环境因子(这里我们将常量环境因子设置为0.1)，再乘以物体的颜色，然后将最终结果作为片段的颜色：
```
// 片段着色器

#version 330 core
out vec4 FragColor;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main() {
float ambientStrength = 0.1;
vec3 ambient = ambientStrength * lightColor;
FragColor = vec4(ambient * objectColor, 1.0);
}
```
<br/>

## 漫反射光照
`漫反射光照(Diffuse Lighting)`：模拟光源对物体的方向性影响(Directional Impact)。它是冯氏光照模型中视觉上最显著的分量。物体的某一部分越是正对着光源，它就会越亮。
计算漫反射光照我们需要两个信息：
法向量：一个垂直于顶点表面的向量。
定向的光线：作为光源的位置与片段的位置之间向量差的方向向量。为了计算这个光线，我们需要光的位置向量和片段的位置向量。

### 法向量
法向量是一个垂直于顶点表面的（单位）向量。
由于顶点本身并没有表面（它只是空间中一个独立的点），我们利用它周围的顶点来计算出这个顶点的表面。我们能够使用一个小技巧，使用叉乘对立方体所有的顶点计算法向量，但是由于3D立方体不是一个复杂的形状，所以我们可以简单地把法线数据手工添加到顶点数据中。
更新后的顶点数据（顶点数据+法线数据）：
```
float vertices[] = {
-0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
-0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
-0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,

-0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
-0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
-0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,

-0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
-0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
-0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
-0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
-0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
-0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,

0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,

-0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
-0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
-0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,

-0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
-0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
-0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
};
```
更新了顶点数组数据后，我们调整`顶点着色器`及其读取规则
首先是调整顶点着色器，我们添加一个接收属性接收顶点数组对象中的法线数据的值---`aNormal`
然后，因为所有光照的计算都是在`片段着色器`中进行的，我们将`法向量`据传递到`片段着色器`中，这里也就相应添加了输出属性`Normal`。
```
// 顶点着色器

#version 330 core
layout (location = 0) in vec3 aPos;     // 顶点值
layout (location = 1) in vec3 aNormal;  // 法向量

out vec3 Normal; // 传递给片段着色器的法向量

uniform mat4 model;         // 模型矩阵
uniform mat4 view;          // 观察矩阵
uniform mat4 projection;    // 投影矩阵

void main()
{
// 注意乘法要从右向左读
gl_Position = projection * view * model * vec4(aPos, 1.0);
Normal = aNormal;
}
```
数据读取规则也要调整，之前每个顶点数据只有3个，所以步长是3，现在数据有6个（3个顶点数据、3个`法向量`数据），所以步长调整为6
```
// 步长为6
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);
```
另外，需要添加法向量的读取
```
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
glEnableVertexAttribArray(1);

```
最后我们在`片段着色器`中添加`法向量`的接收变量
```
in vec3 Normal;
```
截止这一步，我们对于数据的传输环境搭建完成，下一步将计算通过这个值进行`漫反射光照`计算。
<br/>

### 漫反射光照计算

#### 光源位置向量和片段位置向量

有了`法向量`，现在还需要一个光源的位置向量和片段的位置向量。
- 光源位置向量
由于光源的位置是一个静态变量，我们可以简单地在`片段着色器`中把它声明为uniform：
```
uniform vec3 lightPos;
```
然后在渲染循环中更新`uniform`，我们使用在前面申明的`lightPos`向量作为光源位置
```
ourShader.setVec3("lightPos", lightPos);
```
- 片段位置向量
我们会在世界空间中进行所有的光照计算，因此我们需要一个在世界空间中的顶点位置。我们可以通过把顶点位置属性乘以模型矩阵（不是观察和投影矩阵）来把它变换到世界空间坐标。这个在顶点着色器中很容易完成，所以我们声明一个输出变量，并计算它的世界空间坐标：
```
// 片段位置向量
out vec3 FragPos; 
// 计算出片段位置向量
FragPos = vec3(model * vec4(aPos, 1.0));
```

最终`顶点着色器`的代码是：
```
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
// 计算片段位置向量
FragPos = vec3(model * vec4(aPos, 1.0));
// 法向量
Normal = aNormal;
}
```
最后，在`片段着色器`中添加`片段位置向量`的输入变量
```
in vec3 FragPos;
```
截止到这一步，`片段着色器`中的代码是：
```
// 片段着色器

#version 330 core
out vec4 FragColor;

in vec3 Normal;             // 法向量

uniform vec3 lightPos;      // 光源位置向量
uniform vec3 objectColor;   // 物体颜色
uniform vec3 lightColor;    // 光源颜色

void main() {
float ambientStrength = 0.1;
vec3 ambient = ambientStrength * lightColor;
FragColor = vec4(ambient * objectColor, 1.0);
}
```

#### 光照计算
- 计算光源位置和片段位置之间的方向向量
前面提到，光的方向向量是光源位置向量与片段位置向量之间的向量差。我们同样希望确保所有相关向量最后都转换为单位向量，所以我们把法线和最终的方向向量都进行标准化：
```
// 标准话的法向量
vec3 norm = normalize(Normal);
// 标准化的方向向量
vec3 lightDir = normalize(lightPos - FragPos);
```
- 计算光源对当前片段的漫反射影响
终于到最后一步，计算漫反射分量了。
我们对norm和lightDir向量进行点乘，计算光源对当前片段实际的漫发射影响。结果值再乘以光的颜色，得到漫反射分量。两个向量之间的角度越大，漫反射分量就会越小。如果两个向量之间的角度大于90度，点乘的结果就会变成负数，这样会导致漫反射分量变为负数。为此，我们使用max函数返回两个参数之间较大的参数，从而保证漫反射分量不会变成负数。负数颜色的光照是没有定义的，所以最好避免它，除非你是那种古怪的艺术家。
```
// 满反射光照的影响分量
// 标准话的法向量
vec3 norm = normalize(Normal);
// 标准化的方向向量
vec3 lightDir = normalize(lightPos - FragPos);
// 影响值
float diff = max(dot(norm, lightDir), 0.0);
// 最终的漫反射影响分量
vec3 diffuse = diff * lightColor;
```

### 漫反射光照分量应用
现在我们有了环境光分量和漫反射分量，我们把它们相加，然后把结果乘以物体的颜色，来获得片段最后的输出颜色。
```
vec3 result = (ambient + diffuse) * objectColor;
FragColor = vec4(result, 1.0);
```
截止到此步骤，完成了`环境光照`和`漫反射光照`的影响。

### One more thing
法线矩阵避免物体倍不等比缩放的影响。
`法线矩阵`：`模型矩阵`左上角的`逆矩阵`的`转置矩阵`。
`逆矩阵`：Inverse Matrix ，`inverse`函数实现。
`转置矩阵`：Transpose Matrix，`transpose`函数实现。
最终`顶点着色器`中法向量的结果是：
```
// 法向量
Normal = mat3(transpose(inverse(model))) * aNormal;
```
<br/>

## 镜面光照
`镜面光照(Specular Lighting)`：模拟有光泽物体上面出现的亮点。镜面光照的颜色相比于物体的颜色会更倾向于光的颜色。

和前面两个光照影响一样，要看到`镜面光照`处理过的效果，首先要计算出`镜面光照`的影响值。
`镜面光照`的影响值的计算，需要有`观察向量`分量和`反射向量`分量。

### 观察向量分量
和前面的`光源方向向量`分量计算类似，`光源方向向量`的计算是`光源位置向量`与`片段位置向量`的差值，类似，`观察方向向量`的计算是`观察位置向量`与`片段位置向量`的差值。`片段位置向量`之前已经拿到，现在要拿到`观察位置向量`。`观察位置向量`的获取也很简单，其实就是`摄像机`的位置向量。
因此，我们在`片段着色器`中定义一个`uniform`的接收全局变量`viewPos`:
```
uniform vec3 viewPos;       // 观察位置向量
```
然后在渲染循环中，将`摄像机`的位置向量传递过来：
```
// 设置观察位置向量
ourShader.setVec3("viewPos", camera.Position);
```
有了`观察位置向量`和之前的`片段位置向量`，我们就可以计算出`观察方向向量`了：
```
// 视线方向向量: 观察位置向量与片段位置向量的差值
vec3 viewDir = normalize(viewPos - FragPos);
```

### 反射向量
`反射向量`的计算通过反射函数`reflect`取得的，反射函数需要两个参数，第一个是光源指向片段位置的向量，第二个参数是`法线向量`（`法向量`），因为我们获取的是沿着法线轴的`反射向量`。
`法向量`，这个之前就有计算好，`norm`向量；
`光源向量`，我们之前计算的`光源向量`---`lightDir`，刚好方向相反，是片段位置指向光源位置的，因此这里需要取反。
那么`反射向量`的计算就是：
```
// 反射向量：沿着法线轴的反射向量
// 反射函数reflect：
// 要求第一个向量是从光源指向片段位置的向量，但是这里lightDir刚好相反，是片段指向光源
// 要求第二个向量是法向量，这里提供norm法向量
vec3 reflectDir = reflect(-lightDir, norm);
```

### 计算镜面反射影响值
有了前面两步的计算，已经得到`实现方向向量`和`反射向量`了，接下来是计算影响值得了。
先看计算代码：
```
// 计算影响值：法向量与光源方向向量的点乘的非负数值, 在取32次幂。
// 32次幂是高光的方光度，一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小
float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
```
代码的注释有说明这一波计算的作用，这里不再描述了。
有了影响值，我们还需要一个高光强度，这里我们设置中等高光强度：
```
// 镜面光照的影响分量
// 给个高光强度，我们选中等亮度的
float specularStrength = 0.5;
```
最后计算影响分量了，和前面两个光照计算逻辑一样，高光强度因子*影响值*光源色即是`镜面光照`的影响分量。
```
// 计算镜面分量：高光强度*影响值*光源色
vec3 specular = specularStrength * spec * lightColor;
```

### 镜面光照分量应用
现在我们有了环境光分量和漫反射分量，以及镜面光照分量，我们把它们相加，然后把结果乘以物体的颜色，来获得片段最后的输出颜色。
```
vec3 result = (ambient + diffuse + specular) * objectColor;
FragColor = vec4(result, 1.0);
```
以上，我们完成了`镜面光照`的影响，加上之前的两个光照，我们完成了`冯氏光照模型`中所有光照影响分量。

<br/>


## 总结
由上一示例，我们知道，物体显示的颜色，是有`光色`（光源照射的颜色）和`物色`（物体本身的颜色）决定。
本示例，将两因素中的一个因素`光色`又进一步具体进行了分析。
本示例，用`冯氏光照模型`分析了影响`光色`的三种光照：`环境光照`、`漫反射光照`以及`镜面光照`。
通过这三种光照的具体计算，最终计算出符合真实情况的`光色`，来应用到物体真实显示的颜色重。
