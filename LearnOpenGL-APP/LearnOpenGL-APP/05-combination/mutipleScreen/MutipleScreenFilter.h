//
//  MutipleScreen.h
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 分屏样式
 
 - MutipleScreenFilterStyle1Screen: 单屏幕
 - MutipleScreenFilterStyle2ScreenVertical: 双屏幕上下
 - MutipleScreenFilterStyle2ScreenHorizontal: 双屏幕左右
 - MutipleScreenFilterStyle3ScreenVertical: 三屏幕上下
 - MutipleScreenFilterStyle3ScreenHorizontal: 三屏幕左右
 - MutipleScreenFilterStyle4Screen: 四屏幕
 - MutipleScreenFilterStyle6ScreenVertical: 六屏幕，三行两列
 - MutipleScreenFilterStyle6ScreenHorizontal: 六屏幕，两行三列
 - MutipleScreenFilterStyle9Screen: 九屏幕
 */
typedef NS_ENUM(NSInteger, MutipleScreenFilterStyle){
    MutipleScreenFilterStyle1Screen = 0,
    MutipleScreenFilterStyle2ScreenVertical,
    MutipleScreenFilterStyle2ScreenHorizontal,
    MutipleScreenFilterStyle3ScreenVertical,
    MutipleScreenFilterStyle3ScreenHorizontal,
    MutipleScreenFilterStyle4Screen,
    MutipleScreenFilterStyle6ScreenVertical,
    MutipleScreenFilterStyle6ScreenHorizontal,
    MutipleScreenFilterStyle9Screen,
};

@interface MutipleScreenFilter : NSObject

/**
 图像资源
 */
@property (nonatomic, strong) UIImage *image;

/**
 screentype
 */
@property (nonatomic, assign) MutipleScreenFilterStyle screenStyle;


- (void)progress;
- (UIImage *)getResultImage;

@end

NS_ASSUME_NONNULL_END
