//
//  ViewController.m
//  OpenGL_Shader
//
//  Created by 聂宽 on 2018/12/15.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLView *view = [[GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}

@end
