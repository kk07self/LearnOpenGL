//
//  ContentView.h
//  LearnOpenGL-APP
//
//  Created by KK on 2019/5/22.
//  Copyright © 2019 KK. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentView : GLKView

@property (nonatomic, assign, readonly) BOOL hasChange; // 拉伸区域是否被拉伸

- (void)updateImage:(UIImage *)image;

- (void)updateTexture;

/**
 拉伸

 @param startY 拉伸的起始位置
 @param endY 拉伸结束位置
 @param newHeight 拉伸后的高度
 */
- (void)stretchingFromStartY:(CGFloat)startY
                      toEndY:(CGFloat)endY
               withNewHeight:(CGFloat)newHeight;


/**
 纹理顶部的纵坐标 0～1
 
 @return 纹理顶部的纵坐标（相对于 View）
 */
- (CGFloat)textureTopY;

/**
 纹理底部的纵坐标 0～1
 
 @return 纹理底部的纵坐标（相对于 View）
 */
- (CGFloat)textureBottomY;

/**
 纹理高度 0～1
 
 @return 纹理高度（相对于 View）
 */
- (CGFloat)textureHeight;


- (UIImage *)getResultImage;

@end

NS_ASSUME_NONNULL_END
