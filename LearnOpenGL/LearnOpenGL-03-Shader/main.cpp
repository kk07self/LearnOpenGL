//
//  main.cpp
//  LearnOpenGL-03-Shader
//
//  Created by tutu on 2019/5/5.
//  Copyright © 2019 KK. All rights reserved.
//

#include <iostream>
#include <cmath>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

void bindTriangle(unsigned int *VAO, unsigned int *VBO);
void bindRectangle(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO);
void bindMore(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO);

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;


#pragma mark - 顶点着色器与片段着色器传递值
// 顶点着色器的输出值和片段着色器的输入值一样即可满足传递
// 例如
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
//const char *fragmentShaderSource =
//"#version 330 core\n"
//"out vec4 FragColor;\n"
//"in vec4 vertexColor;\n" // 接受顶点着色器传递的值
//"void main() {\n"
////"   FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n"
//"   FragColor = vertexColor;\n" // 将顶点着色器传来的文理颜色进行赋值
//"}\n\0";

#pragma mark - Uniform
// uniform是全局的，CPU向GPU发送数据
const char *fragmentShaderSource =
"#version 330 core\n"
"out vec4 FragColor;\n"
"uniform vec4 ourColor;\n" // 接受外部的数据
"void main() {\n"
"   FragColor = ourColor;\n" // 将外面传来的文理颜色进行赋值
"}\n\0";



int main(int argc, const char * argv[]) {
    
    // glfw 初始化及设置
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // on OS X
#endif
    
    // 创建window
    GLFWwindow *window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL-02", NULL, NULL);
    if (window == NULL) {
        // 创建失败
        std::cout << "创建窗口失败" << std::endl;
        glfwTerminate();
        return -1;
    }
    // 将窗口的上下文设置为主线程的上下文
    glfwMakeContextCurrent(window);
    // 设置屏幕尺寸大小回调
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    
    // glad : 初始化OpenGL的指针管理器
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        // 没有初始化成功
        std::cout << "初始化指针管理器失败"  << std::endl;
        return -1;
    }
    
    
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
    
    unsigned int VAO, VBO; // 顶点数组对象，顶点缓冲对象，索引缓冲对象
    // 绘制三角形
    bindTriangle(&VAO, &VBO);
    
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
    
    // 删除顶点数据
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    
    glfwTerminate();
    return 0;
}


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
    glGenVertexArrays(1, VAO);
    glGenBuffers(1, VBO);
    
    // 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
    // 复制顶点数组到缓冲中供OpenGL使用
    glBindVertexArray(*VAO);
    glBindBuffer(GL_ARRAY_BUFFER, *VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}


// 监听是否点击了退出按键
void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
    glViewport(0, 0, width, height);
}

