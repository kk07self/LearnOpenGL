//
//  ShaderParameterPassing.hpp
//  LearnOpenGL-03-Shader
//
//  Created by KK on 2019/5/12.
//  Copyright © 2019 KK. All rights reserved.
//

#ifndef ShaderParameterPassing_hpp
#define ShaderParameterPassing_hpp

#include <stdio.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

int shaderParameterPassingProgram();

#endif /* ShaderParameterPassing_hpp */
