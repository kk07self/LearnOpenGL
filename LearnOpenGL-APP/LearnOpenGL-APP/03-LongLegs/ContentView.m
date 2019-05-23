//
//  ContentView.m
//  LearnOpenGL-APP
//
//  Created by KK on 2019/5/22.
//  Copyright © 2019 KK. All rights reserved.
//

#import "ContentView.h"
#import "GLSLShader.h"

/**
 定义顶点类型
 */
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;


static CGFloat const kDefaultOriginTextureHeight = 0.7f;  // 初始纹理高度占控件高度的比例
static NSInteger const kVertexCount = 8;  // 初始纹理高度占控件高度的比例

@interface ContentView()<GLKViewDelegate>

@property (nonatomic, strong) UIImage *originImage;

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, assign) CGSize currentImageSize;

@property (nonatomic, assign) CGFloat currentTextureWidth;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) SenceVertex *vertices;

// 临时创建的帧缓存和纹理缓存，重新绘制时会刷新，并用于创建新的图片
@property (nonatomic, assign) GLuint tmpFrameBuffer;
@property (nonatomic, assign) GLuint tmpTexture;

// 用于重新绘制纹理
@property (nonatomic, assign) CGFloat currentTextureStartY;
@property (nonatomic, assign) CGFloat currentTextureEndY;
@property (nonatomic, assign) CGFloat currentNewHeight;

@property (nonatomic, assign, readwrite) BOOL hasChange;

@end

@implementation ContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    self.delegate = self;
    
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * kVertexCount); // 8 个顶点
    
}


- (void)updateImage:(UIImage *)image {
    if (_originImage == nil) {
        _originImage = image;
    }
    _currentImage = image;
    
    // effect
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = textureInfo.name;
    
    self.currentImageSize = image.size;
    CGFloat ratio = (self.currentImageSize.height / self.currentImageSize.width) *
    (self.bounds.size.width / self.bounds.size.height);
    CGFloat textureHeight = MIN(ratio, kDefaultOriginTextureHeight);
    self.currentTextureWidth = textureHeight/ratio;
    
    [self calculateOriginTextureCoordWithTextureSize:self.currentImageSize startY:0 endY:0 newHeight:0];

    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * kVertexCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    self.hasChange = NO;
    
    // 调用绘制渲染
    [self display];
}

- (void)updateTexture {
    // 重置纹理及其绑定
    [self resetTextureWithOriginWidth:self.currentImageSize.width
                         originHeight:self.currentImageSize.height
                                 topY:self.currentTextureStartY
                              bottomY:self.currentTextureEndY
                            newHeight:self.currentNewHeight];
    
    // 解绑掉之前的texture
    if (self.baseEffect.texture2d0.name != 0) {
        GLuint name = self.baseEffect.texture2d0.name;
        glDeleteTextures(1, &name);
    }
    self.baseEffect.texture2d0.name = self.tmpTexture;
    
    self.currentImageSize = [self newImageSize];
    [self calculateOriginTextureCoordWithTextureSize:self.currentImageSize
                                              startY:0
                                                endY:0
                                           newHeight:0];
    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * kVertexCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    self.hasChange = NO;
    [self display];
}

- (void)resetTextureWithOriginWidth:(CGFloat)originWidth
                       originHeight:(CGFloat)originHeight
                               topY:(CGFloat)topY
                            bottomY:(CGFloat)bottomY
                          newHeight:(CGFloat)newHeight {
    
    // 新的纹理尺寸
    GLsizei newTextureWidth = originWidth;
    GLsizei newTextureHeight = originHeight * (newHeight - (bottomY - topY)) + originHeight;
    
    // 高度变化百分比
    CGFloat heightScale = newTextureHeight / originHeight;
    
    // 在新的纹理坐标下，重新计算topY、bottomY
    CGFloat newTopY = topY / heightScale;
    CGFloat newBottomY = (topY + newHeight) / heightScale;
    
    // 创建顶点数组
    SenceVertex *tmpVertices = malloc(sizeof(SenceVertex) * kVertexCount);
    tmpVertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上
    tmpVertices[1] = (SenceVertex){{1, 1, 0}, {1, 1}};  // 右上
    
    tmpVertices[2] = (SenceVertex){{-1, -2 * newTopY + 1, 0}, {0, 1 - topY}};
    tmpVertices[3] = (SenceVertex){{1, -2 * newTopY + 1, 0}, {1, 1 - topY}};
    tmpVertices[4] = (SenceVertex){{-1, -2 * newBottomY + 1, 0}, {0, 1 - bottomY}};
    tmpVertices[5] = (SenceVertex){{1, -2 * newBottomY + 1, 0}, {1, 1 - bottomY}};
    
    tmpVertices[6] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下
    tmpVertices[7] = (SenceVertex){{1, -1, 0}, {1, 0}};  // 右下
    
    
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
    
    glBindFramebuffer(GL_FRAMEBUFFER, 1);
    free(tmpVertices);
    
    self.tmpTexture = texture;
    self.tmpFrameBuffer = frameBuffer;
}



- (void)stretchingFromStartY:(CGFloat)startY toEndY:(CGFloat)endY withNewHeight:(CGFloat)newHeight {
    
    [self calculateOriginTextureCoordWithTextureSize:self.currentImageSize startY:startY endY:endY newHeight:newHeight];
    self.hasChange = YES;
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * kVertexCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    [self display];
}



