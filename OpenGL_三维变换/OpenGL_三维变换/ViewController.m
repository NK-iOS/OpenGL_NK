//
//  ViewController.m
//  OpenGL_三维变换
//
//  Created by 聂宽 on 2018/12/25.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()
@property (nonatomic, strong) GLView *glView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.glView = [[GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
