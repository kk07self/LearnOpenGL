//
//  main.cpp
//  LearnOpenGL-07-Camera
//
//  Created by tutu on 2019/5/15.
//  Copyright © 2019 KK. All rights reserved.
//

#include "../stb_image/stb_image.h"
#include <cmath>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "shader/shader.hpp"
#include <iostream>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "Camera.hpp"

#define Camera_Class



typedef enum ImageType : int {
    ImageType_RGB,
    ImageType_RGBA,
} ImageType;


// 摄像机类： 初始化加了位置向量
Camera camera(glm::vec3(0.0f, 0.0f, 3.0f));

// 摄像机变量
glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);

// 控制变动速度
float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间

// 控制鼠标移动
bool firstMouse = true;
double lastX = 400.0f;
double lastY = 300.0f;

float yaw = -90.0f; // 偏航角角度
float pitch = 0.0f; // 俯仰角角度

float fov = 45.0f;

// 鼠标移动回调
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
// 鼠标滚轮
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);

// 创建纹理
unsigned int creatTexture(const char* imagePath, const ImageType imageType);

void bindRectangle(unsigned int *VAO, unsigned int *VBO);
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
    // 设置鼠标移动回调
    glfwSetCursorPosCallback(window, mouse_callback);
    // 设置鼠标滚轮回调
    glfwSetScrollCallback(window, scroll_callback);
    
    // glad : 初始化OpenGL的指针管理器
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        // 没有初始化成功
        std::cout << "初始化指针管理器失败"  << std::endl;
        return -1;
    }
    
    // 开启深度测试
    // -----------------------------
    glEnable(GL_DEPTH_TEST);
    
    // 使用我们自定义的着色器类
    Shader ourShader("shader/shader.vs","shader/shader.fs");
    
    
    unsigned int VAO, VBO; // 顶点数组对象，顶点缓冲对象，索引缓冲对象
    // 绘制矩形
    bindRectangle(&VAO, &VBO);
    
    // 定义了10个立方体 的位移值
    // world space positions of our cubes
    glm::vec3 cubePositions[] = {
        glm::vec3( 0.0f,  0.0f,  0.0f),
        glm::vec3( 2.0f,  5.0f, -10.0f),
        glm::vec3(-1.5f, -2.2f, -2.5f),
        glm::vec3(-3.8f, -2.0f, -10.3f),
        glm::vec3( 2.4f, -0.4f, -3.5f),
        glm::vec3(-1.7f,  3.0f, -7.5f),
        glm::vec3( 1.3f, -2.0f, -2.5f),
        glm::vec3( 1.5f,  2.0f, -2.5f),
        glm::vec3( 1.5f,  0.2f, -1.5f),
        glm::vec3(-1.3f,  1.0f, -1.5f)
    };
    
    
    // 告诉opengl如何读取数据
    // 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为5
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)0);
    // 以顶点位置0作为参数启用顶点属性
    glEnableVertexAttribArray(0);
    
    // 文理设置 从1开始, 偏移量是3
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)(3 * sizeof(float)));
    // 以顶点位置1作为参数启用顶点属性 ---
    glEnableVertexAttribArray(1);
    
    
    // 创建纹理-------------------------------------
    // 创建文理：1> 生成纹理 2> 绑定纹理 3> 设置纹理属性
    unsigned int texture1 = creatTexture("../resources/container.jpg", ImageType_RGB);
    unsigned int texture2 = creatTexture("../resources/awesomeface.png", ImageType_RGBA);
    
    
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
        
        // 计算上一帧的时间搓
        // --------------------
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        
        // input
        processInput(window);
        
        // render
        // -----
        
        // 清屏
        glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // 绘制纹理
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        
        // 使用我们的着色器进行渲染
        ourShader.use();
        
        // 观察矩阵
        glm::mat4 view          = glm::mat4(1.0f);

