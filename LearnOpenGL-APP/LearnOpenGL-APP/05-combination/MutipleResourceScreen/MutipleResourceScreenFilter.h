//
//  MutipleResourceScreen.h
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutipleScreenFilter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 分屏样式
 
 - MutipleResourceScreenFilterStyle1Screen: 单屏幕
 - MutipleResourceScreenFilterStyle2ScreenVertical: 双屏幕上下
 - MutipleResourceScreenFilterStyle2ScreenHorizontal: 双屏幕左右
 - MutipleResourceScreenFilterStyle3ScreenVertical: 三屏幕上下
 - MutipleResourceScreenFilterStyle3ScreenHorizontal: 三屏幕左右
 - MutipleResourceScreenFilterStyle4Screen: 四屏幕
 - MutipleResourceScreenFilterStyle6ScreenVertical: 六屏幕，三行两列
 - MutipleResourceScreenFilterStyle6ScreenHorizontal: 六屏幕，两行三列
 - MutipleResourceScreenFilterStyle9Screen: 九屏幕
 */
typedef NS_ENUM(NSInteger, MutipleResourceScreenFilterStyle){
    MutipleResourceScreenFilterStyle1Screen = 0,
    MutipleResourceScreenFilterStyle2ScreenVertical,
    MutipleResourceScreenFilterStyle2ScreenHorizontal,
    MutipleResourceScreenFilterStyle3ScreenVertical,
    MutipleResourceScreenFilterStyle3ScreenHorizontal,
    MutipleResourceScreenFilterStyle4Screen,
    MutipleResourceScreenFilterStyle6ScreenVertical,
    MutipleResourceScreenFilterStyle6ScreenHorizontal,
    MutipleResourceScreenFilterStyle9Screen,
};

@interface MutipleResourceScreenFilter : NSObject

/**
 图像资源
 */
@property (nonatomic, strong) UIImage *image;

/**
 images
 */
@property (nonatomic, strong) NSMutableArray *images;

/**
 剪切 scaleFit/fillFit
 */
@property (nonatomic, assign) BOOL isClip;

/**
 screentype
 */
@property (nonatomic, assign) MutipleResourceScreenFilterStyle screenStyle;


- (void)progress;
- (UIImage *)getResultImage;

@end

NS_ASSUME_NONNULL_END
