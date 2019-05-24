//
//  FilterViewController.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/24.
//  Copyright © 2019 KK. All rights reserved.
//

#import "FilterViewController.h"
#import <GLKit/GLKit.h>
#import "GLSLShader.h"
#import "FilterShaderBar.h"

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;


@interface FilterViewController ()<FilterShaderBarDelegate>

/** mContext */
@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组

@property (weak, nonatomic) IBOutlet FilterShaderBar *filterShaderBar;

/** 开始时间 */
@property (nonatomic, assign) double startTime;

/**
 定时器
 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/**
 shader
 */
@property (nonatomic, strong) GLSLShader *shader;

/**
 textureID
 */
@property (nonatomic, assign) GLuint textureID;

/**
 current
 */
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
}


- (void)commonInit {
    
    self.filterShaderBar.delegate = self;
    [self.filterShaderBar setModels:@[@"默认",@"缩放",@"灵魂出窍",@"抖动",@"闪白",@"毛刺",@"幻觉"]];
    
    [self createLayer];
    [self uploadShader];
}



#pragma mark - texture
- (void)createLayer {
    [self mContext];
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width);
    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
    
    
    // binder layer
    GLuint renderBuffer, frameBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}

- (void)uploadVertexArray {
    self.vertices = malloc(sizeof(SenceVertex)*4);
    self.vertices[0] = (SenceVertex){{-1,  1, 0}, {0, 1}}; // 左上
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下
    self.vertices[2] = (SenceVertex){{ 1,  1, 0}, {1, 1}}; // 右上
    self.vertices[3] = (SenceVertex){{ 1, -1, 0}, {1, 0}}; // 右下
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex)*4, self.vertices, GL_STATIC_DRAW);
}


- (void)uploadShader {
    // 创建纹理
    UIImage *image = [UIImage imageNamed:@"sample_filter.jpg"];
    _textureID = [self createTextureWithImage:image];
    
    // 设置窗口
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    NSString *fileName = [self fileNameWith:(_currentIndex)];
    _shader = [GLSLShader shaderWithVertexPath:fileName fragmentPath:fileName];
    [_shader use];
    
    GLuint aPostion = [_shader getAttribLocation:@"aPos"];
    GLuint texCoord = [_shader getAttribLocation:@"aTexCoord"];
    GLuint texture  = [_shader getUniformLocation:@"texture1"];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureID);
    glUniform1i(texture, 0);
    
    [self uploadVertexArray];
    
    glEnableVertexAttribArray(aPostion);
    glVertexAttribPointer(aPostion, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
    
    if (_currentIndex != 0) {
        [self startDisplaylink];
    }
}


- (void)filterAction {
    
    if (self.startTime == 0.0) {
        self.startTime = self.displayLink.timestamp;
    }
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_shader use];
    
    // 传入时间
    GLuint time  = [_shader getUniformLocation:@"Time"];
    CGFloat currentTime = self.displayLink.timestamp - self.startTime;
    glUniform1f(time, currentTime);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}



#pragma mark - displaylink
- (void)startDisplaylink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(filterAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)cancelDisplaylink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}


#pragma mark - FilterShaderBarDelegate
- (void)filterShaderBar:(FilterShaderBar *)filterShaderBar selected:(NSInteger)index {
    if (_currentIndex == index) {
        return;
    }
    _currentIndex = index;
    [self cancelDisplaylink];
    [self uploadShader];
}


#pragma mark - tools

- (GLuint)createTextureWithImage:(UIImage *)image {
    CGImageRef cgImageRef = [image CGImage];
    GLuint width  = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 生成纹理
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    // 设置纹理样式
    // 纹理环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // 纹理过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height,0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(context);
    free(imageData);
    return textureID;
}




#pragma mark - getter setter

- (NSString *)fileNameWith:(NSInteger)index {
    switch (index) {
        case 0:
            return @"normal";
            break;
        case 1:
            return @"scale";
            break;
        case 2:
            return @"soulOut";
            break;
        case 3:
            return @"shake";
            break;
        case 4:
            return @"flashWhite";
            break;
        case 5:
            return @"glitch";
            break;
        case 6:
            return @"illusion";
            break;
        default:
            break;
    }
    return @"normal";
}


// 获取渲染缓存宽度
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}

// 获取渲染缓存高度
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

- (EAGLContext *)mContext {
    if (!_mContext) {
        _mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:_mContext];
    }
    return _mContext;
}


@end
