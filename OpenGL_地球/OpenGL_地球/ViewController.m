//
//  ViewController.m
//  OpenGL_地球
//
//  Created by 聂宽 on 2019/1/4.
//  Copyright © 2019年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import "GLKVertexAttribArrayBuffer.h"
#import "sphere.h"

@interface ViewController ()
@property (nonatomic, strong) EAGLContext *mContext;

// 顶点
@property (nonatomic, strong) GLKVertexAttribArrayBuffer *vertexPosiztionBuffer;
@property (nonatomic, strong) GLKVertexAttribArrayBuffer *vertexNormalBuffer;
// 纹理
@property (nonatomic, strong) GLKVertexAttribArrayBuffer *vertexTexureCoord;
// 着色器
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

// 地球纹理
@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;

@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;

// 矩阵栈
@property (nonatomic) GLKMatrixStackRef modelViewMatrixStack;
@property (nonatomic) GLfloat earthRotationAngleDegrees;
@property (nonatomic) GLfloat moonRotationAngleDegrees;

@end
static const GLfloat SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat SceneMoonDistanceFromEarth = 2.0;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    glEnable(GL_DEPTH_TEST);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    [self confitureLight];
    
    GLfloat aspectRatio = self.view.bounds.size.width / self.view.bounds.size.height;
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0 * aspectRatio, 1.0 * aspectRatio, -1.0, 1.0, 1.0, 120.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    
    [self setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
    
    // 顶点数据
    [self bufferData];
}

- (void)confitureLight
{
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, 0.8f, 0.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
}

- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}

- (void)bufferData{
    self.modelViewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    // 顶点数据缓存
    self.vertexPosiztionBuffer = [[GLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    
    self.vertexNormalBuffer = [[GLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    
    self.vertexTexureCoord = [[GLKVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    
    // 地球纹理
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:@{GLKTextureLoaderOriginBottomLeft : [NSNumber numberWithBool:YES]} error:NULL];
    
    // 月球纹理
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:@{GLKTextureLoaderOriginBottomLeft : [NSNumber numberWithBool:YES]} error:NULL];
    
    // 矩阵堆
    GLKMatrixStackLoadMatrix4(self.modelViewMatrixStack, self.baseEffect.transform.modelviewMatrix);
    self.moonRotationAngleDegrees = -20.0f;
}

// 地球
- (void)drawEarth{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    
    GLKMatrixStackPush(self.modelViewMatrixStack);
    GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(SceneEarthAxialTiltDeg), 1.0, 0.0, 0.0);
    
    GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 0.0, 1.0, 0.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    
    [GLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelViewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
}

- (void)drawMoon{
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.modelViewMatrixStack);
    GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0.0, 1.0, 0.0);
    
    GLKMatrixStackTranslate(self.modelViewMatrixStack, 0.0, 0.0, SceneMoonDistanceFromEarth);
    
    GLKMatrixStackScale(self.modelViewMatrixStack, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth, SceneMoonRadiusFractionOfEarth);
    
    GLKMatrixStackRotate(self.modelViewMatrixStack, GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 0.0, 1.0, 0.0);
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    
    [GLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelViewMatrixStack);
    self.baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(self.modelViewMatrixStack);
}

// 场景数据变化
- (void)update{
    
}

// 渲染场景代码
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    self.earthRotationAngleDegrees += 360.0f / 60.0f;
    self.moonRotationAngleDegrees += (360.0f / 60.0f) / SceneDaysPerMoonOrbit;
    
    [self.vertexPosiztionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffSet:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffSet:0 shouldEnable:YES];
    [self.vertexTexureCoord prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffSet:0 shouldEnable:YES];
    
    [self drawEarth];
    [self drawMoon];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Return YES for supported orientations
    return (toInterfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown &&
            toInterfaceOrientation !=
            UIInterfaceOrientationPortrait);
}
@end
