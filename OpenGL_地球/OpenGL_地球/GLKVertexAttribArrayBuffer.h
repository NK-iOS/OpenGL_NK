//
//  GLKVertexAttribArrayBuffer.h
//  OpenGL_地球
//
//  Created by 聂宽 on 2019/1/4.
//  Copyright © 2019年 聂宽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLKVertexAttribArrayBuffer : NSObject
{
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint name;
}

@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, readonly) GLsizeiptr stride;

+ (void)drawPreparedArraysWithModel:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

- (id)initWithAttribStride:(GLsizeiptr)pStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffSet:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)pStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr;
@end
