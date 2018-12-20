//
//  NSNotificationCenter+LFAdd.m
//  LFDemo
//
//  Created by wlf on 2018/12/20.
//  Copyright © 2018 lio. All rights reserved.
//

#import "NSNotificationCenter+LFAdd.h"
#import <objc/runtime.h>

@implementation NSNotificationCenter (LFAdd)

+ (void)load {
    Method origin = class_getInstanceMethod([self class], @selector(removeObserver:));
    Method current = class_getInstanceMethod([self class], @selector(_removeObserver:));
    method_exchangeImplementations(origin, current);
}

- (void)_removeObserver:(id)observer {
    NSLog(@"调用移除通知方法: %@", observer);
    [self _removeObserver:observer];
}

@end
