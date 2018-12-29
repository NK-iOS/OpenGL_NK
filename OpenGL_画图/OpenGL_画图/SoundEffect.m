//
//  SoundEffect.m
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "SoundEffect.h"

@implementation SoundEffect
+ (instancetype)soundEffectWithContentsOfFile:(NSString *)file
{
    if (file) {
        return [[SoundEffect alloc] initWithContentsOfFile:file];
    }
    return nil;
}

- (instancetype)initWithContentsOfFile:(NSString *)file
{
    if (self = [super init]) {
        NSURL *fileUrl = [NSURL fileURLWithPath:file isDirectory:NO];
        if (fileUrl != nil) {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(fileUrl), &aSoundID);
            if (error == kAudioServicesNoError) {
                _soundID = aSoundID;
            }else
            {
                self = nil;
            }
        }else
        {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(_soundID);
}

- (void)play
{
    AudioServicesPlaySystemSound(_soundID);
}
@end