//        float radius = 20.0f;
//        float camX = sin(glfwGetTime()) * radius;
//        float camZ = cos(glfwGetTime()) * radius;
        
        // 摄像机的位置不断变化，达到旋转的效果
        // 相机的位置+目标位置+时间空间中的上向量的向量
//        view = glm::lookAt(glm::vec3(camX, 0.0, camZ), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0));
        
        // 透视矩阵
        glm::mat4 projection    = glm::mat4(1.0f);
//        projection = glm::perspective(glm::radians(45.0f), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
#ifdef Camera_Class
        view = camera.GetViewMatrix();
        projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
#else
        view = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
        // 随着鼠标滚轮的滚动进行调整
        projection = glm::perspective(glm::radians(fov), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
#endif
        
        ourShader.setMat4("view", view);
        ourShader.setMat4("projection", projection);
        
        // 绘制四角形
        // 使用着色器程序进行渲染
        glBindVertexArray(VAO);
        for (unsigned int i = 0; i < 10; i++)
        {
            // calculate the model matrix for each object and pass it to shader before drawing
            glm::mat4 model = glm::mat4(1.0f);
            // 位移
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * (i);
            // 旋转角度
            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
            ourShader.setMat4("model", model);
            
            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        
        //        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, 0);
        // 绘制顶点
        //        glDrawArrays(GL_TRIANGLES, 0, 36);
        
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
void bindRectangle(unsigned int *VAO, unsigned int *VBO) {
    
    // 顶点数据数组，包含纹理数据
    // 纹理是2维数据，范围是(0,0)左下-(1,1)右上
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
    
#ifdef Camera_Class
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
        camera.ProcessKeyBoard(Camera_Movement_FORWARD, deltaTime);
    }
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
        camera.ProcessKeyBoard(Camera_Movement_BACKWARD, deltaTime);
    }
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
        camera.ProcessKeyBoard(Camera_Movement_LEFT, deltaTime);
    }
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
        camera.ProcessKeyBoard(Camera_Movement_RIGHT, deltaTime);
    }
#else
    float cameraSpeed = 2.5f * deltaTime;
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
        cameraPos += cameraSpeed * cameraFront; // 向前移动
    }
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
        cameraPos -= cameraSpeed * cameraFront; // 向后移动
    }
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
        cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed; // 左移动
    }
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
        cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed; // 右移动
    }
#endif
    
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
    glViewport(0, 0, width, height);
}


/**
 监听鼠标移动回调

 @param window 窗口
 @param xpos 移动到当前的x值
 @param ypos 移动到当前的y值
 */
void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    
    // 控制第一次鼠标进入屏幕会闪动的问题
    if(firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }
    
    // 计算两次移动的偏移量
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;
    // 刷新上一次变动的值
    lastX = xpos;
    lastY = ypos;
    
#ifdef Camera_Class
    camera.ProcessMouseMovement(xoffset, yoffset);
#else
    
    
    // 将偏移量进行灵敏度处理
    float sensitivity = 0.05;
    xoffset *= sensitivity;
    yoffset *= sensitivity;
    
    // 将偏移量放到全局角度变量上
    yaw   += xoffset;
    pitch += yoffset;
    
    // 角度最大值最小值限制
    if(pitch > 89.0f)
        pitch = 89.0f;
    if(pitch < -89.0f)
        pitch = -89.0f;
    
    // 通过俯仰角和偏航角计算真正的方向向量
    glm::vec3 front;
    front.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
    front.y = sin(glm::radians(pitch));
    front.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
    cameraFront = glm::normalize(front);
    
#endif
}


/**
 监听鼠标滚轮的回调

 @param window 窗口
 @param xoffset x移动到的位置
 @param yoffset y移动到的位置
 */
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
#ifdef Camera_Class
    camera.ProcessMouseScroll(yoffset);
#else
    if (fov >= 1.0f && fov <= 45.0f)
        fov -= yoffset;
    if (fov <= 1.0f)
        fov = 1.0f;
    if (fov >= 45.0f)
        fov = 45.0f;
#endif
}

