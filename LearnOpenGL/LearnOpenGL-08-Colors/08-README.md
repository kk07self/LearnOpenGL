# LearnOpenGL-08-Colors

<br/>

>  此示例学习资源来自于[颜色](https://learnopengl-cn.github.io/02%20Lighting/01%20Colors/)，感谢！关于理论的部分可以直接阅读这篇文章。
<br/>

这篇文件将简单介绍几个`光照`场景的前提知识点。
<br/>

## 颜色
具体的理论部分参考我前面说的那篇文章，这里我要说的是实践，最后见到的光，是光颜色向量和物体颜色向量的乘积。
```
// 光颜色向量
glm::vec3 lightColor(1.0f, 1.0f, 1.0f);
// 物体颜色向量
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
// 最终看到的结果
glm::vec3 result = lightColor * toyColor; // = (1.0f, 0.5f, 0.31f);
```


## 创建一个光照场景
### 着色器
这个示例我们需要两个物体：光源和物体，因此我们需要两套着色器。
#### 光源的着色器
光源的着色器：`lightShader.vs`和`lightShader.fs`分别是光源的`顶点着色器`和`片段着色器`。
- 顶点着色器
```
// 光源的顶点着色器

#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;         // 模型矩阵
uniform mat4 view;          // 观察矩阵
uniform mat4 projection;    // 投影矩阵

void main()
{
    // 注意乘法要从右向左读
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
```
- 片段着色器
```
// 光源的片段着色器

#version 330 core
out vec4 FragColor;

void main() {
    // 光源为全白色
    FragColor = vec4(1.0);
}
```
<br/>

#### 物体的着色器
物体的着色器：`shader.vs`和`shader.fs`分别是物体的`顶点着色器`和`片段着色器`。
- 顶点着色器
```
// 光源的顶点着色器

#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;         // 模型矩阵
uniform mat4 view;          // 观察矩阵
uniform mat4 projection;    // 投影矩阵

void main()
{
// 注意乘法要从右向左读
gl_Position = projection * view * model * vec4(aPos, 1.0);
}
```

- 片段着色器
```
// 片段着色器

#version 330 core
out vec4 FragColor;

uniform vec3 objectColor;   // 物体颜色
uniform vec3 lightColor;    // 光源颜色

void main() {
    FragColor = vec4(lightColor * objectColor, 1.0);
}
```

### 顶点数组对象
创建两个立方体（光源和物体），简单点我们可以用同一个`顶点数组对象`-VAO，在渲染的时候渲染两次即可出现两个立方体，然后通过`模型矩阵`-`model`调整其大小和位置即可，但是为了后面的更多可能性，这里又单独给光源创建了一个`顶点数组对象`-VAO。
```
// 光源的
unsigned int lightVAO;
glGenVertexArrays(1, &lightVAO);
glBindVertexArray(lightVAO);
glBindBuffer(GL_ARRAY_BUFFER, VBO);
// 告诉opengl如何读取数据
// 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为5
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);
```


### 转换渲染
这个示例中，我们创建了两个着色器类-管理两套着色器程序，对应两套着色器
```
// 物体的
Shader ourShader("shader/shader.vs","shader/shader.fs");
// 光源的
Shader lightShader("shader/lightShader.vs","shader/lightShader.fs");
```

#### 物体转换渲染
这里分为了两部分，一部分是设置物体颜色，另一部分是控制物体的位置和视角
最后一步是用顶点数据进行渲染
```
ourShader.use();
// 物体颜色
ourShader.setVec3("objectColor", 1.0, 0.5, 0.31);
ourShader.setVec3("lightColor", 1.0, 1.0, 1.0);

// view/projection transformations
glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
glm::mat4 view = camera.GetViewMatrix();
ourShader.setMat4("projection", projection);
ourShader.setMat4("view", view);

glm::mat4 model = glm::mat4(1.0f);
model = glm::rotate(model, glm::radians(45.0f), glm::vec3(1.0f, 0.3f, 0.5f));
ourShader.setMat4("model", model);

// 绘制四角形
// 使用着色器程序进行渲染
glBindVertexArray(VAO);
glDrawArrays(GL_TRIANGLES, 0, 36);
```

#### 光源渲染
光源的渲染和物体的渲染一样，只是`模型矩阵`有所变动，要错开两个物体的位置
```
// 使用我们的着色器进行渲染
lightShader.use();
lightShader.setMat4("view", view);
lightShader.setMat4("projection", projection);
model = glm::mat4(1.0f);
model = glm::translate(model, lightPos);
model = glm::scale(model, glm::vec3(0.2f)); // a smaller cube
lightShader.setMat4("model", model);

// 绘制四角形
// 使用着色器程序进行渲染
glBindVertexArray(lightVAO);
glDrawArrays(GL_TRIANGLES, 0, 36);
```

以上，运行项目即可看到效果。
