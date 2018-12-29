//
//  PaintingView.m
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "PaintingView.h"

#define kBrushOpacity (1.0 / 3.0)
#define kBrushPixeStep 3
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
    GLint uinform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t progtam[NUM_PROGRAMS] = {
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
}
@end

@implementation PaintingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
