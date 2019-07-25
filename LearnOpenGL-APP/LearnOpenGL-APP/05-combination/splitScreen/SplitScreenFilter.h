//
//  SplitScreenFilter.h
//  LearnOpenGL-APP
//
//  Created by kk on 2019/7/25.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 输入的资源是否处理

 - SplitScreenFilterResourceTypeOriginal: 保持源数据
 - SplitScreenFilterResourceTypeClip: 剪切（保留中间）
 */
typedef NS_ENUM(NSInteger, SplitScreenFilterResourceType){
    SplitScreenFilterResourceTypeOriginal = 0,
    SplitScreenFilterResourceTypeClip
};


/**
 分屏样式

 - SplitScreenFilterStyle1Screen: 单屏幕
 - SplitScreenFilterStyle2ScreenVertical: 双屏幕上下
 - SplitScreenFilterStyle2ScreenHorizontal: 双屏幕左右
 - SplitScreenFilterStyle3ScreenVertical: 三屏幕上下
 - SplitScreenFilterStyle3ScreenHorizontal: 三屏幕左右
 - SplitScreenFilterStyle3ScreenBlur: 三屏幕，中间正常，上下模糊
 - SplitScreenFilterStyle3ScreenBlackAndWhite: 三屏幕，中间正常，上下黑白
 - SplitScreenFilterStyle4Screen: 四屏幕
 - SplitScreenFilterStyle6ScreenVertical: 六屏幕，三行两列
 - SplitScreenFilterStyle6ScreenHorizontal: 六屏幕，两行三列
 - SplitScreenFilterStyle9Screen: 九屏幕
 */
typedef NS_ENUM(NSInteger, ScreenFilterStyle){
    ScreenFilterStyle1Screen = 0,
    ScreenFilterStyle2ScreenVertical,
    ScreenFilterStyle2ScreenHorizontal,
    ScreenFilterStyle3ScreenVertical,
    ScreenFilterStyle3ScreenHorizontal,
    ScreenFilterStyle3ScreenBlur,
    ScreenFilterStyle3ScreenBlackAndWhite,
    ScreenFilterStyle4Screen,
    ScreenFilterStyle6ScreenVertical,
    ScreenFilterStyle6ScreenHorizontal,
    ScreenFilterStyle9Screen,
};



/**
 分屏滤镜，单资源输入
 */
@interface SplitScreenFilter : NSObject

/**
 分屏样式
 */
@property (nonatomic, assign) ScreenFilterStyle screenFilterStyle;

/**
 图像资源
 */
@property (nonatomic, strong) UIImage *image;


- (void)progress;
- (UIImage *)getResultImage;

@end

NS_ASSUME_NONNULL_END
