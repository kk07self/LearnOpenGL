//
//  CombineFilter.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/6/5.
//  Copyright © 2019 KK. All rights reserved.
//

#import "CombineFilter.h"
#import <GLKit/GLKit.h>
#import "GLSLShader.h"

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;


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


void checkCompileErrors_(GLuint shader, NSString* type) {
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
    GLuint _position;
    GLuint _inputTexture1Coordinate;
    GLuint _inputTexture2Coordinate;
    
    GLuint _inputTexture1Buffer;
    GLuint _inputTexture2Buffer;
    
    GLfloat *_positions;
    
    GLuint texture1;
    GLuint texture2;
    GLuint frameBuffer;
    
    UIImage *image1;
    UIImage *image2;
    
    GLSLShader *_shader;
}

@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组

@end

@implementation CombineFilter

- (instancetype)init {
    if (self = [super init]) {
        image1 = [UIImage imageNamed:@"sample_filter.jpg"];
        image2 = [UIImage imageNamed:@"hahah.jpg"];
    }
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    return self;
}

- (void)dealloc {
    _shader = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)draw {
    
    // 创建纹理
    if (texture1 == 0) {
        
        texture1 = [self createTextureWithImage:image1];
        texture2 = [self createTextureWithImage:image2];
    }
    NSLog(@"--------texture1: %d", texture1);
    NSLog(@"--------texture2: %d", texture2);
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 设置窗口
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    _shader = [GLSLShader shaderWithVertexPath:@"c_shader" fragmentPath:@"c_shader"];
    [_shader use];
    
    GLuint aPostion = [_shader getAttribLocation:@"position"];
    GLuint texCoord1 = [_shader getAttribLocation:@"inputTextureCoordinate"];
    GLuint inputTexture1  = [_shader getUniformLocation:@"inputImageTexture"];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glUniform1i(inputTexture1, 0);
    
    
    GLfloat vertices[] = {
        -1.0f, 1.0f,
        -1.0f, -1.0f,
        1.0f,  1.0f,
        1.0f,  -1.0f,
    };

//    GLfloat vertices[] = {
//        -1.0f, 1.0f, // 左上
//        -1.0f, 0.0f, // 左中
//        1.0f,  1.0f, // 右上
//        1.0f,  0.0f, // 右中
//        1.0f,  -1.0f, // 右下
//        -1.0f, -1.0f, // 左下
//    };
//    GLfloat textureCoordinates[] = {
//        0.0f, 1.0f, // 左上
//        0.0f, 0.0f, // 左下
//        1.0f, 1.0f, // 右上
//        1.0f, 0.0f, // 右下
//    };
    
    GLfloat textureCoordinates1[] = {
        0.0f, 1.0f, // 左上
        0.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };

    
    glEnableVertexAttribArray(aPostion);
    glVertexAttribPointer(aPostion, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(texCoord1);
    glVertexAttribPointer(texCoord1, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates1);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)initProgram {
    
    if (isInitProgram) {
        return;
    }

    _shader = [GLSLShader shaderWithVertexPath:@"c_shader" fragmentPath:@"c_shader"];
    _program = _shader.program;
    
    isInitProgram = YES;
}


- (GLuint)createTextureWithImage:(UIImage *)image {
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // effect
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    
    // 纹理环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // 纹理过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureInfo.name, 0);
    return textureInfo.name;
}
- (GLuint)createTexture:(UIImage *)image{
    
//    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
//                                                               options:options
//                                                                 error:NULL];
//    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
//
//    // 纹理环绕方式
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//    // 纹理过滤方式
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
////    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
//    return textureInfo.name;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData.bytes);
    
    return texture;
}

- (UIImage *)getImage {
//    glBindBuffer(GL_FRAMEBUFFER, frameBuffer);
//    int width = [UIScreen mainScreen].bounds.size.width;
//    int height = width;
//    int size = width * height * 4;
//    GLubyte *buffer = malloc(size);
//    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, size, NULL);
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    int bytesPerRow = 4 * width;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
//    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
//    return imageRef;
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    CGFloat width = [self drawableWidth];
    CGFloat height = [self drawableHeight];
    int size = width * height * 4;
    GLubyte *buffer = malloc(size);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, size, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // 此时的 imageRef 是上下颠倒的，调用 CG 的方法重新绘制一遍，刚好翻转过来
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    UIImage *imageN = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(buffer);
    return imageN;
}

// 获取渲染缓存宽度
- (GLint)drawableWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

// 获取渲染缓存高度
- (GLint)drawableHeight {
    return [UIScreen mainScreen].bounds.size.width*1.5;
}

@end
