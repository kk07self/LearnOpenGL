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
    GLuint _position;
    GLuint _inputTexture1Coordinate;
    GLuint _inputTexture2Coordinate;
    
    GLuint _inputTexture1Buffer;
    GLuint _inputTexture2Buffer;
    
    GLfloat *_positions;
    
    GLuint texture1;
    GLuint texture2;
    GLuint outFrameBuffer;
    
    UIImage *image1;
    UIImage *image2;
}

@end

@implementation CombineFilter

- (instancetype)init {
    if (self = [super init]) {
        image1 = [UIImage imageNamed:@"sample_filter.jpg"];
        image2 = [UIImage imageNamed:@"hahah.jpg"];
        [self initProgram];
        [self createTextures];
    }
    return self;
}

- (void)draw {
    glViewport(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    glUseProgram(_program);
    
    // 清屏
    glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 绘制纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glUniform1i(_inputTexture1Buffer, 0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    glUniform1i(_inputTexture2Buffer, 1);
    
    GLfloat positions[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f
    };
    
    GLfloat firstTexCoods[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f
    };
    
    GLfloat secondTexCoods[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f
    };
    glVertexAttribPointer(_position, 2, GL_FLOAT, 0, 0, positions);
    glVertexAttribPointer(_inputTexture1Coordinate, 2, GL_FLOAT, 0, 0, firstTexCoods);
    glVertexAttribPointer(_inputTexture2Coordinate, 2, GL_FLOAT, 0, 0, secondTexCoods);
    
    glDrawArrays(GL_TRIANGLES, 0, 4);
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
    
    _position = glGetAttribLocation(program, "position");
    _inputTexture1Coordinate = glGetAttribLocation(program, "inputTextureCoordinate");
    _inputTexture2Coordinate = glGetAttribLocation(program, "inputTexture2Coordinate");
    
    _inputTexture1Buffer = glGetUniformLocation(program, "inputImageTexture");
    _inputTexture2Buffer = glGetUniformLocation(program, "inputImageTexture2");
    
    isInitProgram = YES;
}

- (void)createTextures {
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    texture1 = [self createTexture:image1];
    texture2 = [self createTexture:image2];
    
    outFrameBuffer = frameBuffer;
}

- (GLuint)createTexture:(UIImage *)image {
    
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

- (CGImageRef)getImage {
    glBindBuffer(GL_FRAMEBUFFER, outFrameBuffer);
    int width = [UIScreen mainScreen].bounds.size.width;
    int height = width;
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
    return imageRef;
}

//- (CVPixelBufferRef)imageToRGBPixelBuffer:(UIImage *)image {
//    CGSize frameSize = CGSizeMake(CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage));
//    NSDictionary *options =
//    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,[NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    CVReturn status =
//    CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width, frameSize.height,8, CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage)), image.CGImage);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    return pxbuffer;
//}

@end
