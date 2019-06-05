//
//  CombineFilter.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/6/5.
//  Copyright © 2019 KK. All rights reserved.
//

#import "CombineFilter.h"
#import <GLKit/GLKit.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)


#pragma mark - ShaderString
/**************************************************/
NSString *const lsqTuSDKGPUCombineVertexShaderString = SHADER_STRING
(
 attribute vec2 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTexture2Coordinate;
 
 varying vec2 textureCoordinate;
 varying vec2 texture2Coordinate;
 
 void main()
 {
     gl_Position = vec4(position, 0.0, 1.0);
     textureCoordinate = inputTextureCoordinate.xy;
     texture2Coordinate = inputTexture2Coordinate.xy;
 }
 );

NSString *const lsqTuSDKGPUCombineFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 texture2Coordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float opacityPercent;
 
 void main()
 {
     vec3 baseColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     vec3 coverColor = texture2D(inputImageTexture2, texture2Coordinate).rgb;
     baseColor = mix(baseColor, coverColor, opacityPercent);
     
     gl_FragColor = vec4(baseColor, 1.0);
 }
 );


void checkCompileErrors(GLuint shader, NSString* type) {
    int success;
    char infoLog[1024];
    
    if (![type isEqualToString:@"PROGRAM"]) {
        glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
        if (!success) {
            glGetShaderInfoLog(shader, 1024, NULL, infoLog);
            NSLog(@"ERROR::SHADER_COMPILATION_ERROR of type: %@\n%s", type, infoLog);
        }
    } else {
        glGetProgramiv(shader, GL_LINK_STATUS, &success);
        if (!success) {
            glGetProgramInfoLog(shader, 1024, NULL, infoLog);
            NSLog(@"ERROR::PROGRAM_LINKING_ERROR of type:  %@\n%s", type, infoLog);
        }
    }
}

@interface CombineFilter()
{
    BOOL isInitProgram;
    GLuint _program;
    
}
@end

@implementation CombineFilter

- (void)calNewData {
    
    
    // buffer
    GLuint texture, frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, newTextureWidth, newTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    
    
    // 纹理方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // 帧缓存绑定纹理
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    
    
    // 设置视图窗口
    glViewport(0, 0, newTextureWidth, newTextureHeight);
    
    GLSLShader *shader = [GLSLShader shaderWithVertexPath:@"shader" fragmentPath:@"shader"];
    [shader use];
    
    GLuint aPostion = [shader getAttribLocation:@"aPos"];
    GLuint texCoord = [shader getAttribLocation:@"aTexCoord"];
    GLuint textureLoc  = [shader getUniformLocation:@"texture1"];
    
    
    // 将纹理id传给着色器
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.baseEffect.texture2d0.name);
    glUniform1i(textureLoc, 0);
    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * kVertexCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, tmpVertices, GL_STATIC_DRAW);
    
    // 坐标传值
    glEnableVertexAttribArray(aPostion);
    glVertexAttribPointer(aPostion, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, kVertexCount);
}

- (void)initProgram {
    
    if (isInitProgram) {
        return;
    }
    
    GLuint vertex = glCreateShader(GL_VERTEX_SHADER);
    const char *vertexC = [lsqTuSDKGPUCombineVertexShaderString UTF8String];
    int vertexStringLenght = (int)[lsqTuSDKGPUCombineVertexShaderString length];
    glShaderSource(vertex, 1, &vertexC, &vertexStringLenght);
    glCompileShader(vertex);
    checkCompileErrors(vertex, @"VERTEX");
    
    GLuint fragment = glCreateShader(GL_FRAGMENT_SHADER);
    const char *fragmentC = [lsqTuSDKGPUCombineVertexShaderString UTF8String];
    int fragmentStringLenght = (int)[lsqTuSDKGPUCombineVertexShaderString length];
    glShaderSource(fragment, 1, &fragmentC, &fragmentStringLenght);
    glCompileShader(fragment);
    checkCompileErrors(fragment, @"FRAGMENT");
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);
    checkCompileErrors(program, @"PROGRAM");
    _program = program;
    
    isInitProgram = YES;
}

@end
