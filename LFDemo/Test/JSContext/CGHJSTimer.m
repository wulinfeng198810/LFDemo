//
//  CGHJSTimer.m
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/17.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import "CGHJSTimer.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "YYThreadSafeDictionary.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@interface CGHJSTimer()
@property(nonatomic, strong) YYThreadSafeDictionary *timersMap;
@property(nonatomic, assign) NSUInteger timerId;
@end

@implementation CGHJSTimer
{
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timersMap = [YYThreadSafeDictionary dictionary];
        _lock = dispatch_semaphore_create(1);
        self.timerId = 100000;
    }
    return self;
}

- (void)registerInto:(JSContext*)jsContext forKeyedSubscript:(NSString *)forKeyedSubscript {
    [jsContext setObject:self forKeyedSubscript:forKeyedSubscript];
    NSString *timeJs =
    [NSString stringWithFormat:
     @"function clearTimeout(indentifier){%@.clearTimeout(indentifier)}\
     function clearInterval(indentifier){%@.clearInterval(indentifier)}\
     function setTimeout(callback,ms){return %@.setTimeout(callback,ms)}\
     function setInterval(callback,ms){return %@.setInterval(callback,ms)}",
     forKeyedSubscript, forKeyedSubscript, forKeyedSubscript, forKeyedSubscript];
    [jsContext evaluateScript:timeJs];
}

- (void)clearAllTimers {
    [self.timersMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [(NSTimer*)value invalidate];
    }];
    [self.timersMap removeAllObjects];
}

#pragma mark - protocol
- (void)clearInterval:(NSString *)identifier {
    [self _invalidate:identifier];
}

- (void)clearTimeout:(NSString *)identifier {
    [self _invalidate:identifier];
}

- (NSString *)setInterval:(JSValue *)callback :(double)ms {
    return [self _createTimer:callback ms:ms repeats:YES];
}

- (NSString *)setTimeout:(JSValue *)callback :(double)ms {
    return [self _createTimer:callback ms:ms repeats:NO];
}

- (void)_invalidate:(NSString *)identifier {
    if (!identifier) { return; }
    NSTimer *timer = self.timersMap[identifier];
    [self.timersMap removeObjectForKey:identifier];
    if (timer.isValid) {
        [timer invalidate];
    }
}

- (NSString *)_createTimer:(JSValue *)callback ms:(double)ms repeats:(BOOL)repeats {
    NSTimeInterval timeInterval  = ms/1000.0;
    Lock();
    NSString *uuid = @(self.timerId++).stringValue;
    Unlock();
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate interval:timeInterval target:self selector:@selector(_callJsCallback:) userInfo:@{@"value":callback, @"timerId":uuid, @"repeats":@(repeats)} repeats:repeats];
    //[timer fire];//不能调用fire，否则定时器立刻执行
    //[NSRunLoop currentRunLoop] 非 mainRunLoop 时，timer不跑
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.timersMap[uuid] = timer;
    return uuid;
}

- (void)_callJsCallback:(NSTimer *)timer {
    NSDictionary *userInfo = timer.userInfo;
    JSValue *callback = (JSValue *)(userInfo[@"value"]);
    NSNumber *repeats = (NSNumber *)(userInfo[@"repeats"]);
    if ([callback isString]) { //setInterval("console.log(111111)", 1000);
        [callback.context evaluateScript:callback.description];
    } else { //setInterval(fun, 1000);
        [callback callWithArguments:nil];
    }
    if (![repeats boolValue]) { //setTimeout直接移除
        NSString *timerId = (NSString *)(userInfo[@"timerId"]);
        [self _invalidate:timerId];
    }
}

@end
