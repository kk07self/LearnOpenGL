//
//  UIViewController+Statistics.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/28.
//  Copyright © 2019 KK. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+Statistics.h"

@implementation UIViewController (Statistics)


+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL origilaSEL = @selector(viewDidLoad);
        
        SEL hook_SEL = @selector(tusdk_viewDidLoad);
        
        //交换方法
        Method origilalMethod = class_getInstanceMethod(self, origilaSEL);
        
        
        Method hook_method = class_getInstanceMethod(self, hook_SEL);
        
        
        class_addMethod(self,
                        origilaSEL,
                        class_getMethodImplementation(self, origilaSEL),
                        method_getTypeEncoding(origilalMethod));
        
        class_addMethod(self,
                        hook_SEL,
                        class_getMethodImplementation(self, hook_SEL),
                        method_getTypeEncoding(hook_method));
        
        method_exchangeImplementations(class_getInstanceMethod(self, origilaSEL), class_getInstanceMethod(self, hook_SEL));
        
    });
    
}

- (void)tusdk_viewDidLoad {
    // 统计
    NSLog(@"hahahahaha---%@",self);
    
    [self tusdk_viewDidLoad];
}

@end
