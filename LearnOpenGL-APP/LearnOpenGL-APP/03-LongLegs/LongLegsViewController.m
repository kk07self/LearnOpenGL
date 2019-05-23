//
//  LongLegsViewController.m
//  LearnOpenGL-APP
//
//  Created by KK on 2019/5/22.
//  Copyright © 2019 KK. All rights reserved.
//

#import "LongLegsViewController.h"
#import "ContentView.h"

@interface LongLegsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *top;
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomC;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, assign) CGFloat currentTop;  // 上方横线距离纹理顶部的高度
@property (nonatomic, assign) CGFloat currentBottom;    // 下方横线距离纹理顶部的高度

@end

@implementation LongLegsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取图片
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"girl.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [self.contentView updateImage:image];
    
    self.bottom.layer.cornerRadius = 25;
    self.bottom.layer.masksToBounds = true;
    self.top.layer.cornerRadius = 25;
    self.top.layer.masksToBounds = true;
    
    [self.top addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanTop:)]];
    
    [self.bottom addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionPanBottom:)]];
    
    self.currentTop = 0.25f;
    self.currentBottom = 0.75f;
    CGFloat textureOriginHeight = 0.7f; // 初始纹理占 View 的比例
    self.topC.constant = ((self.currentTop * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.contentView.bounds.size.height;
    self.bottomC.constant = ((self.currentBottom * textureOriginHeight) + (1 - textureOriginHeight) / 2) * self.contentView.bounds.size.height;
}


- (void)actionPanTop:(UIPanGestureRecognizer *)pan {
    if (self.contentView.hasChange) {
        [self.contentView updateTexture];
        self.slider.value = 0.5;
    }
    
    CGPoint translation = [pan translationInView:self.view];
    CGFloat topC = MIN(self.topC.constant + translation.y,
                             self.bottomC.constant);
    CGFloat textureTop = self.contentView.bounds.size.height * [self.contentView textureTopY];
    self.topC.constant = MAX(topC, textureTop);
    
    [pan setTranslation:CGPointZero inView:self.view];
    
//    CGPoint texturePoint = [self.view convertPoint:self.top.center toView:<#(nullable UIView *)#>];
    self.currentTop = (self.topC.constant/self.contentView.bounds.size.height - [self.contentView textureTopY])/self.contentView.textureHeight;
    NSLog(@"------------++%f",self.currentTop);
}

- (void)actionPanBottom:(UIPanGestureRecognizer *)pan {
    if (self.contentView.hasChange) {
        [self.contentView updateTexture];
        self.slider.value = 0.5;
    }
    
    CGPoint translation = [pan translationInView:self.view];
    CGFloat bottomC = MAX(self.bottomC.constant + translation.y,
                       self.topC.constant);
    CGFloat textureBottom = self.contentView.bounds.size.height * [self.contentView textureBottomY];
    self.bottomC.constant = MIN(bottomC, textureBottom);
    [pan setTranslation:CGPointZero inView:self.view];
    //    CGPoint texturePoint = [self.view convertPoint:self.top.center toView:<#(nullable UIView *)#>];
    self.currentBottom = (self.bottomC.constant/self.contentView.bounds.size.height - [self.contentView textureTopY])/self.contentView.textureHeight;
    NSLog(@"------------++%f",self.currentBottom);
}


- (IBAction)sliderValueChanged:(UISlider *)sender {
    CGFloat newHeight = (self.currentBottom - self.currentTop)*(sender.value + 0.5);
    [self.contentView stretchingFromStartY:self.currentTop toEndY:self.currentBottom withNewHeight:newHeight];
}


@end
