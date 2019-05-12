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
#include <glad/glad.h>; // 包含glad来获取所有的必须OpenGL头文件

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

class Shader {
    
public:
    // 程序id
    unsigned int ID;
    
    // 构造器读取并创建着色器
    Shader(const GLchar* vertexPath, const GLchar* fragmentPath);
    
    // 使用/激活程序
    void use();
    // uniform工具函数
    void setBool(const std::string &name, bool value) const;
    void setInt(const std::string &name, int value) const;
    void setFloat(const std::string &name, float value) const;
};

#endif /* shader_hpp */
