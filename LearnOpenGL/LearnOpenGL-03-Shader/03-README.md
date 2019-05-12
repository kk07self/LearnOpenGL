# LearnOpenGL-03-Shader

## 第三个示例：着色器
本示例和之前的两个示例基本一致，区别的地方主要在着色器（源码）上，如果看过前面两个示例的话，可以着重看下着色器部分

## 1、着色器传值
顶点着色器的输出值和片段着色器的输入值一样即可满足传递
例如以下着色器代码 :
```
// GLSL顶点着色器源码
const char *vertexShaderSource =
"#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"out vec4 vertexColor;\n" // 顶点着色器的颜色输出
"void main() {\n"
"   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
"   vertexColor = vec4(1.0, 0.5, 0.0, 1.0);\n" // 这里给棕色
"}\n\0";

// GLSL片段着色器，计算像素最后的颜色输出
const char *fragmentShaderSource =
"#version 330 core\n"
"out vec4 FragColor;\n"
"in vec4 vertexColor;\n" // 接受顶点着色器传递的值
"void main() {\n"
//"   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n"
"   FragColor = vertexColor;\n" // 将顶点着色器传来的文理颜色进行赋值
"}\n\0";
```
`顶点着色器`中定义了`out`属性（输出值）的纹理颜色`vertexColor`，并给其设置了`棕色`。
`片段着色器`中定义了`in`属性（输入值）的纹理颜色`vertexColor`，这里再将这个值传递给颜色输出`FragColor`，让其渲染信息

其他的代码保持和`LearnOpenGL-02-Triangle`中的代码一直(绘制三角形的部分)，运行，即可看到绘制出`棕色`三角形。


## 2、Uniform
uniform修饰的属性是全局的，CPU向GPU发送数据可以使用，定义在`片段着色器`中可接收`顶点着色器`以外进行的值传递
这里将片段着色器修改成以下：
```
const char *fragmentShaderSource =
"#version 330 core\n"
"out vec4 FragColor;\n"
"uniform vec4 ourColor;\n" // 接受外部的数据
"void main() {\n"
"   FragColor = ourColor;\n" // 将外面传来的文理颜色进行赋值
"}\n\0"
```
这里用`uniform`修饰了一个`ourColor`属性，在着色器内部的函数中，将这个`ourColor`属性值传递给`FragColor`供着色器渲染使用。
其他代码和上一步一样，唯一不同的是在渲染中加入以下一段代码
```
// update shader uniform
float timeValue = glfwGetTime();
float redValue = sin(timeValue)/2.0f + 0.5f; // 设置红色随时间进行变化
// 拿到ourcolor信息
int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
// 进行赋值
glUniform4f(vertexColorLocation, redValue, 0.0, 0.0, 1.0);
```
这段代码的功能是，拿到`Uniform`修饰的属性`ourColor`然后进行赋值，这里给的值时随着时间变化的颜色值。


代码具体插入的位置是：
在代码
```
// 绘制三角形
// 使用着色器程序进行渲染
glBindVertexArray(VAO);
```
之后，
在代码
```
// 绘制物体
// 第一个参数：图元的类型，这里是三角形
// 第二个参数：顶点数组的起始索引，这里是0
// 第三个参数：要绘制的顶点个数，三角形，绘制三个
glDrawArrays(GL_TRIANGLES, 0, 3);
```
之前。
整个渲染循环就是：
```
// render loop
while (!glfwWindowShouldClose(window)) {
// input
processInput(window);

// render
// -----

// 清屏
glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
glClear(GL_COLOR_BUFFER_BIT);

// 绘制三角形
// 使用着色器程序进行渲染
glBindVertexArray(VAO);

// update shader uniform
float timeValue = glfwGetTime();
float redValue = sin(timeValue)/2.0f + 0.5f; // 设置红色随时间进行变化
// 拿到ourcolor信息
int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
// 进行赋值
glUniform4f(vertexColorLocation, redValue, 0.0, 0.0, 1.0);

// 绘制物体
// 第一个参数：图元的类型，这里是三角形
// 第二个参数：顶点数组的起始索引，这里是0
// 第三个参数：要绘制的顶点个数，三角形，绘制三个
glDrawArrays(GL_TRIANGLES, 0, 3);

// 会交换颜色缓冲
glfwSwapBuffers(window);
// 捕捉事件
glfwPollEvents();
}
```
然后运行项目，即可看到一个颜色渐变的三角形。


