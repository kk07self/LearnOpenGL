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
    _previewLayer = [[CALayer alloc] init];
    _previewLayer.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width);
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    CombineFilter *com = [[CombineFilter alloc] init];
    [com draw];
    _previewLayer.contents = (__bridge id _Nullable)([com getImage]);
}




@end
