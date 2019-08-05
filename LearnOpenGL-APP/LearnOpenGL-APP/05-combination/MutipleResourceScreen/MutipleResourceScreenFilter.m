//
//  MutipleResourceScreen.m
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import "MutipleResourceScreenFilter.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
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
    
    GLuint _textures[9];
    CGFloat _ys[9];
    CGFloat _xs[9];
    GLfloat _vertices[9][8];
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
    [self configVertices];
    NSInteger drawCount = [self getDrawCount];
    
    for (int i = 0; i < drawCount; i++) {
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        glUniform1i(_inputImageTexture, 0);
        
        // 一图
        static GLfloat textureCoordinates0[8] = {
            0.0, 1.0f, // 左上
            0.0, 0.0f, // 左下
            1.0, 1.0f, // 右上
            1.0f, 0.0f, // 右下
        };
        textureCoordinates0[3] = _ys[i];
        textureCoordinates0[7] = _ys[i];
        textureCoordinates0[1] = 1.0 - _ys[i];
        textureCoordinates0[5] = 1.0 - _ys[i];
        
        textureCoordinates0[0] = _xs[i];
        textureCoordinates0[2] = _xs[i];
        textureCoordinates0[4] = 1.0 - _xs[i];
        textureCoordinates0[6] = 1.0 - _xs[i];
        
//        GLfloat *vertices_ = _vertices[i];
        for (int j = 0;  j < 8; j++) {
            vertices[j] = _vertices[i][j];
        }
        glEnableVertexAttribArray(_position);
        glVertexAttribPointer(_position, 2, GL_FLOAT, GL_FALSE, 0, vertices);
        glEnableVertexAttribArray(_inputTextureCoordinate);
        glVertexAttribPointer(_inputTextureCoordinate, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates0);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    }
}


- (void)initTexture {
    glDeleteTextures(1, &_texture);
    
    glDeleteFramebuffers(1, &_frameBuffer);
    GLuint name = _textureInfo.name;
    glDeleteTextures(1, &name);
    
    for (int i = 0; i<9; i++) {
        glDeleteTextures(1, &_textures[i]);
    }
    
    NSInteger drawCount = [self getDrawCount];
    CGSize drawSize = [self getSimpleSize];
    
    for (int i = 0; i < drawCount; i++) {
        _textures[i] = [self createTextureWithImage:self.images[i]];
        
        // 计算
        UIImage *image = self.images[i];
        if (_isClip) {
            // 裁剪
            if (image.size.width/drawSize.width > image.size.height/drawSize.height) {
                // 宽度裁剪 x
                _ys[i] = 0.0;
                _xs[i] = (image.size.width - image.size.height * drawSize.width/drawSize.height)/image.size.width * 0.5;
            } else {
                // 高度裁剪 y
                _xs[i] = 0.0;
                _ys[i] = (image.size.height - image.size.width * drawSize.height/drawSize.width)/image.size.height * 0.5;
            }
        } else {
            // 不够填充黑色
            
            if (image.size.width/drawSize.width > image.size.height/drawSize.height) {
                // 宽度 》 高度  y 填充
                _xs[i] = 0.0;
                _ys[i] = -(image.size.width - image.size.height * drawSize.width/drawSize.height)/image.size.height * 0.5;
            } else {
                // 宽度 < 高度  x 填充
                _ys[i] = 0.0;
                _xs[i] = -(image.size.height - image.size.width * drawSize.height/drawSize.width)/image.size.width * 0.5;
            }
        }
    }
    [self createTextureWithImage:self.image];
}

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray arrayWithCapacity:9];
        [_images addObject:[UIImage imageNamed:@"sample.jpg"]];
        [_images addObject:[UIImage imageNamed:@"sample_filter.jpg"]];
        [_images addObject:[UIImage imageNamed:@"IMG_2538.JPG"]];
        [_images addObject:[UIImage imageNamed:@"hahah.jpg"]];
        [_images addObject:[UIImage imageNamed:@"sample.jpg"]];
        [_images addObject:[UIImage imageNamed:@"sample_filter.jpg"]];
        [_images addObject:[UIImage imageNamed:@"IMG_2538.JPG"]];
        [_images addObject:[UIImage imageNamed:@"hahah.jpg"]];
        [_images addObject:[UIImage imageNamed:@"sample_filter.jpg"]];
    }
    return _images;
}