## 3、片段着色器的数据来自顶点数组对象
#### 3.1 顶点数组对象调整
这段示例将体现`片段着色器`的数据来源自`顶点数组对象`，即和`顶点着色器`来自同一个数据源
这里我们将顶点数据数组进行扩展
之前是：
```
float vertices[] = {
-0.5f, -0.5f, 0.0f, // 左
0.5f, -0.5f, 0.0f, // 右
0.0f,  0.5f, 0.0f, // 上
};
```
现在是：
```
float vertices[] = {
// 位置                 // 颜色
0.5f,  -0.5f, 0.0f,    1.0, 0.0, 0.0,// 右下 红
-0.5f, -0.5f, 0.0f,    0.0, 1.0, 0.0,// 左下 绿
0.0f,  0.5f,  0.0f,    0.0, 0.0, 1.0// 上上 蓝
};
```
那么整个初始化顶点数据，并绑定、填充到缓冲区的代码就变成：
```
/**
三角形：初始化顶点数据，并绑定、填充到缓冲区 ---- 附带颜色数据

@param VAO 顶点数据对象
@param VBO 顶点缓冲对象
*/
void bindTriangle(unsigned int *VAO, unsigned int *VBO) {
float vertices[] = {
// 位置                 // 颜色
0.5f,  -0.5f, 0.0f,    1.0, 0.0, 0.0,// 右下 红
-0.5f, -0.5f, 0.0f,    0.0, 1.0, 0.0,// 左下 绿
0.0f,  0.5f,  0.0f,    0.0, 0.0, 1.0// 上上 蓝
};
glGenVertexArrays(1, VAO);
glGenBuffers(1, VBO);

// 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
// 复制顶点数组到缓冲中供OpenGL使用
glBindVertexArray(*VAO);
glBindBuffer(GL_ARRAY_BUFFER, *VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}
```
#### 3.2 着色器源码调整
`片段着色器`中的颜色值要从`顶点数组对象`中获取，那么相应的`顶点着色器`和`片段着色器`的源码也要进行调整。这里的调整，就是和接收`位置`数据一样，添加接收`颜色`数据。
`顶点着色器`添加了一个`in`修饰的`aColor`接收颜色值的属性，和位置属性`aPos`一样，需要添加`layout`修饰，另外`颜色`数据的读取的下标和`位置`的读取下标是不一样的，`位置`的读取下标是`0`，`颜色`的读取下标后延是`1`，这个在上面的`顶点数组对象`中的数据源也可以看出，每一个颜色值都是较位置值偏移了1个下标（3个数据位置，位置信息是3个值表示）。
另外，`顶点着色器`读取了`顶点数组对象`中的数据后，需要传递给`片段着色器`，那这里就用到了这篇文章中的第一个知识点，`着色器传值`，这里就不重复描述，直接给出调整后的代码：
```
// GLSL顶点着色器源码
const char *vertexShaderSource =
"#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"   // 从0的位置区
"layout (location = 1) in vec3 aColor;\n" // 从1的位置取
"out vec3 vertexColor;\n" // 顶点着色器的颜色输出
"void main() {\n"
"   gl_Position = vec4(aPos, 1.0);\n"
"   vertexColor = aColor;\n" // 这里给棕色
"}\n\0";

// GLSL片段着色器，计算像素最后的颜色输出
const char *fragmentShaderSource =
"#version 330 core\n"
"out vec4 FragColor;\n"
"in  vec3 vertexColor;\n" // 接受顶点着色器传递的值
"void main() {\n"
//"   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n"
"   FragColor = vec4(vertexColor, 1.0);\n" // 将顶点着色器传来的文理颜色进行赋值
"}\n\0";
```



#### 3.3 数据解析调整
由于`顶点数据对象`较之前有所变化，那么在告诉Opengl如何解析数据就需要进行调整，调整的具体如下：
- 调整位置数据解析
将这段
```
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), (void *)0);
glEnableVertexAttribArray(0);
```
替换成
```
// 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为6
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);
```
这段具体调整的是解析的`步长`，之前只有顶点（位置）是从`顶点数组对象`中获取的，因此每个点获取三个数据，那么步长就是三个数据，即`3*sizeof(float)`。那么现在不仅有位置还有颜色也是从里面取的，所以步长是6个数据（3个位置、3个颜色数据）即`6*sizeof(float)`。

- 添加颜色数据解析
由于`片段着色器`的颜色数据来源也来自于`顶点数组对象`，因此需要添加上颜色的数据解析。
这里只需要在`顶点着色器`数据解析
```
// 颜色属性 从1开始, 偏移量是3
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void *)(3 * sizeof(float)));
// 以顶点位置1作为参数启用顶点属性 --- 颜色
glEnableVertexAttribArray(1);
```
解析颜色数据和解析位置数据的逻辑是一样的，唯一不一样的是，颜色数据的起始位置是1，位置数据的起始位置是0，这也是这两句代码的唯一区别。这里的起始位置，也就对应上了`顶点着色器`中的两个接收值的下标位置信息了。

通过以上的调整，运行代码，即可看到效果。

## 4、自定义着色器

