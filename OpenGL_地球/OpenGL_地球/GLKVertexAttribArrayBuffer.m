//
//  GLKVertexAttribArrayBuffer.m
//  OpenGL_地球
//
//  Created by 聂宽 on 2019/1/4.
//  Copyright © 2019年 聂宽. All rights reserved.
//

#import "GLKVertexAttribArrayBuffer.h"

@interface GLKVertexAttribArrayBuffer()
@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;

@property (nonatomic, assign) GLsizeiptr stride;

@end

@implementation GLKVertexAttribArrayBuffer
@synthesize name;
@synthesize bufferSizeBytes;
@synthesize stride;

- (id)initWithAttribStride:(GLsizeiptr)pStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage
{
    NSParameterAssert(0 < pStride);
    NSAssert((0 < count && NULL != dataPtr) || (0 == count && NULL == dataPtr), @"data must not be null or count > 0");
    if (self = [super init]) {
        stride = pStride;
        bufferSizeBytes = stride * count;
        
        // 1 生成顶点缓冲对象
        glGenBuffers(1, &name);
        // 2 把顶点缓冲对象绑定到GL_array_BUFFER目标上
        glBindBuffer(GL_ARRAY_BUFFER, self.name);
        // 3 把数据复制到当前绑定的顶点缓冲对象上
        glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, dataPtr, usage);
        NSAssert(name != 0, @"Failed to generate name");
    }
    return self;
}

- (void)reinitWithAttribStride:(GLsizeiptr)pStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr
{
    NSParameterAssert(0 < pStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(dataPtr != NULL);
    NSAssert(name != 0, @"invalid name");
    
    self.stride = pStride;
    self.bufferSizeBytes = pStride * count;
    
    // 将顶点缓冲对戏那个绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    // 设置数据
    glBufferData(GL_ARRAY_BUFFER, self.bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffSet:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(name != 0, @"Invalid name");
    
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    
    if (shouldEnable) {
        // 开启缓存
        glEnableVertexAttribArray(index);
    }
    /*
     // Identifies the attribute to use
     // number of coordinates for attribute
     // data is floating point
     // no fixed point scaling
     // total num bytes stored per vertex
     // offset from start of each vertex to
     // first coord for attribute
     */
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
#ifdef DEBUG
    {
        GLenum error = glGetError();
        if (GL_NO_ERROR != error) {
            NSLog(@"gl error : 0x%x", error);
        }
    }
#endif
}

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >= ((first + count) * self.stride), @"attempt to draw more vertex data than available.");
    // 绘制
    glDrawArrays(mode, first, count);
}

+ (void)drawPreparedArraysWithModel:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    glDrawArrays(mode, first, count);
}

- (void)dealloc
{
    // 释放
    if (name != 0) {
        glDeleteBuffers(1, &name);
        name = 0;
    }
}
@end
