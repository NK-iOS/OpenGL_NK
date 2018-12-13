//
//  ViewController.m
//  OpenGL_1
//
//  Created by 聂宽 on 2018/12/11.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic, strong) EAGLContext *mContext;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingConfig];
    
    unsigned int textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);
}

- (void)settingConfig
{
    // EAGLRenderingAPI : api
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *imgView = [[GLKView alloc] initWithFrame:CGRectMake(100, 100, screenW - 200, screenH - 200)];
    imgView.context = self.mContext;
    //颜色缓冲区格式
    imgView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:self.mContext];
    
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    GLfloat squareVertexData[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
}

@end
