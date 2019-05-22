//
//  ViewController.m
//  LearnOpenGL-APP
//
//  Created by KK on 2019/5/20.
//  Copyright © 2019 KK. All rights reserved.
//

#import "TBViewController.h"

@interface TBViewController ()

/**
 数据
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *demos;

@end

@implementation TBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _demos = @[@{@"00-GLKit-加载纹理":@"GLKitViewController"},
               @{@"01-GLSL-加载纹理" :@"GLSLViewController"}];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TBViewControllerCellID"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TBViewControllerCellID"];
    NSDictionary *dict = _demos[indexPath.row];
    cell.textLabel.text = dict.allKeys.firstObject;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _demos[indexPath.row];
    [self performSegueWithIdentifier:dict.allValues.firstObject sender:nil];
}


@end
