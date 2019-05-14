//
//  main.cpp
//  LearnOpenGL-05-Transform
//
//  Created by tutu on 2019/5/14.
//  Copyright © 2019 KK. All rights reserved.
//

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

// glm
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "shader/shader.hpp"
#include "../stb_image/stb_image.h"

typedef enum ImageType : int {
    ImageType_RGB,
    ImageType_RGBA,
} ImageType;

unsigned int creatTexture(const char* imagePath, const ImageType imageType);

void bindRectangle(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO);
void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;


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
    
    // 使用我们自定义的着色器类
    Shader ourShader("shader/Shader.vs","shader/Shader.fs");
    
    
    unsigned int VAO, VBO, EBO; // 顶点数组对象，顶点缓冲对象，索引缓冲对象
    // 绘制矩形
    bindRectangle(&VAO, &VBO, &EBO);
    
    
    // 告诉opengl如何读取数据
    // 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为6
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)0);
    // 以顶点位置0作为参数启用顶点属性
    glEnableVertexAttribArray(0);
    
    //
    // 颜色属性 从1开始, 偏移量是3
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)(3 * sizeof(float)));
    // 以顶点位置1作为参数启用顶点属性 --- 颜色
    glEnableVertexAttribArray(1);
    
    // 文理设置 从2开始, 偏移量是6
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)(6 * sizeof(float)));
    // 以顶点位置1作为参数启用顶点属性 --- 颜色
    glEnableVertexAttribArray(2);
    
    
    // 创建纹理-------------------------------------
    // 创建文理：1> 生成纹理 2> 绑定纹理 3> 设置纹理属性
    unsigned int texture1 = creatTexture("resources/container.jpg", ImageType_RGB);
    unsigned int texture2 = creatTexture("resources/awesomeface.png", ImageType_RGBA);
    
    
    // 设置采样器
    // 在设置采样器之前先激活程序
    ourShader.use();
    
    // 设置片段着色器中两个纹理采样器, 第一个是0绑定这里的第一个纹理，第二个是1绑定这里的第二个纹理
    glUniform1i(glGetUniformLocation(ourShader.ID, "texture1"), 0);
    glUniform1i(glGetUniformLocation(ourShader.ID, "texture2"), 1);
    // 或者使用这个设置
    //    ourShader.setInt("texture1", 0);
    //    ourShader.setInt("texture2", 1);
    
    // render loop
    while (!glfwWindowShouldClose(window)) {
        // input
        processInput(window);
        
        // render
        // -----
        
        // 清屏
        glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // 绘制纹理
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        
        // mark: ------------ 新加的transformations
        // 初始化一个4x4的单位向量
        glm::mat4 transform = glm::mat4(1.0f);
        // 位移
        transform = glm::translate(transform, glm::vec3(0.5f, -0.5f, 0.0f));
        // 缩放
        transform = glm::scale(transform, glm::vec3(0.5f, 0.5f, 0.5f));
        // 旋转角度
        transform = glm::rotate(transform, (float)glfwGetTime(), glm::vec3(0.0, 0.0f, 1.0f));
        
        // 使用我们的着色器进行渲染
        ourShader.use();
        // 拿到着色器中的transform --- 变换矩阵，将值赋值过去
        unsigned int transformLoc = glGetUniformLocation(ourShader.ID, "transform");
        glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(transform));
        
        // 绘制四角形
        // 使用着色器程序进行渲染
        glBindVertexArray(VAO);
        
        glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, 0);
        
        // 会交换颜色缓冲
        glfwSwapBuffers(window);
        
        // 捕捉事件
        glfwPollEvents();
    }
    
    // 删除顶点数据
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    
    glfwTerminate();
    return 0;
}


/**
 创建纹理
 
 @param imagePath 图片资源路径
 @param imageType 图片资源格式：RGB或RGBA，目前支持这两个
 @return 创建后的纹理
 */
unsigned int creatTexture(const char* imagePath, const ImageType imageType) {
    unsigned int texture;
    // 1、创建1个texture给 texture
    glGenTextures(1, &texture);
    
    // 2、绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // 3、设置纹理样式
    // 3.1 设置纹理环绕方式，这里的S和T对应x,y坐标，如果3D则是STR对应xyz。
    // GL_REPEAT: 环绕方式，对纹理的默认行为。重复纹理图像。其他的还有：
    // GL_MIRRORED_REPEAT    和GL_REPEAT一样，但每次重复图片是镜像放置的。
    // GL_CLAMP_TO_EDGE    纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
    // GL_CLAMP_TO_BORDER    超出的坐标为用户指定的边缘颜色。这个需要设置边缘颜色，float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f }; glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    // 设置纹理过滤方式：GL_NEAREST和GL_LINEAR
    // GL_LINEAR: 线性过滤，(Bi)linear Filtering）它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。
    // 邻近过滤，Nearest Neighbor Filtering 是OpenGL默认的纹理过滤方式。当设置为GL_NEAREST的时候，OpenGL会选择中心点最接近纹理坐标的那个像素。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 加载图片，并附加到纹理上
    int width, height, nrChannels;
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data = stbi_load(imagePath, &width, &height, &nrChannels, 0);
    if (data) {
        // 第一个参数：纹理目标类型，这里是2D
        // 第二个参数：为纹理指定多级渐远纹理的级别，如果你希望单独手动设置每个多级渐远纹理的级别的话。这里我们填0，也就是基本级别。
        // 第三个参数：把纹理储存为何种格式, 这里是RGB
        // 第四、五个参数：设置最终的纹理的宽度和高度
        // 第六个参数：应该总是被设为0（历史遗留的问题）
        // 第七个参数：源图片的格式，RGB这里是
        // 第八个参数：传入的图片数据类型，这里data是char数组（byte）
        // 第九个参数：真正的图像数据
        glTexImage2D(GL_TEXTURE_2D, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, width, height, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
        // 为当前绑定的纹理自动生成所有需要的多级渐远纹理。
        glGenerateMipmap(GL_TEXTURE_2D);
    } else {
        std::cout << "Failed to load texture" << std::endl;
    }
    // 释放data
    stbi_image_free(data);
    return texture;
}


/**
 矩形：初始化顶点数据，并绑定、填充到缓冲区
 
 @param VAO 顶点数据对象
 @param VBO 顶点缓冲对象
 @param EBO 索引缓冲对象
 */
void bindRectangle(unsigned int *VAO, unsigned int *VBO, unsigned int *EBO) {
    
    // 顶点数据数组，包含纹理数据
    // 纹理是2维数据，范围是(0,0)左下-(1,1)右上
    float vertices[] = {
        
        // points           // colors           // texture coords
        0.5f,  0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   1.0f, 1.0f,// top right
        0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   1.0f, 0.0f,// bottom right
        -0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 0.0f,   0.0f, 0.0f, // bottom left
        -0.5f,  0.5f, 0.0f, 1.0f, 1.0f, 0.0f,   0.0f, 1.0f   // top left
    };
    // 索引数据
    unsigned int indices[] = {  // note that we start from 0!
        0, 1, 3,  // first Triangle
        1, 2, 3   // second Triangle
    };
    
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


// 监听是否点击了退出按键
void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
    glViewport(0, 0, width, height);
}
