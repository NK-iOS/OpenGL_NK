//
//  ViewController.m
//  OpenGL_画图
//
//  Created by 聂宽 on 2018/12/28.
//  Copyright © 2018年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import "SoundEffect.h"
#import "PaintingView.h"

// 亮度
#define  kBrightness 1.0
// 饱和度
#define  kStaturation 0.45

#define  kPaletteHeight 30
#define  kpaletteSize 5
#define  kMinEraseInterval 0.5

#define  kLeftMargin 10.0
#define  kTopMargin 10.0
#define  kRightMargin 10.0

@interface ViewController ()
@property (nonatomic, strong) SoundEffect *erasingSound;
@property (nonatomic, strong) SoundEffect *selectSound;
@property (nonatomic, assign) CFTimeInterval lastTime;

@property (nonatomic, strong) PaintingView *paintingView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingUI];
}

- (void)settingUI
{
    PaintingView *paintingView = [[PaintingView alloc] init];
    _paintingView = paintingView;
    paintingView.frame = self.view.bounds;
    [self.view addSubview:paintingView];
    
    // 调色板
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                      [[UIImage imageNamed:@"Red"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                      [[UIImage imageNamed:@"Yellow"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                      [[UIImage imageNamed:@"Green"]     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                      [[UIImage imageNamed:@"Blue"]      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                                      [[UIImage imageNamed:@"Purple"]    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal],
                                                                            nil]];
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
    segmentedControl.frame = frame;
    [segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.tintColor = [UIColor darkGrayColor];
    segmentedControl.selectedSegmentIndex = 2;
    [self.view addSubview:segmentedControl];
    
    // 初始化颜色
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kpaletteSize saturation:kStaturation brightness:kBrightness alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    [_paintingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
    // 初始化声音
    _erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Erase" ofType:@"caf"]];
    _selectSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Select" ofType:@"caf"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
}

- (void)eraseView
{
    if (CFAbsoluteTimeGetCurrent() > _lastTime + kMinEraseInterval) {
        [_erasingSound play];
        [_paintingView erase];
        _lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)changeBrushColor:(UISegmentedControl *)segControl
{
    [_selectSound play];
    
    CGColorRef color = [UIColor colorWithHue:(CGFloat)[segControl selectedSegmentIndex] / (CGFloat)kpaletteSize saturation:kStaturation brightness:kBrightness alpha:1.0].CGColor;
    
    const CGFloat *components = CGColorGetComponents(color);
    
    [_paintingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
