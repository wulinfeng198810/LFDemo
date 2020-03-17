//
//  CGHJSTimer.h
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/17.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CGHJSTimerExport <JSExport>
- (void)clearTimeout:(NSString *)identifier;
- (void)clearInterval:(NSString *)identifier;
- (NSString *)setTimeout:(JSValue *)callback :(double)ms;
- (NSString *)setInterval:(JSValue *)callback :(double)ms;
@end

@interface CGHJSTimer : NSObject <CGHJSTimerExport>
- (void)registerInto:(JSContext*)jsContext forKeyedSubscript:(NSString *)forKeyedSubscript;
- (void)clearAllTimers;
@end

NS_ASSUME_NONNULL_END
