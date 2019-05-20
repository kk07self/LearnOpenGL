//
//  main.cpp
//  LearnOpenGL-12-LightCasters
//
//  Created by KK on 2019/5/17.
//  Copyright © 2019 KK. All rights reserved.
//

#include <cmath>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "shader/shader.hpp"
#include <iostream>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "../stb_image/stb_image.h"

#include "Camera.hpp"



unsigned int creatTexture(const char* imagePath);

// 摄像机类： 初始化加了位置向量
Camera camera(glm::vec3(0.0f, 0.0f, 3.0f));

// 控制变动速度
float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间

// lighting
glm::vec3 lightPos(0.0f, -0.2f, 2.0f);

// 控制鼠标移动
bool firstMouse = true;
double lastX = 400.0f;
double lastY = 300.0f;



// 鼠标移动回调
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
// 鼠标滚轮
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);

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
    
    Shader lightShader("shader/lightShader.vs","shader/lightShader.fs");
    
    // 绘制矩形
    float vertices[] = {
        // positions          // normals           // texture coords
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
    };
    
    // 定义了10个立方体 的位移值
    // world space positions of our cubes
    glm::vec3 cubePositions[] = {
        glm::vec3( 0.0f,  0.0f,  0.0f),
        glm::vec3( 2.0f,  5.0f, -15.0f),
        glm::vec3(-1.5f, -2.2f, -2.5f),
        glm::vec3(-3.8f, -2.0f, -12.3f),
        glm::vec3( 2.4f, -0.4f, -3.5f),
        glm::vec3(-1.7f,  3.0f, -7.5f),
        glm::vec3( 1.3f, -2.0f, -2.5f),
        glm::vec3( 1.5f,  2.0f, -2.5f),
        glm::vec3( 1.5f,  0.2f, -1.5f),
        glm::vec3(-1.3f,  1.0f, -1.5f)
    };
    
    // positions of the point lights
    glm::vec3 pointLightPositions[] = {
        glm::vec3( 0.7f,  0.2f,  2.0f),
        glm::vec3( 2.3f, -3.3f, -4.0f),
        glm::vec3(-4.0f,  2.0f, -12.0f),
        glm::vec3( 0.0f,  0.0f, -3.0f)
    };
    
    // 物体的
    unsigned int VAO, VBO; // 顶点数组对象，顶点缓冲对象，索引缓冲对象
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBindVertexArray(VAO);
    
    // 告诉opengl如何读取数据
    // 步长为6
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)0);
    // 以顶点位置0作为参数启用顶点属性
    glEnableVertexAttribArray(0);
    
    // 法向量的值读取方式
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    // 纹理坐标
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);
    
    // 光源的
    unsigned int lightVAO;
    glGenVertexArrays(1, &lightVAO);
    glBindVertexArray(lightVAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    // 告诉opengl如何读取数据
    // 步长为8
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)0);
    // 以顶点位置0作为参数启用顶点属性
    glEnableVertexAttribArray(0);
    
    // 创建纹理-------------------------------------
    // 创建文理：1> 生成纹理 2> 绑定纹理 3> 设置纹理属性
    unsigned int texture1 = creatTexture("../resources/container2.png");
    unsigned int texture2 = creatTexture("../resources/container2_specular.png");
    
    ourShader.use();
    ourShader.setInt("material.diffuse", 0);
    ourShader.setInt("material.specular", 1);
    
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
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        ourShader.use();
        
        // 设置观察位置
        ourShader.setVec3("viewPos", camera.Position);
        
        // 设置材质
        // 反光度
        ourShader.setFloat("material.shininess", 32.0f);
        ourShader.setInt("material.diffuse", 0);
        ourShader.setInt("material.specular", 1);

        // 定位光源
        ourShader.setVec3("dirLight.direction", -0.2f, -1.0f, -0.3f);
        ourShader.setVec3("dirLight.ambient", 0.05f, 0.05f, 0.05f);
        ourShader.setVec3("dirLight.diffuse", 0.4f, 0.4f, 0.4f);
        ourShader.setVec3("dirLight.specular", 0.5f, 0.5f, 0.5f);
        
        // 点光源
        // point light 1
        ourShader.setVec3("pointLights[0].position", pointLightPositions[0]);
        ourShader.setVec3("pointLights[0].ambient", 0.05f, 0.05f, 0.05f);
        ourShader.setVec3("pointLights[0].diffuse", 0.8f, 0.8f, 0.8f);
        ourShader.setVec3("pointLights[0].specular", 1.0f, 1.0f, 1.0f);
        ourShader.setFloat("pointLights[0].constant", 1.0f);
        ourShader.setFloat("pointLights[0].linear", 0.09);
        ourShader.setFloat("pointLights[0].quadratic", 0.032);
        // point light 2
        ourShader.setVec3("pointLights[1].position", pointLightPositions[1]);
        ourShader.setVec3("pointLights[1].ambient", 0.05f, 0.05f, 0.05f);
        ourShader.setVec3("pointLights[1].diffuse", 0.8f, 0.8f, 0.8f);
        ourShader.setVec3("pointLights[1].specular", 1.0f, 1.0f, 1.0f);
        ourShader.setFloat("pointLights[1].constant", 1.0f);
        ourShader.setFloat("pointLights[1].linear", 0.09);
        ourShader.setFloat("pointLights[1].quadratic", 0.032);
        // point light 3
        ourShader.setVec3("pointLights[2].position", pointLightPositions[2]);
        ourShader.setVec3("pointLights[2].ambient", 0.05f, 0.05f, 0.05f);
        ourShader.setVec3("pointLights[2].diffuse", 0.8f, 0.8f, 0.8f);
        ourShader.setVec3("pointLights[2].specular", 1.0f, 1.0f, 1.0f);
        ourShader.setFloat("pointLights[2].constant", 1.0f);
        ourShader.setFloat("pointLights[2].linear", 0.09);
        ourShader.setFloat("pointLights[2].quadratic", 0.032);
        // point light 4
        ourShader.setVec3("pointLights[3].position", pointLightPositions[3]);
        ourShader.setVec3("pointLights[3].ambient", 0.05f, 0.05f, 0.05f);
        ourShader.setVec3("pointLights[3].diffuse", 0.8f, 0.8f, 0.8f);
        ourShader.setVec3("pointLights[3].specular", 1.0f, 1.0f, 1.0f);
        ourShader.setFloat("pointLights[3].constant", 1.0f);
        ourShader.setFloat("pointLights[3].linear", 0.09);
        ourShader.setFloat("pointLights[3].quadratic", 0.032);
        
        // 聚合光源
        ourShader.setVec3("spotLight.position", camera.Position);
        ourShader.setVec3("spotLight.direction", camera.Front);
        ourShader.setVec3("spotLight.ambient", 0.2f, 0.2f, 0.2f);
        ourShader.setVec3("spotLight.diffuse", 1.0f, 1.0f, 1.0f);
        ourShader.setVec3("spotLight.specular", 1.0f, 1.0f, 1.0f);
        ourShader.setFloat("spotLight.constant", 1.0f);
        ourShader.setFloat("spotLight.linear", 0.09);
        ourShader.setFloat("spotLight.quadratic", 0.032);
        ourShader.setFloat("spotLight.cutOff", glm::cos(glm::radians(12.5f)));
        ourShader.setFloat("spotLight.outerCutOff", glm::cos(glm::radians(17.5f)));
        
        
        // view/projection transformations
        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH / (float)SCR_HEIGHT, 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        ourShader.setMat4("projection", projection);
        ourShader.setMat4("view", view);
        
        // world transformation
        glm::mat4 model = glm::mat4(1.0f);
        ourShader.setMat4("model", model);
        
        // 绘制纹理图片
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);
        
        // 绘制四角形
        // 使用着色器程序进行渲染
        glBindVertexArray(VAO);
        for (unsigned int i = 0; i < 10; i++)
        {
            // calculate the model matrix for each object and pass it to shader before drawing
            glm::mat4 model = glm::mat4(1.0f);
            // 位移
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * (i+1);
            // 旋转角度
            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
            ourShader.setMat4("model", model);
            
            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        
        // 使用我们的着色器进行渲染
        lightShader.use();
        lightShader.setMat4("view", view);
        lightShader.setMat4("projection", projection);
        
        // 绘制四角形
        // 使用着色器程序进行渲染
        glBindVertexArray(lightVAO);
        for (unsigned int i = 0; i < 4; i++) {
            model = glm::mat4(1.0f);
            model = glm::translate(model, pointLightPositions[i]);
            model = glm::scale(model, glm::vec3(0.2f)); // a smaller cube
            lightShader.setMat4("model", model);
            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        
        
        // 会交换颜色缓冲
        glfwSwapBuffers(window);
        
        // 捕捉事件
        glfwPollEvents();
    }
    
    // 删除顶点数据
    glDeleteVertexArrays(1, &VAO);
    glDeleteVertexArrays(1, &lightVAO);
    glDeleteBuffers(1, &VBO);
    
    glfwTerminate();
    return 0;
}


// 监听是否点击了退出按键
void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }
    
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
    camera.ProcessMouseMovement(xoffset, yoffset);
}


/**
 监听鼠标滚轮的回调
 
 @param window 窗口
 @param xoffset x移动到的位置
 @param yoffset y移动到的位置
 */
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    camera.ProcessMouseScroll(yoffset);
}


/**
 创建纹理
 
 @param imagePath 图片资源路径
 
 @return 创建后的纹理
 */
unsigned int creatTexture(const char* imagePath ) {
    unsigned int texture;
    // 1、创建1个texture给 texture
    glGenTextures(1, &texture);
    
    // 加载图片，并附加到纹理上
    int width, height, nrChannels;
    unsigned char *data = stbi_load(imagePath, &width, &height, &nrChannels, 0);
    if (data) {
        GLenum format;
        if (nrChannels == 1)
            format = GL_RED;
        else if (nrChannels == 3)
            format = GL_RGB;
        else format = GL_RGBA;
 
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // 为当前绑定的纹理自动生成所有需要的多级渐远纹理。
        glGenerateMipmap(GL_TEXTURE_2D);
    } else {
        std::cout << "Failed to load texture" << std::endl;
    }
    // 释放data
    stbi_image_free(data);
    return texture;
}

