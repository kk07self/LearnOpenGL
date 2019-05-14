# LearnOpenGL-02-Triangle
<br/>

>  此示例学习资源来自于[LearnOpenGL](https://learnopengl-cn.github.io/)，感谢！
<br/>

## 第二个示例：三角形
本示例和第一个窗口示例，整体的逻辑是一样的，区别在于教之前在屏幕上对渲染了三角形（也拓展了矩形等）

- 1、创建顶点着色器
    - 创建顶点着色器
    - 并配置着色器源码
    - 编译着色器：让openGL能够使用它
    
一个顶点（x, y, z）三个坐标的值
GLSL中向量是vec4，4个值表示，(x, y, z, w)，这里w先用1，后期会介绍
具体见以下代码
```
// GLSL顶点着色器源码
const char *vertexShaderSource =
"#version 330 core\n"
"layout (location = 0) in vec3 aPos;\n"
"void main() {\n"
"   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
"}\n\0";
```
```
// vertex shader, 顶点着色器
int vertexShader = glCreateShader(GL_VERTEX_SHADER);
glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
glCompileShader(vertexShader);
// 查看编译结果
int success;
char infoLog[512];
glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
if (!success) {
// 编译失败
glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
std::cout << "Error::Sharder::Vertex::Compilation_failed\n" << infoLog << std::endl;
}
```


- 2、创建片段着色器
这个过程和顶点着色器一样
    - 创建片段着色器
    - 设置片段着色器源码
    - 编译着色器源码
    
不同的是着色器是不同的，这里是片段着色器
片段着色器做的工作是，计算像素最后的颜色输出，这里设置成了红色（1.0，0，0，0，1）（rgba）

```
// GLSL片段着色器，计算像素最后的颜色输出
const char *fragmentShaderSource =
"#version 330 core\n"
"out vec4 FragColor;\n"
"void main() {\n"
"   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n"
"}\n\0";
```

```
// fragment shader, 片段着色器
int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
// 将着色器源码附加到着色器对象上，并编译
glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
glCompileShader(fragmentShader);
// 查看编译结果
glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
if (!success) {
glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
std::cout << "Error::Sharder::Fragment::Compilation_failed\n" << infoLog << std::endl;
}
```

- 3、绑定着色器: 通过着色器程序绑定多个着色器

```
// link shader, 链接着色器，通过着色器程序进行多个着色器合并
int shaderProgram = glCreateProgram();
glAttachShader(shaderProgram, vertexShader);
glAttachShader(shaderProgram, fragmentShader);
glLinkProgram(shaderProgram);
// 查看链接是否成功
glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
if (!success) {
// 链接失败
glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
std::cout << "Error::Sharder::Program::Linking_failed\n" << infoLog << std::endl;
}

// 删除shader，链接成功后就不需要了，需要清除他们
glDeleteShader(vertexShader);
glDeleteShader(fragmentShader);
```
- 4、设置、绑定顶点数据：数组对象，顶点缓冲对象，索引缓冲对象
这里示例了三组：分别是一个三角形、矩形（2个三角形）、多边形（多个三角形）
一个三角形：用的最简单的顶点数组对象进行设置；
矩形和多边形：用的是索引缓冲对象进行设置

```
/**
三角形：初始化顶点数据，并绑定、填充到缓冲区

@param VAO 顶点数据对象
@param VBO 顶点缓冲对象
*/
void bindTriangle(unsigned int *VAO, unsigned int *VBO) {
float vertices[] = {
-0.5f, -0.5f, 0.0f, // 左
0.5f, -0.5f, 0.0f, // 右
0.0f,  0.5f, 0.0f, // 上
};
// 创建顶点数组对象
glGenVertexArrays(1, VAO);
// 创建顶点缓冲对象
glGenBuffers(1, VBO);

// 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
// 复制顶点数组到缓冲中供OpenGL使用
glBindVertexArray(*VAO);

glBindBuffer(GL_ARRAY_BUFFER, *VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}
```
```
/**
矩形：初始化顶点数据，并绑定、填充到缓冲区

@param VAO 顶点数据对象
@param VBO 顶点缓冲对象
@param EBO 索引缓冲对象
*/
void bindRectangle(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO) {
// 顶点数据数组
float vertices[] = {
0.5f,  0.5f, 0.0f,  // top right
0.5f, -0.5f, 0.0f,  // bottom right
-0.5f, -0.5f, 0.0f,  // bottom left
-0.5f,  0.5f, 0.0f   // top left
};
// 索引数据
unsigned int indices[] = {  // note that we start from 0!
0, 1, 3,  // first Triangle
1, 2, 3   // second Triangle
};

// 创建对象
glGenVertexArrays(1, VAO);
glGenBuffers(1, VBO);
glGenBuffers(1, EBO);

// 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
// 复制顶点数组到缓冲中供OpenGL使用
glBindVertexArray(*VAO);

glBindBuffer(GL_ARRAY_BUFFER, *VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, *EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
}
```

```
/**
更多图形绘制：初始化顶点数据，并绑定、填充到缓冲区

@param VAO 顶点数据对象
@param VBO 顶点缓冲对象
@param EBO 索引缓冲对象
*/
void bindMore(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO) {
// 顶点数据数组
float vertices[] = {
0.5f,  0.5f, 0.0f,  // top right
0.5f, -0.5f, 0.0f,  // bottom right
-0.5f, -0.5f, 0.0f,  // bottom left
-0.5f,  0.5f, 0.0f,   // top left
0.0f, 0.5f, 0.0, // 上面中间点
-0.5f, 1.0f, 0.0f, // 最左上角
0.5f, 1.0f, 0.0, // 最右上角
};
// 索引数据
unsigned int indices[] = {  // note that we start from 0!
0, 1, 3, // first Triangle
1, 2, 3, // second Triangle
5, 4, 3, // 第三个
6, 4, 0  // 第四个
};

// 创建对象
glGenVertexArrays(1, VAO);
glGenBuffers(1, VBO);
glGenBuffers(1, EBO);

// 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
// 复制顶点数组到缓冲中供OpenGL使用
glBindVertexArray(*VAO);

glBindBuffer(GL_ARRAY_BUFFER, *VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, *EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
}

```
最后是需要删除这些对象的
```
// 删除顶点数据
glDeleteVertexArrays(1, &VAO);
glDeleteBuffers(1, &VBO);
glDeleteBuffers(1, &EBO);
```

- 5、链接顶点属性：告诉OpenGL如何解析顶点数据
具体可见以下代码的注释：
```
// 设置顶点属性指针，告诉OpenGL如何解析顶点数据
// 第一个参数：顶点属性的位置值，这里从第一个开始，即0
// 第二个参数：指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
// 第三个参数：指定数据的类型，这里是GL_FLOAT(GLSL中vec*都是由浮点数值组成的)。
// 第四个参数：是否希望数据被标准化。
//           如果我们设置为GL_TRUE，所有数据都会被映射到0（对于有符号型signed数据是-1）到1之间。
//           我们把它设置为GL_FALSE。
// 第五个参数：步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔。
// 第六个参数：类型是void*，所以需要我们进行这个奇怪的强制类型转换。它表示位置数据在缓冲中起始位置的偏移量(Offset)。
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);

// 解绑之前的绑定
glBindBuffer(GL_ARRAY_BUFFER, 0);
glBindVertexArray(0);
```


- 6、进行渲染：使用
具体见以下的注释
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
glUseProgram(shaderProgram);
glBindVertexArray(VAO);

// 绘制物体
// 第一个参数：图元的类型，这里是三角形
// 第二个参数：顶点数组的起始索引，这里是0
// 第三个参数：要绘制的顶点个数，三角形，绘制三个
//        glDrawArrays(GL_TRIANGLES, 0, 3);

// 绘制矩形, 1-绘制的模式：三角形    2-顶点个数：6个   3-索引的类型：unsigned int    4-索引起始位置： 0
//        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

// 这里绘制了4个三角形，12个点
glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, 0);

// 会交换颜色缓冲
glfwSwapBuffers(window);
// 捕捉事件
glfwPollEvents();
}
```
