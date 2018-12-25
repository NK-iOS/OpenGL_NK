//
//  GLView.m
//  OpenGL_三维变换
//
//  Created by 聂宽 on 2018/12/25.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "GLView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESUtils.h"
#import "GLESMath.h"

@interface GLView()
@property (nonatomic, strong) EAGLContext *myContext;
@property (nonatomic, strong) CAEAGLLayer *myEagLayer;

@property (nonatomic, assign) GLuint myProgram;
@property (nonatomic, assign) GLuint myVertices;

@property (nonatomic, assign) GLuint myColorRenderBuffer;
@property (nonatomic, assign) GLuint myColorFrameBuffer;
@end

@implementation GLView
{
    float degree;
    float yDegree;
    BOOL bX;
    BOOL bY;
    NSTimer *myTimer;
}

- (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    [self setupLayer];
}

- (void)setupLayer{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    
    // CALayer 默认是透明的，必须将它设置为不透明才能让其可见
    self.myEagLayer.opaque = YES;
    
    // 设置描述属性，在这里设置不维持渲染内容以及颜色格式为RGBA8
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyRetainedBacking,
                                          kEAGLColorFormatRGBA8,
                                          kEAGLDrawablePropertyColorFormat, nil]
}
@end
