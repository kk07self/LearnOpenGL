//
//  FilterShaderBar.h
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/24.
//  Copyright © 2019 KK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FilterShaderBar;

@protocol FilterShaderBarDelegate <NSObject>

@optional
- (void)filterShaderBar:(FilterShaderBar *)filterShaderBar selected:(NSInteger)index;

@end


@interface FilterShaderBar : UIView

/**
 models
 */
@property (nonatomic, strong) NSArray<NSString *> *models;

/**
 delegate
 */
@property (nonatomic, weak) id<FilterShaderBarDelegate> delegate;

@end


@interface FilterShaderBarCell : UICollectionViewCell

/**
 text
 */
@property (nonatomic, strong) NSString *text;

/**
 selected
 */
@property (nonatomic, assign) BOOL isSelected;


@end

NS_ASSUME_NONNULL_END