- (NSInteger)getDrawCount {
    NSInteger count = 1;
    if (_screenStyle == 1 || _screenStyle == 2 ) {
        count = 2;
    } else if (_screenStyle == 3 || _screenStyle == 4) {
        count = 3;
    } else if (_screenStyle == 5) {
        count = 4;
    } else if (_screenStyle == 6 || _screenStyle == 7) {
        count = 6;
    } else if (_screenStyle == 8) {
        count = 9;
    }
    return count;
}

- (CGSize)getSimpleSize {
    CGFloat width = [self drawableWidth];
    CGFloat height = [self drawableHeight];
    if (_screenStyle == 1 || _screenStyle == 2 ) {
        width = _screenStyle == 1 ? width : width * 0.5;
        height = _screenStyle == 2 ? height : height * 0.5;
    } else if (_screenStyle == 3 || _screenStyle == 4) {
        width = _screenStyle == 3 ? width : width/3;
        height = _screenStyle == 4 ? height : height/3;
    } else if (_screenStyle == 5) {
        width = width * 0.5;
        height = height * 0.5;
    } else if (_screenStyle == 6 || _screenStyle == 7) {
        width = _screenStyle == 6 ? width/2 : width/3;
        height = _screenStyle == 7 ? height/2 : height/3;
    } else if (_screenStyle == 8) {
        width = width/3;
        height = height/3;
    }
    return CGSizeMake(width, height);
}

