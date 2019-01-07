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
@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glView;

// GL上下文
@property (nonatomic, strong) EAGLContext *mContext;

// 相当于OpenGL中的shader    着色器
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingConfig];
    
    [self settingVertexArr];
    
    [self settingTexture];
}

// 初始化上下文
- (void)settingConfig
{
    // EAGLRenderingAPI : api
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *glView = [[GLKView alloc] initWithFrame:self.view.bounds];
    _glView = glView;
    glView.delegate = self;
    glView.context = self.mContext;
    //颜色缓冲区格式
    glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [self.view addSubview:glView];
    [EAGLContext setCurrentContext:self.mContext];
}

// 缓存顶点
- (void)settingVertexArr
{
    // 顶点数据，前三个是顶点坐标（x,y,z），后两个是纹理坐标（x,y）
    GLfloat vertexData[] = {
        0.5, -0.5, 0.0f,   1.0f, 0.0f, // 右下
        0.5, 0.5, 0.0f,     1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, // 左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, // 左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    //1、顶点缓冲对象(Vertex Buffer Objects, VBO), 用这个指针管理顶点数据，一次发送大量的数据到显卡（GPU），而不是一个一个的发送。当数据发送到显卡存储后，着色器能立即访问这些顶点
    GLuint VBO;
    //2、使用glGenBuffers和一个缓冲id生成一个顶点缓冲对象
    glGenBuffers(1, &VBO);
    //3、绑定缓冲 (OpenGL有很多缓冲对象类型，顶点缓冲对象类型是GL_ARRAY_BUFFER)  使用glBindBuffer函数把新创建的缓冲对象绑定到GL_ARRAY_BUFFER的目标上
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //4、使用glBufferData 把上边设置的顶点数据vertexData放到顶点缓冲对象中，把顶点数据从cpu内存复制到gpu内存
    /*
     glBufferData把用户定义的数据复制到当前绑定的顶点缓冲对象的函数。
     第一个参数是目标缓冲类型：上面我们把顶点缓冲对象绑定到GL_ARRAY_BUFFER目标上；
     第二个参数指定传输数据的大小，以字节为单位；
     第三个参数是我们要绑定的数据；
     第四个参数指定显卡如何管理给定的数据（GL_STATIC_DRAW ：数据不会或几乎不会改变。GL_DYNAMIC_DRAW：数据会被改变很多。GL_STREAM_DRAW ：数据每次绘制时都会改变。对于缓冲中的数据频繁被改变时，选择后两种类型，保证显卡把数据放在能够高速写入的内存部分）
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    /*--------------上面我们把顶点数据保存到显卡内存中，用顶点缓冲对象管理；接下来创建一个顶点和片段着色器真正处理这些数据---------------*/
    
    //5、开启对应顶点属性，才可在顶点着色器中访问逐顶点的属性数据，允许顶点着色器读取GPU（服务器端）数据。
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //6、设置合适的格式从buffer读取数据，glVertexAttribPointer函数是建立CPU和GPU之间的逻辑连接，实现CPU的数据上传到GPU
    /*
     第一个参数index  ， Attribute的索引
     第二个参数size, Attribute 变量数据是由几个元素组成的， x,y,z,w ; 最多四个。
     第三个参数type 指定数组中每个组件的数据类型
     第四个参数normalized, 固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）， 编程1.0以内的数，这样做的目的是减少向gpu传递数据的带宽。
     第五个参数stride,  元素间隔,， 通常是0
     第六个参数pointer 指定第一个组件在数组的第一个顶点属性中的偏移量。该数组与GL_ARRAY_BUFFER绑定，储存于缓冲区中。初始值为0；
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    // 开启缓存
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

// Texture
- (void)settingTexture
{
    // 纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gl_test" ofType:@"png"];
    //GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@(1)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 着色器
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = textureInfo.name;
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 启动着色器
    [self.baseEffect prepareToDraw];
    // glGraeArrays应该是绘制顶点数组，指定绘制的类型，和数组的range
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
@end
