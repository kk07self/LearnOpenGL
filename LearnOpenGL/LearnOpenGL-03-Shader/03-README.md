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


## 4、自定义着色器类
创建、编译、绑定、管理着色器是一系列重复、麻烦的事，在这里会写一个类来统一管理这些工作，避免繁杂重复的工作。

### 4.1 创建着色器类
#### 4.1.1 创建shader文件
这一步我们创建一个shader文件`shader.hpp`，在里面倒入需要的头文件
```
#include <stdio.h>
#include <glad/glad.h> // 包含glad来获取所有的必须OpenGL头文件

#include <string>
#include <fstream> // 读取文件流
#include <sstream>
#include <iostream>
```

#### 4.1.2 创建Shader类
在头文件`shader.hpp`中创建`Shader`类；
添加一个`ID`属性，用于绑定着色器的时候使用；
创建`构造函数`和`使用函数`，这里`构造函数`需要两个参数，一个是`vertexPath`和`fragmentPath`，对应`顶点着色器`和`片段着色器`源文件路径
```
class Shader
{
public:
// 程序ID
unsigned int ID;

// 构造器读取并构建着色器
Shader(const GLchar* vertexPath, const GLchar* fragmentPath);
// 使用/激活程序
void use();
};
```

#### 4.1.3 构造函数等函数实现
构造函数除了创建`Shader`类的对象，还需要完成`着色器`的创建、编译和绑定

- 1、读取文件中`着色器`的源代码流
```
// 1. 从文件滤镜获取顶点/片段着色器
std::string vertexCode;
std::string fragmentCode;
std::ifstream vShaderFile;
std::ifstream fShaderFile;

// 保证ifstream对象可抛出异常
vShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
fShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);

try {
// 打开文件
vShaderFile.open(vertexPath);
fShaderFile.open(fragmentPath);
// 定义数据流
std::stringstream vShaderStream, fShaderStream;
// 读取文件数据到数据流中
vShaderStream << vShaderFile.rdbuf();
fShaderStream << fShaderFile.rdbuf();

// 关闭文件
vShaderFile.close();
fShaderFile.close();

// 转换数据流到string
vertexCode = vShaderStream.str();
fragmentCode = fShaderStream.str();
} catch (std::ifstream::failure e) {
std::cout << "ERROR:: SHADER::FILE_NOT_SUCCESFULLY_READ" << std::endl;
}

const char *vShaderCode = vertexCode.c_str();
const char *fShaderCode = fragmentCode.c_str();
```
- 2、创建、编译、绑定着色器
```
// 2. 编译着色器
unsigned int vertex, fragment;
// 顶点着色器创建、编译
vertex = glCreateShader(GL_VERTEX_SHADER);
glShaderSource(vertex, 1, &vShaderCode, NULL);
glCompileShader(vertex);
checkCompileErrors(vertex, "VERTEX");
// 片段着色器创建、编译
fragment = glCreateShader(GL_FRAGMENT_SHADER);
glShaderSource(fragment, 1, &fShaderCode, NULL);
glCompileShader(fragment);
checkCompileErrors(fragment, "FRAGMENT");

// 3. 着色器绑定
ID = glCreateProgram();
glAttachShader(ID, vertex);
glAttachShader(ID, fragment);
glLinkProgram(ID);
checkCompileErrors(ID, "PROGRAM");

glDeleteShader(vertex);
glDeleteShader(fragment);
```
从前几个示例中我们可以看到，每一步的编译、绑定都需要check下是否成功，为了避免代码冗余，这里将check的代码封装到了一个私有方法中。
```

private:
// 查看编译/ 绑定是否成功
    void checkCompileErrors(unsigned int shader, std::string type) {
        int success;
        char infoLog[1024];
        if (type != "PROGRAM") {
            glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
            if (!success)
            {
                glGetShaderInfoLog(shader, 1024, NULL, infoLog);
                std::cout << "ERROR::SHADER_COMPILATION_ERROR of type: " << type << "\n" << infoLog << "\n -- --------------------------------------------------- -- " << std::endl;
            }
        } else {
            glGetProgramiv(shader, GL_LINK_STATUS, &success);
            if (!success)
            {
                glGetProgramInfoLog(shader, 1024, NULL, infoLog);
                std::cout << "ERROR::PROGRAM_LINKING_ERROR of type: " << type << "\n" << infoLog << "\n -- --------------------------------------------------- -- " << std::endl;
            }
        }
    }
```

- 4、Shader的使用
这里很简单，就是拿到程序的`ID`（保存在类`Shader`的属性`ID`中），进行使用
```
// 使用/激活程序
void use()
{
    glUseProgram(ID);
}
```

### 4.2 创建着色器源码文件
这一步是将`顶点着色器`和`片段着色器`的源码放在单独的文件中，这一步即对于上一步中`Shader`类构造方法中两个文件路径参数（`vertexPath`和`fragmentPath`）。
这里新建了两个空文件，`Shader.vs`和`Shader.fs`分别对于`顶点着色器`和`片段着色器`。
然后将源码放到对于的文件中。
`Shader.vs`文件中的`着色器`源码是：
```
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
out vec3 vertexColor;
void main() {
gl_Position = vec4(aPos, 1.0);
vertexColor = aColor;
}
```
`Shader.fs`文件中的`着色器`源码是：
```
#version 330 core
out vec4 FragColor;
in  vec3 vertexColor;
void main() {
FragColor = vec4(vertexColor, 1.0);
}

```

到这一步为止，我们的轮子造好了，下一步就是使用了。

### 4.3 使用自定义的着色器类
和之前没有使用`着色器`类相比，代码上只有两部分出入，一是着色器的创建、编译和绑定，二是着色器程序的使用。

- 1、着色器的创建、编译和绑定
将之前创建、编译、和绑定的代码全部删除
即这些代码删除
```
// build and compile our shader program
// ------------------------------------
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
替换成以下代码
```
// 使用我们自定义的着色器类
Shader ourShader("Shader.vs","Shader.fs");
```
这一步是用`Shader`类的构造方法，创建了一个`ourShader`对象，这里传入了着色器源码的文件路径。
内部会完成着色器的创建、编译和绑定。

- 2、着色器对象的使用
将之前使用程序的代码
```
glUseProgram(shaderProgram);
```
替换成
```
ourShader.use();
```
即可。

以上就完成了自定义着色器类的使用，相比于之前那些冗余的代码，这样的方式更加简介清晰。
运行程序，即可看到和之前一样的效果。
