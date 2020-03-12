//
//  TestRotateController.m
//  LFDemo
//
//  Created by wulinfeng on 2019/10/9.
//  Copyright © 2019 lio. All rights reserved.
//

#import "TestRotateController.h"

@interface TestRotateController ()

@end

@implementation TestRotateController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (IBAction)testAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)rotate:(UIButton *)sender {
    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationPortrait;
    NSLog(@"%ld", (long)deviceOrientation);
    [self setOrientation:deviceOrientation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setOrientation:UIDeviceOrientationPortrait];
}

- (void)setOrientation:(UIDeviceOrientation)deviceOrientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (!(currentDevice && [currentDevice respondsToSelector:selector])) {
        return;
    }
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(deviceOrientation) forKey:@"orientation"];
    
//     NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//     [invocation setSelector:selector];
//     [invocation setTarget:[UIDevice currentDevice]];
//     // UIInterfaceOrientationPortrait 竖屏的参数
//     int val = deviceOrientation;
//     [invocation setArgument:&val atIndex:2];
//     [invocation invoke];
}

@end
