//
//  SoundEffect.h
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundEffect : NSObject
{
    SystemSoundID _soundID;
}
+ (instancetype)soundEffectWithContentsOfFile:(NSString *)file;
- (instancetype)initWithContentsOfFile:(NSString *)file;
- (void)play;
@end
