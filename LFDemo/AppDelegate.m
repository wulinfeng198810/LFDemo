//
//  AppDelegate.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "AppDelegate.h"
#import <YYKit.h>
#import "3rd/YYFPSLabel.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"➡️ application path:%@", path);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self configFpsLabel];
    });
    
//    [self testDispatchSemaphore];
//    [self testDispatchBarrier];
//    [self testDispatchGroup];
    return YES;
}

- (void)testDispatchSemaphore {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    for (NSUInteger i = 0; i < 10; i++) {
        [self task:i callback:^{
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"====");
    NSLog(@"====123123");
}

- (void)testDispatchBarrier {
    NSLog(@"====000=====");
    dispatch_queue_t queue = dispatch_queue_create("save", DISPATCH_QUEUE_CONCURRENT);
    for (NSUInteger i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            sleep(1);
            NSLog(@"%@", @(i));
        });
    }
    NSLog(@"====1111====");
    dispatch_barrier_sync(queue, ^{
        NSLog(@"====2222====");
    });
    NSLog(@"====3333====");
}

- (void)testDispatchGroup {
    NSLog(@"====000=====");
    dispatch_group_t group = dispatch_group_create();
    for (NSUInteger i = 0; i < 10; i++) {
        dispatch_group_enter(group);
        [self task:i callback:^{
            dispatch_group_leave(group);
        }];
    }
    NSLog(@"====1111====");
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSLog(@"====");
    dispatch_queue_t queue = dispatch_queue_create("save", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_notify(group, queue, ^{
        NSLog(@"====2222====");
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSLog(@"====3333====");
}

- (void)task:(NSUInteger)taskId callback:(void(^)(void))callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(1);
        NSLog(@"taskId = %@", @(taskId));
        !callback ?: callback();
    });
}

- (void)configFpsLabel {
    YYFPSLabel *fps = [YYFPSLabel new];
    fps.top = 0;
    fps.left = 110;
    [self.window addSubview:fps];
    self.window.backgroundColor = UIColor.whiteColor;
}

@end
