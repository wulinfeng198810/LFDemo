//
//  NSNotificationCenterVC.m
//  LFDemo
//
//  Created by wlf on 2018/12/20.
//  Copyright © 2018 lio. All rights reserved.
//


//https://developer.apple.com/documentation/foundation/nsnotificationcenter/1413994-removeobserver?language=objc
//⚠️If your app targets iOS 9.0 and later or macOS 10.11 and later, you don't need to unregister an observer in its dealloc method
//思考：⚠️removeObserver 写类别交换方法，发现会跑；但写个子类 removeObserver 就不跑了


#import "NSNotificationCenterVC.h"
#import "LFNotificationCenter.h"

static NSString * const kWlfNotify = @"com.wlf.notify";


@implementation NSNotificationCenterVC

- (void)dealloc {
    NSLog(@"---------------- %@ %s ----------------", self.class, __func__);
//    [[LFNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TEST: n次添加同一个通知
    //测试结果：会收到同一个通知n次
    for (NSInteger i = 0; i < 3; i++) {
        [[LFNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveObserver) name:kWlfNotify object:nil];
    }
}

- (void)receiveObserver {
    NSLog(@"j哈哈啊哈");
}

- (IBAction)clickSendBtn:(id)sender {
    [[LFNotificationCenter defaultCenter] postNotificationName:kWlfNotify object:nil];
}

@end
