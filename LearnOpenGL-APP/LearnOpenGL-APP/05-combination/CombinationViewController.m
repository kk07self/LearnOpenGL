//
//  CombinationViewController.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/6/5.
//  Copyright © 2019 KK. All rights reserved.
//

#import "CombinationViewController.h"
#import "CombineFilter.h"

@interface CombinationViewController ()

/**
 layer
 */
@property (nonatomic, strong) CALayer *previewLayer;

@end

@implementation CombinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CombineFilter *com = [[CombineFilter alloc] init];
    [com draw];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[com getImage]];
    imageView.frame = CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*1.5);
    [self.view addSubview:imageView];
}


@end
