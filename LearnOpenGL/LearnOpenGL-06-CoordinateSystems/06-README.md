# LearnOpenGL-06-CoordinateSystems

<br/>

>  此示例学习资源来自于[LearnOpenGL](https://learnopengl-cn.github.io/)，感谢！建议在查看此示例前，先看看这篇文章[坐标系统](https://learnopengl-cn.github.io/01%20Getting%20started/08%20Coordinate%20Systems/)，先对坐标系统和各个空间有所了解。
<br/>


本篇文章将分三个小示例：纹理3D预览，3D盒子，多个3D盒子。
<br/>

## 小示例1：纹理3D预览
这一部分也很简单，整体来说和示例5中的转换示例的逻辑一致。
转换的逻辑是：
- 先是在顶点着色器源码上设置矩阵接收属性并进行处理
- 然后是创建转换矩阵（可以是多个组合的）
- 最后是将创建的转换矩阵复制到着色器中

同样，3D预览的逻辑也是这样：
- 先是在顶点着色器源码上设置矩阵接收属性并进行处理（可以多个组合）
- 然后是创建各个空间矩阵（创建需要的）
- 最后是将创建的空间矩阵复制到着色器中

<br/>

针对对应的逻辑上代码：
### 1.1 顶点着色器调整
- 先是在顶点着色器上添加三个接收矩阵，同样`uniform`修饰的全局数据
```
uniform mat4 model;         // 模型矩阵
uniform mat4 view;          // 观察矩阵
uniform mat4 projection;    // 投影矩阵
```
- 在`main`函数中，将这几个矩阵进行组合
```
gl_Position = projection * view * model * vec4(aPos, 1.0);
```
<br/>

### 1.2 创建各个空间矩阵
这个小示例中，我们创建三个矩阵（与顶点着色器中的三个接收者相匹配）
```
// create transformations
glm::mat4 model         = glm::mat4(1.0f); // make sure to initialize matrix to identity matrix first
glm::mat4 view          = glm::mat4(1.0f);
glm::mat4 projection    = glm::mat4(1.0f);
// 模型矩阵，这里是按照x轴向后倾倒（旋转）-55弧度
model = glm::rotate(model, glm::radians(-55.0f), glm::vec3(1.0f, 0.0f, 0.0f));
// 观察矩阵，我们将矩阵向我们要进行移动场景的反方向移动
view  = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f));
// 透视矩阵，简单的一个投影矩阵
projection = glm::perspective(glm::radians(45.0f), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
```
<br/>

### 1.3 将各空间矩阵传递给着色器
这里的传递，我们用了三种不同的方式，但是每一种方式的效果是等价的
```
// retrieve the matrix uniform locations
unsigned int modelLoc = glGetUniformLocation(ourShader.ID, "model");
unsigned int viewLoc  = glGetUniformLocation(ourShader.ID, "view");
// pass them to the shaders (3 different ways)
glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(model));
glUniformMatrix4fv(viewLoc, 1, GL_FALSE, &view[0][0]);
ourShader.setMat4("projection", projection);
```
通过以上的设置，运行项目，即可看到效果。

## 小示例2：旋转的3D盒子
这个示例相比较于上一个示例只需要简单的微调即可。
### 2.1 顶点数据对象的数据源调整
一个3D的矩形盒子需要36点，6个面，每个面需要2个三角形，每个三角形需要3个顶点。这里的36个顶点如下：
```
float vertices[] = {
-0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
-0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
-0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
-0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

-0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
-0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
-0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
-0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
-0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

-0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
-0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
-0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};
```
### 2.2 告知OpenGL如何读取数据源调整
这里只给出调整后的代码，具体为什么这样调整，前面的示例中也都有描述
```
// 告诉opengl如何读取数据
// 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为5
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);

// 文理设置 从1开始, 偏移量是3
glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)(3 * sizeof(float)));
// 以顶点位置1作为参数启用顶点属性 ---
glEnableVertexAttribArray(1);
```

### 2.3 绘制顶点数据调整
这里只传入36个顶点，没有用索引，所以这里的绘制是绘制数组而不是elments。同样的，为什么这样绘制，在前面第二个示例中就有详解，这里也不再详细描述。
```
// 绘制顶点
glDrawArrays(GL_TRIANGLES, 0, 36);
```

### 2.4 开启深度测试
关于为什么要开启`深度测试`，文章开头的链接中的对应文章就有所描述，当然可以直接点击[这里](https://learnopengl-cn.github.io/01%20Getting%20started/08%20Coordinate%20Systems/)进行查看，此知识点在文章的`Z缓冲`模块中。
```
// 开启深度测试
// -----------------------------
glEnable(GL_DEPTH_TEST);
```
清除屏幕上的数据时，也要清除深度数据
```
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
```

### 2.4 调整模型矩阵
为了达到不停旋转的效果，这里需要调整`模型矩阵`
```
// 随着时间进行转动
model = glm::rotate(model, (float)glfwGetTime() * glm::radians(50.0f), glm::vec3(0.5f, 1.0f, 0.0f));
```

完成以上所有调整后，运行项目，即可看到旋转的立方体盒子
<br/>

## 多个3D盒子
