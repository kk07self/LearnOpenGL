//
//  GLSLShader.h
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/21.
//  Copyright © 2019 KK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLSLShader : NSObject

+ (instancetype)shaderWithVertexPath:(NSString *)vertexPath fragmentPath:(NSString *)fragmentPath;

/**
 programID
 */
@property (nonatomic, assign) GLuint program;


- (void)use;

- (GLuint)getAttribLocation:(NSString *)name;

- (GLuint)getUniformLocation:(NSString *)name;

- (void)setBOOL:(NSString *)name value:(BOOL)value;

- (void)setInt:(NSString *)name value:(int)value;

- (void)setFloat:(NSString *)name value:(float)value;

@end

NS_ASSUME_NONNULL_END