/**
 计算新纹理坐标

 @param size 图片纹理大小
 @param startY 拉伸的开始位置
 @param endY 拉伸的结束位置
 @param newHeight 需要拉伸的高度
 */
- (void)calculateOriginTextureCoordWithTextureSize:(CGSize)size
                                            startY:(CGFloat)startY
                                              endY:(CGFloat)endY
                                         newHeight:(CGFloat)newHeight {
    
    CGFloat ratio = (size.height / size.width) *
    (self.bounds.size.width / self.bounds.size.height);
    CGFloat textureWidth = self.currentTextureWidth;
    CGFloat textureHeight = textureWidth * ratio;
    
    // 拉伸量
    CGFloat delta = (newHeight - (endY -  startY)) * textureHeight;
    
    // 判断是否超出最大值
    if (textureHeight + delta >= 1) {
        delta = 1 - textureHeight;
        newHeight = delta / textureHeight + (endY -  startY);
    }
    
    // 四个顶点
    GLKVector3 pointLT = {-textureWidth,  textureHeight + delta, 0}; // 左上
    GLKVector3 pointRT = { textureWidth,  textureHeight + delta, 0}; // 右上
    GLKVector3 pointLB = {-textureWidth, -textureHeight - delta, 0}; // 左下
    GLKVector3 pointRB = { textureWidth, -textureHeight - delta, 0}; // 右上
    
    // 中间四个点
    CGFloat startYCoord = MIN(-2 * textureHeight * startY + textureHeight, textureHeight);
    CGFloat endYCoord   = MAX(-2 * textureHeight * endY + textureHeight, -textureHeight);
    GLKVector3 centerPointLT = {-textureWidth, startYCoord + delta, 0};  // 左上角
    GLKVector3 centerPointRT = {textureWidth, startYCoord + delta, 0};  // 右上角
    GLKVector3 centerPointLB = {-textureWidth, endYCoord - delta, 0};  // 左下角
    GLKVector3 centerPointRB = {textureWidth, endYCoord - delta, 0};  // 右下角
    
    // 纹理的上面两个顶点
    self.vertices[0].positionCoord = pointLT;
    self.vertices[0].textureCoord = GLKVector2Make(0, 1);
    self.vertices[1].positionCoord = pointRT;
    self.vertices[1].textureCoord = GLKVector2Make(1, 1);
    // 中间区域的4个顶点
    self.vertices[2].positionCoord = centerPointLT;
    self.vertices[2].textureCoord = GLKVector2Make(0, 1 - startY);
    self.vertices[3].positionCoord = centerPointRT;
    self.vertices[3].textureCoord = GLKVector2Make(1, 1 - startY);
    self.vertices[4].positionCoord = centerPointLB;
    self.vertices[4].textureCoord = GLKVector2Make(0, 1 - endY);
    self.vertices[5].positionCoord = centerPointRB;
    self.vertices[5].textureCoord = GLKVector2Make(1, 1 - endY);
    // 纹理的下面两个顶点
    self.vertices[6].positionCoord = pointLB;
    self.vertices[6].textureCoord = GLKVector2Make(0, 0);
    self.vertices[7].positionCoord = pointRB;
    self.vertices[7].textureCoord = GLKVector2Make(1, 0);
    
    // 保存临时的，便于重置
    self.currentTextureStartY = startY;
    self.currentTextureEndY = endY;
    self.currentNewHeight = newHeight;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清屏
    glClearColor(46/255.0f, 47/255.0f, 67/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 渲染绘制
    [self.baseEffect prepareToDraw];
    
    // 顶点坐标和纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, kVertexCount);
}

- (UIImage *)getResultImage {
    [self resetTextureWithOriginWidth:self.currentImageSize.width originHeight:self.currentImageSize.height topY:self.currentTextureStartY bottomY:self.currentTextureEndY newHeight:self.currentNewHeight];
    glBindFramebuffer(GL_FRAMEBUFFER, self.tmpFrameBuffer);
    
    CGSize imageSize = [self newImageSize];
    UIImage *image = [self imageFromTextureWithWidth:imageSize.width height:imageSize.height];
    glBindFramebuffer(GL_FRAMEBUFFER, 1);
    return image;
}

// 返回某个纹理对应的 UIImage，调用前先绑定对应的帧缓存
- (UIImage *)imageFromTextureWithWidth:(int)width height:(int)height {
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
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(buffer);
    return image;
}

- (void)setTmpFrameBuffer:(GLuint)tmpFrameBuffer {
    if (!_tmpFrameBuffer) {
        glDeleteFramebuffers(1, &_tmpFrameBuffer);
    }
    _tmpFrameBuffer = tmpFrameBuffer;
}

- (CGSize)newImageSize {
    CGFloat newImageHeight = self.currentImageSize.height * ((self.currentNewHeight - (self.currentTextureEndY - self.currentTextureStartY)) + 1);
    return CGSizeMake(self.currentImageSize.width, newImageHeight);
}

- (CGFloat)textureTopY {
    return (1 - self.vertices[0].positionCoord.y) / 2;
}

- (CGFloat)textureBottomY {
    return (1 - self.vertices[7].positionCoord.y) / 2;
}

- (CGFloat)textureHeight {
    return self.textureBottomY - self.textureTopY;
}

@end
