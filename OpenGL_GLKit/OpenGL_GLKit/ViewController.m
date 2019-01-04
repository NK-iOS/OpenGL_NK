//
//  ViewController.m
//  OpenGL_GLKit
//
//  Created by 聂宽 on 2019/1/3.
//  Copyright © 2019年 聂宽. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *mContext;

@property (nonatomic, strong) GLKBaseEffect *mEffect;

@property (nonatomic, assign) int mCount;
@property (nonatomic, assign) float mDegreeX;
@property (nonatomic, assign) float mDegreeY;
@property (nonatomic, assign) float mDegreeZ;

@property (nonatomic, assign) BOOL mBoolX;
@property (nonatomic, assign) BOOL mBoolY;
@property (nonatomic, assign) BOOL mBoolZ;
@end

@implementation ViewController
{
    dispatch_source_t timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    
    [self renderNew];
    
    [self settingUI];
}

- (void)settingUI{
    CGFloat leftMargin = 30;
    CGFloat btnW = 60;
    CGFloat btnMargin =([UIScreen mainScreen].bounds.size.width - leftMargin * 2 - btnW * 3) * 0.5;
    
    UIButton *xBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [xBtn setTitle:@"X" forState:UIControlStateNormal];
    xBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [xBtn addTarget:self action:@selector(xBtnClick) forControlEvents:UIControlEventTouchUpInside];
    xBtn.frame = CGRectMake(leftMargin, 30, btnW, 30);
    [self.view addSubview:xBtn];
    
    UIButton *yBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [yBtn setTitle:@"Y" forState:UIControlStateNormal];
    yBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [yBtn addTarget:self action:@selector(yBtnClick) forControlEvents:UIControlEventTouchUpInside];
    yBtn.frame = CGRectMake(CGRectGetMaxX(xBtn.frame) + btnMargin, 30, btnW, 30);
    [self.view addSubview:yBtn];
    
    UIButton *zBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [zBtn setTitle:@"Z" forState:UIControlStateNormal];
    zBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [zBtn addTarget:self action:@selector(zBtnClick) forControlEvents:UIControlEventTouchUpInside];
    zBtn.frame = CGRectMake(CGRectGetMaxX(yBtn.frame) + btnMargin, 30, btnW, 30);
    [self.view addSubview:zBtn];
    
}
- (void)xBtnClick
{
    self.mBoolX = !self.mBoolX;
}

- (void)yBtnClick
{
    self.mBoolY = !self.mBoolY;
}

- (void)zBtnClick
{
    self.mBoolZ = !self.mBoolZ;
}

- (void)renderNew
{
    // 顶点数据， 前三个顶点坐标， 中间三个顶点颜色， 后两个是纹理坐标
    GLfloat attrAttr[] =
    {
        -0.5, 0.5f, 0.0f,   0.0f, 0.0f, 0.5f,   0.0f, 1.0f, //左上
        0.5f, 0.5f, 0.0f,   0.0f, 0.5f, 0.0f,   1.0f, 1.0f, //右上
        -0.5f, -0.5f, 0.0f, 0.5f, 0.0f, 1.0f,   0.0f, 0.0f, // 左下
        0.5f, -0.5f, 0.0f,  0.0f, 0.0f, 0.5f,   1.0f, 0.0f, // 右下
        0.0f, 0.0f, 1.0f,   1.0f, 1.0f, 1.0f,   0.5f, 0.5f // 顶点
    };
    
    // 顶点索引 (四棱锥体)
    /*
     从上往下看，前两个三角形组成底面，后四个三角形分别是四个侧面
     0, 3, 2,
     0, 1, 3,
     0, 2, 4,
     0, 4, 1,
     2, 3, 4,
     1, 4, 3,
     */
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);
    // 顶点缓存对象
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrAttr), attrAttr, GL_STATIC_DRAW);
    
    // 顶点索引对象
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // 顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    // 顶点颜色
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    // 纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);
    
    // 纹理
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gl_test" ofType:@"png"];
    // GLKTextureLoaderOriginBottomLeft 参数是避免纹理上下颠倒，原因是纹理坐标系和世界坐标系的原点不同。
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    // 初始化投影
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width / size.height);
    // GLKMatrix4MakePerspective是透视投影变换
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 10.f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    // GLKMatrix4Translate是平移变换
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    // 定时器
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.mDegreeX += 0.1 * self.mBoolX;
        self.mDegreeY += 0.1 * self.mBoolY;
        self.mDegreeZ += 0.1 * self.mBoolZ;
    });
    dispatch_resume(timer);
}

// 场景数据变化
- (void)update{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
}

#pragma mark - GLKViewDelegate
// 场景渲染
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.mEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}

@end
