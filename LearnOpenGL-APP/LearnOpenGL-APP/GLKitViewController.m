//
//  GLKitViewController.m
//  LearnOpenGL-APP
//
//  Created by KK on 2019/5/20.
//  Copyright © 2019 KK. All rights reserved.
//

#import "GLKitViewController.h"

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface GLKitViewController ()

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect *mEffect;
@property (nonatomic, assign) GLfloat *vertices;

@end

@implementation GLKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self uploadVertexArray];
    [self uploadTexture];
}

- (void)config {
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)uploadVertexArray {
    // 顶点数据数组
    // 顶点数据数组，包含纹理数据
    // 纹理是2维数据，范围是(0,0)左下-(1,1)右上
    GLfloat vertices[] = {
        
        // points             // texture coords
         1.0f,   1.0f, 0.0f,  1.0f, 1.0f,  // top right
         1.0f,  -1.0f, 0.0f,  1.0f, 0.0f,  // bottom right
        -1.0f,   1.0f, 0.0f,  0.0f, 1.0f,   // top left
        
        1.0f,  -1.0f, 0.0f,  1.0f, 0.0f,  // bottom right
        -1.0f,  -1.0f, 0.0f,  0.0f, 0.0f,  // bottom left
        -1.0f,   1.0f, 0.0f,  0.0f, 1.0f   // top left
    };

    
    self.vertices = vertices;
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    
    // 绑定顶点数组对象、绑定和设置顶点缓冲对象、再设置顶点解析
    // 复制顶点数组到缓冲中供OpenGL使用
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // 绘制顶点
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    // 以顶点位置0作为参数启用顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // 文理设置 从2开始, 偏移量是5
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void *)(3 * sizeof(float)));
    // 以顶点位置1作为参数启用顶点属性 --- 颜色
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
}

- (void)uploadTexture {
    // 通过 GLKTextureLoader 来加载纹理，并存放在 GLKBaseEffect 中
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sample.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath]; // 这里如果用 imageNamed 来读取图片，在反复加载纹理的时候，会出现倒置的错误
    
    
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)}; // 消除 UIKit 和 GLKit 的坐标差异，否则会上下颠倒
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清屏
    glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
