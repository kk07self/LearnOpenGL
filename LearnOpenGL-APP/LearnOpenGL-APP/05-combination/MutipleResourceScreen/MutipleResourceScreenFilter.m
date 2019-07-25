//
//  MutipleResourceScreen.m
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import "MutipleResourceScreenFilter.h"
#import <GLKit/GLKit.h>
#import "GLSLShader.h"

@interface MutipleResourceScreenFilter()
{
    GLSLShader *_shader;
    GLuint _position;
    GLuint _inputTextureCoordinate;
    GLuint _inputImageTexture;
    
    GLuint _texture;
    GLuint _frameBuffer;
    GLKTextureInfo *_textureInfo;
}

@end

@implementation MutipleResourceScreenFilter

- (instancetype)init {
    if (self = [super init]) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:context];
        _image = [UIImage imageNamed:@"sample.jpg"];
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
    
    GLfloat vertices[8] = {
        -1.0f, 1.0f,
        -1.0f, -1.0f,
        1.0f,  1.0f,
        1.0f,  -1.0f,
    };
    
    // 一图
    static GLfloat textureCoordinates0[8] = {
        0.0f, 1.0f, // 左上
        0.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };

    glEnableVertexAttribArray(_position);
    glVertexAttribPointer(_position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_inputTextureCoordinate);
    glVertexAttribPointer(_inputTextureCoordinate, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)initTexture {
    glDeleteTextures(1, &_texture);
    
    glDeleteFramebuffers(1, &_frameBuffer);
    GLuint name = _textureInfo.name;
    glDeleteTextures(1, &name);
    
    _texture = [self createTextureWithImage:self.image];
    [self createTextureWithImage:self.image];
}


- (void)initShader {
    if (_shader) {
        return;
    }
    
    _shader = [GLSLShader shaderWithVertexPath:@"t_shader" fragmentPath:@"t_shader"];
    
    _position = [_shader getAttribLocation:@"position"];
    _inputTextureCoordinate = [_shader getAttribLocation:@"inputTextureCoordinate"];
    _inputImageTexture  = [_shader getUniformLocation:@"inputImageTexture"];
}


- (GLuint)createTextureWithImage:(UIImage *)image {
    
    // 创建纹理之前干掉之前的
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
    NSLog(@"---------%d", _textureInfo.name);
    return _textureInfo.name;
}

- (GLfloat *)textureCoordinates {
    // 一图
    static GLfloat textureCoordinates0[8] = {
        0.0f, 1.0f, // 左上
        0.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };
    // 2图 v
    static GLfloat textureCoordinates1[8] = {
        0.0f, 1.0f, // 左上
        0.0f, -1.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -1.0f, // 右下
    };
    
    // 2图 h
    static GLfloat textureCoordinates2[8] = {
        -1.0f, 1.0f, // 左上
        -1.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };
    
    //3图 v
    static GLfloat textureCoordinates3[8] = {
        0.0f, 1.0f, // 左上
        0.0f, -2.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -2.0f, // 右下
    };
    
    //3图 h
    static GLfloat textureCoordinates4[8] = {
        -2.0f, 1.0f, // 左上
        -2.0f, 0.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, 0.0f, // 右下
    };
    
    // 4图
    static GLfloat textureCoordinates5[8] = {
        -1.0f, 1.0f, // 左上
        -1.0f, -1.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -1.0f, // 右下
    };
    
    // 6图 水平3 竖直2
    static GLfloat textureCoordinates6[8] = {
        -2.0f, 1.0f, // 左上
        -2.0f, -1.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -1.0f, // 右下
    };
    
    // 6图 水平2 竖直3
    static GLfloat textureCoordinates7[8] = {
        -1.0f, 1.0f, // 左上
        -1.0f, -2.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -2.0f, // 右下
    };
    
    // 9图 水平3 竖直3
    static GLfloat textureCoordinates8[8] = {
        -2.0f, 1.0f, // 左上
        -2.0f, -2.0f, // 左下
        1.0f, 1.0f, // 右上
        1.0f, -2.0f, // 右下
    };
    
    switch (_screenStyle) {
        case 1:
            return textureCoordinates1;
            break;
        case 2:
            return textureCoordinates2;
            break;
        case 3:
            return textureCoordinates3;
            break;
        case 4:
            return textureCoordinates4;
            break;
        case 5:
            return textureCoordinates5;
            break;
        case 6:
            return textureCoordinates6;
            break;
        case 7:
            return textureCoordinates7;
            break;
        case 8:
            return textureCoordinates8;
            break;
        default:
            break;
    }
    
    return textureCoordinates0;
}


#pragma mark - setter getter

- (void)setScreenStyle:(MutipleResourceScreenFilterStyle)screenStyle {
    _screenStyle = screenStyle;
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

@end
