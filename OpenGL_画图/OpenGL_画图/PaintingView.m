//
//  PaintingView.m
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "PaintingView.h"
#import <GLKit/GLKit.h>
#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

#define kBrushOpacity (1.0 / 3.0)
#define kBrushPixelStep 3
#define kBrushScale 2

// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    {"point.vsh", "point.fsh"}, // PROGRAM_POINT
};

// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;

@implementation LYPoint
- (instancetype)initWithCGPoint:(CGPoint)point {
    if (self = [super init]) {
        self.mX = [NSNumber numberWithDouble:point.x];
        self.mY = [NSNumber numberWithDouble:point.y];
    }
    return self;
}
@end

@interface PaintingView()
{
    // The pixel dimensions of the backbuffer
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
    
    // brush texture
    textureInfo_t brushTexture;
    
    // brush color
    GLfloat brushColor[4];
    
    Boolean firshTouch;
    Boolean needsErase;
    
    // shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    
    // buffer objects
    GLuint vboId;
    
    BOOL initialized;
    
    NSMutableArray *lyArr;
}
@end

@implementation PaintingView

@synthesize location;
@synthesize previousLocation;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)init
{
    if (self = [super init]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:YES], kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        needsErase = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    if (!initialized) {
        initialized = [self initGL];
    }else
    {
        [self resizeFromLayer:(CAEAGLLayer *)self.layer];
    }
    
    if (needsErase) {
        [self erase];
        needsErase = NO;
    }
}

- (BOOL)initGL{
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    glViewport(0, 0, backingWidth, backingHeight);
    glGenBuffers(1, &vboId);
    
    // load the brush texture
    brushTexture = [self textureFromName:@"Particle.png"];
    
    // load shaders
    [self setupShaders];
    
    /*
     enable blending and set a blending function appropriate
     for premultiplied alpha pixel data
     */
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    // playback recorded path
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"string"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    lyArr = [NSMutableArray array];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *dict in jsonArr) {
        LYPoint *point = [[LYPoint alloc] init];
        point.mX = [dict objectForKey:@"mX"];
        point.mY = [dict objectForKey:@"mY"];
        [lyArr addObject:point];
    }
    [self performSelector:@selector(paint) withObject:nil afterDelay:0.5];
    return YES;
}

// create a texture from an image
- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef brushImage;
    CGContextRef brushContext;
    GLbyte *brushData;
    size_t width, height;
    GLuint texId;
    textureInfo_t texture;
    
    brushImage = [UIImage imageNamed:name].CGImage;
    
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
//    if (brushImage) {
//
//    }
    brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(brushContext, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), brushImage);
    
    CGContextRelease(brushContext);
    
    glGenTextures(1, &texId);
    
    glBindTexture(GL_TEXTURE_2D, texId);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
    
    free(brushData);
    
    texture.id = texId;
    texture.width = (int)width;
    texture.height = (int)height;
    
    return texture;
}

// 设置着色器
- (void)setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; i++) {
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex"
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
          "MVP", "pointSize", "vertexColor", "texture"
        };
        
        for (int j = 0; j < NUM_ATTRIBS; j++) {
            if (strstr(vsrc, attribName[j])) {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }
        
        glueCreateProgram(vsrc, fsrc, attribCt, (const GLchar **)&attribUsed[0], attrib, NUM_UNIFORMS, &uniformName[0], program[i].uniform, &program[i].id);
        free(vsrc);
        free(fsrc);
        
        // 初始化uniforms
        if (i == PROGRAM_POINT) {
            glUseProgram(program[PROGRAM_POINT].id);
            // the brush texture will be bound to texture unit 0
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            // this sample uses a constant identity modelView matrix
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            
            // point size
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);
        
            // initialize brush color
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }
    glError();
}

- (void)paint
{
    NSMutableArray *mutableArr = [NSMutableArray array];
    for (LYPoint *point in lyArr) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:point.mX forKey:@"mX"];
        [dict setObject:point.mY forKey:@"mY"];
        [mutableArr addObject:dict];
    }
    for (int i = 0; i + 1 < lyArr.count; i+= 2) {
        LYPoint *lyPoint1 = lyArr[i];
        LYPoint *lyPoint2 = lyArr[i + 1];
        CGPoint point1, point2;
        point1.x = lyPoint1.mX.floatValue;
        point1.y = lyPoint1.mY.floatValue;
        point2.x = lyPoint2.mX.floatValue;
        point2.y = lyPoint2.mY.floatValue;
        [self renderLineFormPoint:point1 toPoint:point2];
    }
}

// drawings a line on screen based on where the user touches
- (void)renderLineFormPoint:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat *vertexBuffer = NULL;
    static NSUInteger vertexMax = 64;
    NSUInteger vertexCount = 0, count, i;
    
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    // convert locations from points to pixels
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // 分配顶点缓存
    if (vertexBuffer == NULL) {
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    }
    // add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for (i = 0; i < count; ++i) {
        if (vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }
        
        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }
    
    // load data to the vertex buffer object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * 2 * sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // draw
    glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    
    // display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // update viewport
    glViewport(0, 0, backingWidth, backingHeight);
    return YES;
}

- (void)erase{
    [EAGLContext setCurrentContext:context];
    
    // clear the buffer
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mrak - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = [self bounds];
    UITouch * touch = [[event touchesForView:self] anyObject];
    firshTouch = YES;
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = [self bounds];
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if (firshTouch) {
        firshTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }else
    {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
    }
    
    [self renderLineFormPoint:previousLocation toPoint:location];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = [self bounds];
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if (firshTouch) {
        firshTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        [self renderLineFormPoint:previousLocation toPoint:location];
    }
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
    
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
    glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)dealloc
{
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    
    if (depthRenderbuffer) {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
    
    // texture
    if (brushTexture.id) {
        glDeleteTextures(1, &brushTexture.id);
        brushTexture.id = 0;
    }
    
    // vbo
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    
    // 移除context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
}
@end
