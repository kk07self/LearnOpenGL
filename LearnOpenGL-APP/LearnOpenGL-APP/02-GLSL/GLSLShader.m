//
//  GLSLShader.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/21.
//  Copyright © 2019 KK. All rights reserved.
//

#import "GLSLShader.h"

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


@interface GLSLShader()

/**
 programID
 */
@property (nonatomic, assign) GLuint program;

@end

@implementation GLSLShader

+ (instancetype)shaderWithVertexPath:(NSString *)vertexPath fragmentPath:(NSString *)fragmentPath {
    
    GLSLShader *shader = [[GLSLShader alloc] init];
    GLuint vertex   = [self createShaderWithFilePath:vertexPath type:GL_VERTEX_SHADER];
    checkCompileErrors(vertex, @"VERTEX");
    
    GLuint fragment = [self createShaderWithFilePath:fragmentPath type:GL_FRAGMENT_SHADER];
    checkCompileErrors(fragment, @"FRAGMENT");
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);
    checkCompileErrors(program, @"PROGRAM");
    
//    glDeleteShader(vertex);
//    glDeleteShader(fragment);
    
    shader.program = program;
    return shader;
}


- (void)use {
    glUseProgram(self.program);
}

- (GLuint)getAttribLocation:(NSString *)name {
    return glGetAttribLocation(self.program, [name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (GLuint)getUniformLocation:(NSString *)name {
    return glGetUniformLocation(self.program, [name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)setBOOL:(NSString *)name value:(BOOL)value {
    glUniform1i(glGetUniformLocation(self.program, [name cStringUsingEncoding:NSUTF8StringEncoding]), (int)value);
}

- (void)setInt:(NSString *)name value:(int)value {
    glUniform1i(glGetUniformLocation(self.program, [name cStringUsingEncoding:NSUTF8StringEncoding]), value);
}

- (void)setFloat:(NSString *)name value:(float)value {
    glUniform1i(glGetUniformLocation(self.program, [name cStringUsingEncoding:NSUTF8StringEncoding]), value);
}


+ (GLuint)createShaderWithFilePath:(NSString *)filePath type:(GLenum)shaderType {
    filePath = [[NSBundle mainBundle] pathForResource:filePath ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString || error) {
        NSLog(@"读取%@ 失败", shaderType == GL_VERTEX_SHADER ? @"vertex" : @"fragment");
    }
    
    GLuint shader = glCreateShader(shaderType);
    const char *shaderC = [shaderString UTF8String];
    int shaderStringLenght = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderC, &shaderStringLenght);
    glCompileShader(shader);
    return shader;
}

@end
