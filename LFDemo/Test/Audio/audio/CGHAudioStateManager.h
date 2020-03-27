//
//  CGHAudioStateManager.h
//  MiniProgramFramework
//
//  Created by wulinfeng on 2019/9/28.
//  Copyright © 2019 wulinfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGHBaseModuleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGHAudioStateManager : CGHBaseModuleManager

- (NSUInteger)distributeTaskId;

- (BOOL)createAudioInstance:(NSDictionary *)args;

- (void)destroyAudioInstance:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback;

- (BOOL)setAudioState:(NSDictionary *)args;

- (void)operateAudio:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback;

- (BOOL)removeAudio;

- (BOOL)setMuted:(NSDictionary *)args;

- (void)getAudioState:(NSDictionary *)args callback:(void(^)(NSDictionary *state))callback;

@end

NS_ASSUME_NONNULL_END