- (void)configVertices {
    if (_screenStyle == 0) {
        GLfloat vertices[8] = {
            -1.0f, 1.0f,
            -1.0f, -1.0f,
            1.0f,  1.0f,
            1.0f,  -1.0f,
        };
        for (int i = 0; i < 8; i++) {
            _vertices[0][i] = vertices[i];
        }
    }
    else if (_screenStyle == 1 || _screenStyle == 2) {
        GLfloat vertices[2][8] = {
            {
                -1.0f, 1.0f,
                -1.0f, -0.0f,
                1.0f,  1.0f,
                1.0f,  -0.0f,
            },
            {
                -1.0f, 0.0f, // 左中
                -1.0f, -1.0f,// 左下
                1.0f,  0.0f, // 右中
                1.0f,  -1.0f, // 右下
            }
        };
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 8; j ++) {
                _vertices[i][j] = vertices[i][j];
            }
        }
    } else if (_screenStyle == 3 || _screenStyle == 4) {
        GLfloat vertices[3][8] = {
            {
                -1.0f, 1.0f,
                -1.0f, 0.3333f,
                1.0f,  1.0f,
                1.0f,  0.3333f,
            },
            {
                -1.0f, 0.3333f, // 左中
                -1.0f, -0.3334f,// 左下
                1.0f,  0.3333f, // 右中
                1.0f,  -0.3334f, // 右下
            },{
                -1.0f, -0.3334f, // 左中
                -1.0f, -1.0f,// 左下
                1.0f,  -0.3334f, // 右中
                1.0f,  -1.0f, // 右下
            }
        };
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 8; j ++) {
                _vertices[i][j] = vertices[i][j];
            }
        }
    }
    else if (_screenStyle == 5) {
        GLfloat vertices[4][8] = {
            {
                -1.0f, 1.0f,
                -1.0f, 0.0f,
                0.0f,  1.0f,
                0.0f,  0.0f,
            },
            {
                0.0f, 1.0f, // 左中
                0.0f, 0.0f,// 左下
                1.0f,  1.0f, // 右中
                1.0f,  0.0f, // 右下
            },
            {
                -1.0f, -0.0f, // 左中
                -1.0f, -1.0f,// 左下
                0.0f,  -0.0f, // 右中
                0.0f,  -1.0f, // 右下
            },
            {
                0.0f, 0.0f, // 左中
                0.0f, -1.0f,// 左下
                1.0f,  0.0f, // 右中
                1.0f,  -1.0f, // 右下
            }
        };

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 8; j ++) {
                _vertices[i][j] = vertices[i][j];
            }
        }
    } else if (_screenStyle == 6 || _screenStyle == 7) {
        GLfloat vertices[6][8] = {
            {
                -1.0f, 1.0f,
                -1.0f, 0.3333f,
                0.0f,  1.0f,
                0.0f,  0.3333f,
            },
            {
                0.0f, 1.0f, // 左中
                0.0f, 0.3333f,// 左下
                1.0f,  1.0f, // 右中
                1.0f,  0.3333f, // 右下
            },
            {
                -1.0f, 0.3333f, // 左中
                -1.0f, -0.3334f,// 左下
                0.0f,  0.3333f, // 右中
                0.0f,  -0.3334f, // 右下
            },
            {
                0.0f, 0.3333f, // 左中
                0.0f, -0.3334f,// 左下
                1.0f,  0.3333f, // 右中
                1.0f,  -0.3334f, // 右下
            },
            {
                -1.0f, -0.3334f, // 左中
                -1.0f, -1.0f,// 左下
                0.0f,  -0.3334f, // 右中
                0.0f,  -1.0f, // 右下
            },
            {
                0.0f, -0.3334f, // 左中
                0.0f, -1.0f,// 左下
                1.0f,  -0.3334f, // 右中
                1.0f,  -1.0f, // 右下
            }
        };
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 8; j ++) {
                _vertices[i][j] = vertices[i][j];
            }
        }
    } else if (_screenStyle == 8) {
        GLfloat vertices[9][8] = {
            // 1
            {
                -1.0f, 1.0f,
                -1.0f, 0.3333f,
                -0.3333f,  1.0f,
                -0.3333f,  0.3333f,
            },
            
            // 2
            {
                -0.3333f, 1.0f, // 左中
                -0.3333f, 0.3333f,// 左下
                0.3334f,  1.0f, // 右中
                0.3334f,  0.3333f, // 右下
            },
            
            // 3
            {
                0.3334f, 1.0f, // 左中
                0.3334f, 0.3333f,// 左下
                1.0f,  1.0f, // 右中
                1.0f,  0.3333f, // 右下
            },
            
            // 4
            {
                -1.0f, 0.3333f,
                -1.0f, -0.3334f,
                -0.3333f,  0.3333f,
                -0.3333f,  -0.3334f,
            },
            
            // 5
            {
                -0.3333f, 0.3333f, // 左中
                -0.3333f, -0.3334f,// 左下
                0.3334f,  0.3333f, // 右中
                0.3334f,  -0.3334f, // 右下
            },
            
            // 6
            {
                0.3334f, 0.3333f, // 左中
                0.3334f, -0.3334f,// 左下
                1.0f,  0.3333f, // 右中
                1.0f,  -0.3334f, // 右下
            },
            
            // 7
            {
                -1.0f, -0.3334f,
                -1.0f, -1.0f,
                -0.3333f,  -0.3334f,
                -0.3333f,  -1.0f,
            },
            
            // 8
            {
                -0.3333f, -0.3334f, // 左中
                -0.3333f, -1.0f,// 左下
                0.3334f,  -0.3334f, // 右中
                0.3334f,  -1.0f, // 右下
            },
            
            // 9
            {
                0.3334f, -0.3334f, // 左中
                0.3334f, -1.0f,// 左下
                1.0f,  -0.3334f, // 右中
                1.0f,  -1.0f, // 右下
            }
        };
        
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 8; j ++) {
                _vertices[i][j] = vertices[i][j];
            }
        }
    }
}

- (void)initShader {
    if (_shader) {
        return;
    }
    
    _shader = [GLSLShader shaderWithVertexPath:@"ms_shader" fragmentPath:@"ms_shader"];
    
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
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, 0x812D);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, 0x812D);
    float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
    
    // 纹理过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureInfo.name, 0);
    NSLog(@"---------%d", _textureInfo.name);
    return _textureInfo.name;
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
    return [UIScreen mainScreen].bounds.size.width;
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
