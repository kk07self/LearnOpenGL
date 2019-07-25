//
//  SplitScreenFilter.m
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import "SplitScreenFilter.h"
#import <GLKit/GLKit.h>
#import "GLSLShader.h"

@interface SplitScreenFilter()
{
    GLSLShader *_shader;
    GLuint _position;
    GLuint _inputTextureCoordinate;
    GLuint _inputImageTexture;
    GLuint _inputScreenType;
    
    GLuint _texture;
    GLuint _frameBuffer;
    GLKTextureInfo *_textureInfo;
}
@end

@implementation SplitScreenFilter

- (instancetype)init {
    if (self = [super init]) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:context];
        _image = [UIImage imageNamed:@"sample_filter.jpg"];
    }
    return self;
}

- (void)dealloc {
    _shader = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)progress {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    [self initTexture];
    [self initShader];
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    [_shader use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(_inputImageTexture, 0);
    
    glUniform1i(_inputScreenType, _screenFilterStyle);
    
    GLfloat vertices[8] = {
        -1.0f, 1.0f,
        -1.0f, -1.0f,
        1.0f,  1.0f,
        1.0f,  -1.0f,
    };
    
    GLfloat textureCoordinates[8] = {
        0.0f, 1.0f, // 左上
        0.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };
    
    glEnableVertexAttribArray(_position);
    glVertexAttribPointer(_position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_inputTextureCoordinate);
    glVertexAttribPointer(_inputTextureCoordinate, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)initTexture {
    
    glDeleteTextures(1, &_texture);
    GLuint name = _textureInfo.name;
    glDeleteTextures(1, &name);
    
    glDeleteFramebuffers(1, &_frameBuffer);

    _texture = [self createTextureWithImage:self.image];
    [self createTextureWithImage:self.image];
}


- (void)initShader {
    if (_shader) {
        return;
    }
    
    _shader = [GLSLShader shaderWithVertexPath:@"s_shader" fragmentPath:@"s_shader"];
    
    _position = [_shader getAttribLocation:@"position"];
    _inputTextureCoordinate = [_shader getAttribLocation:@"inputTextureCoordinate"];
    _inputImageTexture  = [_shader getUniformLocation:@"inputImageTexture"];
    _inputScreenType  = [_shader getUniformLocation:@"screenType"];
}


- (GLuint)createTextureWithImage:(UIImage *)image {

    glDeleteFramebuffers(1, &_frameBuffer);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // effect
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES), GLKTextureLoaderApplyPremultiplication: @(YES)};
    _textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                options:options
                                                  error:NULL];
    glBindTexture(GL_TEXTURE_2D, _textureInfo.name);

    // 纹理环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // 纹理过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureInfo.name, 0);
    return _textureInfo.name;
}


- (UIImage *)getResultImage {
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
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

#pragma mark - setter getter
- (void)setScreenFilterStyle:(ScreenFilterStyle)screenFilterStyle {
    _screenFilterStyle = screenFilterStyle;
}

// 设置图像
- (void)setImage:(UIImage *)image {
    _image = image;
    _texture = 0;
    _textureInfo = nil;
    [self initTexture];
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
