//
//  PaintingView.h
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface LYPoint : NSObject
@property (nonatomic, strong) NSNumber *mX;
@property (nonatomic, strong) NSNumber *mY;
@end

@interface PaintingView : UIView
@property (nonatomic, readwrite) CGPoint location;
@property (nonatomic, assign) CGPoint previousLocation;

- (void)erase;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

- (void)paint;
- (void)clearPaint;
@end
