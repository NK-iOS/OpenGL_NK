//
//  GLView.m
//  OpenGL_Shader
//
//  Created by 聂宽 on 2018/12/16.
//  Copyright © 2018年 聂宽. All rights reserved.
// 1、忘记设置context    2、设置描绘属性    3、glVertexAttribPointer 纹理坐标偏移量设置错误

#import "GLView.h"
#import <OpenGLES/ES2/gl.h>

@interface GLView()
// 上下文
@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) CAEAGLLayer *mEaglLayer;
@property (nonatomic, assign) GLuint myProgram;
@property (nonatomic, assign) GLuint mColorRenderBuffer;
@property (nonatomic, assign) GLuint mColorFrameBuffer;

@end

@implementation GLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [self setupLayer];
    
    [self setupContext];
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self render];
}

- (void)setupLayer
{
    self.mEaglLayer = (CAEAGLLayer *)self.layer;
    
    // 设置放大倍数
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];

    // CALayer默认是透明的，必须将它设为不透明才能让其可见
    self.mEaglLayer.opaque = YES;
    
    // 设置描绘属性，设置不维持渲染内容以及颜色格式为 RGBA8
    self.mEaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    // 指定OpenGL渲染API版本
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"------- failed init context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"-------- faild set current context");
        exit(1);
    }
    self.mContext = context;
}

- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_mColorFrameBuffer);
    self.mColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_mColorRenderBuffer);
    self.mColorRenderBuffer = 0;
}

- (void)setupRenderBuffer
{
    // 生成顶点缓冲对象
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.mColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.mColorRenderBuffer);
    
    // 为颜色缓冲区 分配存储空间
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEaglLayer];
}

- (void)setupFrameBuffer
{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.mColorFrameBuffer = buffer;
    // 设置当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.mColorFrameBuffer);
    
    // 将 colorRenderBuffer 装配到GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mColorRenderBuffer);
}

// 渲染
- (void)render{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 设置窗口大小
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    // 读取文件路径
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    // 加载shader
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    // 链接
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        // 链接错误
        GLchar message[256];
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, &message[0]);
        NSString *messageStr = [NSString stringWithUTF8String:message];
        NSLog(@"-------message: %@", messageStr);
        return;
    }else
    {
        NSLog(@"------link ok");
        // 链接成功 使用
        glUseProgram(self.myProgram);
    }
    
    // 顶点数据   前三个（x,y,z）顶点坐标，后两个（x,y）纹理坐标
    GLfloat attrArr_s[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f
    };
    GLfloat attrArr[] = {
        0.5, -0.5, 0.0f,   1.0f, 0.0f, // 右下
        0.5, 0.5, 0.0f,     1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, // 左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, // 左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    // 加载纹理
    [self setupTexture:@"gl_test"];
    
    // 获取shader里边的变量， 在glLinkProgram成功后面
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    
    float radians = 10 * 3.14159f / 180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    // z轴旋转矩阵
    GLfloat zRotation[16] = {
        c, -s, 0, 0.2,
        s, c, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
    
    // 设置选择矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

/*
 c语言编译流程：预编译，编译，汇编，链接
 glsl编译过程主要glCompileShader, glAttachShader, glLinkProgram;
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag
{
    GLuint verShader, fragShader;
    GLuint program = glCreateProgram();
    
    // 编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    // 释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    //
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

- (GLuint)setupTexture:(NSString *)fileName
{
    //1、获取图片的CGImageRef
    CGImageRef sheepImage = [UIImage imageNamed:fileName].CGImage;
    if (!sheepImage) {
        NSLog(@"------ failed load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片大小
    size_t width = CGImageGetWidth(sheepImage);
    size_t height = CGImageGetHeight(sheepImage);
    // rgba 共四个 byte
    GLubyte *sheepData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef sheepContext = CGBitmapContextCreate(sheepData, width, height, 8, width * 4, CGImageGetColorSpace(sheepImage), kCGImageAlphaPremultipliedLast);
    
    //3、在CGContextRef上绘图
    CGContextDrawImage(sheepContext, CGRectMake(0, 0, width, height), sheepImage);
    
    CGContextRelease(sheepContext);
    
    //4、绑定纹理到默认的纹理ID （这里只有一张图片，故而相当于默认于片段着色器里面的colorMap，如果有多张图片不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    /*
     纹理过滤函数glTexParameteri()
     图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
     　　部分参数功能说明如下:
     　　glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
     　　GL_TEXTURE_2D: 操作2D纹理.
     　　GL_TEXTURE_WRAP_S: S方向上的贴图模式.
     　　GL_CLAMP: 将纹理坐标限制在0.0,1.0的范围之内.如果超出了会如何呢.不会错误,只是会边缘拉伸填充.
     　　glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
     　　这里同上,只是它是T方向
     　　glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
     　　这是纹理过滤
     　　GL_TEXTURE_MAG_FILTER: 放大过滤
     　　GL_LINEAR: 线性过滤, 使用距离当前渲染像素中心最近的4个纹素加权平均值.
     　　glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
     　　GL_TEXTURE_MIN_FILTER: 缩小过滤
     　　GL_LINEAR_MIPMAP_NEAREST: 使用GL_NEAREST对最接近当前多边形的解析度的两个层级贴图进行采样,然后用这两个值进行线性插值.
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, sheepData);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(sheepData);
    return 0;
}
@end
