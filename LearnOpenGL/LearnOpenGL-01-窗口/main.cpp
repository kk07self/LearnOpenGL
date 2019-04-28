//
//  main.cpp
//  LearnOpenGL-01
//
//  Created by KK on 2019/4/28.
//  Copyright © 2019 KK. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

void frameBuffer_size_callback(GLFWwindow *window, int width, int height);

int main(int argc, const char * argv[]) {
    
    // 初始化glfw，并配置信息
    glfwInit();
    // 主板版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    // 次版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    // 使用的是核心模式(Core-profile)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
#ifdef __APPLE__
    // Mac OS X系统需要设置
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    // 创建一个窗口
    GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    // 将我们窗口的上下文设置为当前线程的主上下文
    glfwMakeContextCurrent(window);
    
    // 注册窗口大小调整函数，每次调整回调都会调用callback的方法
    glfwSetFramebufferSizeCallback(window, frameBuffer_size_callback);
    
    // glad: load all OpenGL function pointers
    // glad: 管理OpenGL的函数指针，在OpenGL函数使用之前初始化glad
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }
    
    // render loop
    // 渲染循环
    while (!glfwWindowShouldClose(window)) {
        // input
        // process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
        // 监听按键，如果输入了ESC返回键，就结束这个渲染循环
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
            glfwSetWindowShouldClose(window, true);
        }
        
        // render
        // 这一部分原本应该放屏幕渲染的代码
        // 目前只是填充颜色来查看效果
        // 这里使用了清屏函数，清除屏幕的颜色，以红色为清屏颜色
        glClearColor(1.0, 0.0, 0.0, 1.0);   // rgba，状态设置函数
        glClear(GL_COLOR_BUFFER_BIT);       // 状态使用函数，使用状态设置函数设置的颜色来进行清屏操作
        
        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // 会交换颜色缓冲（它是一个储存着GLFW窗口每一个像素颜色值的大缓冲），它在这一迭代中被用来绘制，并且将会作为输出显示在屏幕上。
        glfwSwapBuffers(window);
        
        // 检查有没有触发什么事件（比如键盘输入、鼠标移动等）、更新窗口状态，并调用对应的回调函数（可以通过回调方法手动设置）
        glfwPollEvents();
    }
    
    // glfw: terminate, clearing all previously allocated GLFW resources.
    // 释放资源
    glfwTerminate();
    return 0;
}


// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// 通过回调告诉OpenGL要渲染的窗口大小
void frameBuffer_size_callback(GLFWwindow *window, int width, int height) {
    
    glViewport(0, 0, width, height);
}
