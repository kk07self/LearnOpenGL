//
//  shader.hpp
//  LearnOpenGL-03-Shader
//
//  Created by KK on 2019/5/12.
//  Copyright © 2019 KK. All rights reserved.
//

#ifndef shader_hpp
#define shader_hpp

#include <stdio.h>
#include <glad/glad.h> // 包含glad来获取所有的必须OpenGL头文件

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

class Shader {
    
public:
    // 程序id
    unsigned int ID;
    
    // 构造器读取并创建着色器
    Shader(const GLchar* vertexPath, const GLchar* fragmentPath)
    {
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
    }
    
    // 使用/激活程序
    void use()
    {
        glUseProgram(ID);
    }
    
    // 查看编译/ 绑定是否成功
private:
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
    
    // uniform工具函数
    //    void setBool(const std::string &name, bool value) const
    //    {
    //        glUniform1i(glGetUniformLocation(ID, name.c_str()), (int)value);
    //    }
    //
    //    void setInt(const std::string &name, int value) const
    //    {
    //        glUniform1i(glGetUniformLocation(ID, name.c_str()), value);
    //    }
    //
    //    void setFloat(const std::string &name, float value) const
    //    {
    //        glUniform1f(glGetUniformLocation(ID, name.c_str()), value);
    //    }
    
};

#endif /* shader_hpp */
