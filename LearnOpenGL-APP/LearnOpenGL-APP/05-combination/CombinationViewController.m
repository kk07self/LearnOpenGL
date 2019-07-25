//
//  CombinationViewController.m
//  LearnOpenGL-APP
//
//  Created by kk on 2019/6/5.
//  Copyright © 2019 TUTU. All rights reserved.
//

#import "CombinationViewController.h"
#import "CombineFilter.h"
#import "SplitScreenFilter.h"
#import "MutipleScreenFilter.h"

@interface CombinationViewController ()

/**
 imageView
 */
@property (nonatomic, strong) UIImageView *imageView;
/**
 splict
 */
@property (nonatomic, strong) SplitScreenFilter *split;

/**
 mutilplescreen
 */
@property (nonatomic, strong) MutipleScreenFilter *mutilplescreen;
@end

@implementation CombinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*1.5);
    [self.view addSubview:_imageView];
    
    _mutilplescreen = [[MutipleScreenFilter alloc] init];
    _mutilplescreen.screenStyle = 8;
    [_mutilplescreen progress];
    _imageView.image = [_mutilplescreen getResultImage];
    
//    _split = [[SplitScreenFilter alloc] init];
//    _split.screenFilterStyle = 1;
//    [_split progress];
//    _imageView.image = [_split getResultImage];
    
//    CombineFilter *com = [[CombineFilter alloc] init];
//    [com draw];
//    _imageView.image = [com getImage];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    _split.screenFilterStyle += 1;
//    if (_split.screenFilterStyle == 11) {
//        _split.screenFilterStyle = 0;
//    }
//    [_split progress];
//    _imageView.image = [_split getResultImage];
    
    _mutilplescreen.screenStyle += 1;
    if (_mutilplescreen.screenStyle == 9) {
        _mutilplescreen.screenStyle = 0;
    }
    [_mutilplescreen progress];
    _imageView.image = [_mutilplescreen getResultImage];

}


@end
