//
//  CGHAudioStateManager.m
//  MiniProgramFramework
//
//  Created by wulinfeng on 2019/9/28.
//  Copyright © 2019 wulinfeng. All rights reserved.
//

#import "CGHAudioStateManager.h"
#include <CoreMedia/CMTime.h>
#import "CGHAudioPlayer.h"
#import "YYKitMacro.h"
#import "YYThreadSafeDictionary.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

static NSString * kCGHAudioState_play = @"play";
static NSString * kCGHAudioState_canplay = @"canplay";
static NSString * kCGHAudioState_seeking = @"seeking";
static NSString * kCGHAudioState_waiting = @"waiting";
static NSString * kCGHAudioState_seeked = @"seeked";
static NSString * kCGHAudioState_pause = @"pause";
static NSString * kCGHAudioState_stop = @"stop";
static NSString * kCGHAudioState_ended = @"ended";

#pragma mark - CGHAudioStateManager
@interface CGHAudioStateManager()
@property (nonatomic, strong) NSOperationQueue *audioQueue;
@property (nonatomic, strong) YYThreadSafeDictionary *audioInstanceStore;
@property (nonatomic, assign) NSUInteger taskId;
@end

@implementation CGHAudioStateManager
{
    dispatch_semaphore_t _lock;
}

- (instancetype)initWithDelegate:(id)delegate {
    self = [super initWithDelegate:delegate];
    if (self) {
        self.audioInstanceStore = [[YYThreadSafeDictionary alloc] initWithCapacity:0];
        self.taskId = 1;
        _lock = dispatch_semaphore_create(1);
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = [@"mini.audioQueue." stringByAppendingString:@""];
        queue.maxConcurrentOperationCount = 1;
        self.audioQueue = queue;
    }
    return self;
}

- (NSUInteger)distributeTaskId {
    Lock();
    NSUInteger _tId = self.taskId++;
    Unlock();
    return _tId;
}

#pragma mark - core
- (BOOL)createAudioInstance:(NSDictionary *)args {
    NSString *audioId = args[@"audioId"];
    CGHAudioPlayer *player = CGHAudioPlayer.new;
    self.audioInstanceStore[audioId] = player;
    @weakify(self);
    player.endPlayHandler = ^(CGHAudioPlayer * _Nonnull player) {
        @strongify(self);
        if (player.loop) {
            [player seekToTime:kCMTimeZero completionHandler:nil];
            [player play];
            
        } else {
            [self onAudioStateChange:player.audioId state:kCGHAudioState_pause];
            [self onAudioStateChange:player.audioId state:kCGHAudioState_ended];
            [player pause];
            [self _player:player seekTime:kCMTimeZero];
        }
    };
    
    player.statusHandler = ^(CGHAudioPlayer * _Nonnull player, AVPlayerStatus status) {
        @strongify(self);
        if (status == AVPlayerStatusReadyToPlay) {
            [self onAudioStateChange:player.audioId state:kCGHAudioState_canplay];
            if (player.playbackState == CGHPlayerPlaybackStatePlaying) {
                [player.player play];
            } else if (player.playbackState == CGHPlayerPlaybackStatePaused || player.playbackState == CGHPlayerPlaybackStatePlayStopped) {
                [player.player pause];
            }
        } else if (status == AVPlayerStatusFailed) {
            [self onAudioStateChange:player.audioId error:nil];
        }
    };
    return audioId != nil;
}

- (void)destroyAudioInstance:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback {
    NSString *audioId = args[@"audioId"];
    if (!audioId) {
        !callback ?: callback(NO);
        return;
    }
    CGHAudioPlayer *player = self.audioInstanceStore[audioId];
    if (!player) {
        !callback ?: callback(NO);
        return;
    }
    
    @weakify(self);
    [self.audioQueue addOperationWithBlock:^{
        @strongify(self);
        [player destroy];
        [self.audioInstanceStore removeObjectForKey:audioId];
        !callback ?: callback(YES);
    }];
}

- (BOOL)setAudioState:(NSDictionary *)args {
    NSString *audioId = args[@"audioId"];
    NSString *src = args[@"src"];
    if (!audioId) { return NO; }
    CGHAudioPlayer *player = self.audioInstanceStore[audioId];
    if (!player) { return NO; }
    
    if (player.src) {
        if ([player.src isEqualToString:src]) {
            return YES;
        } else {
            [player pause];
        }
    }
    [player setAudioState:args];
    [self onAudioStateChange:player.audioId state:kCGHAudioState_waiting];
    if (player.autoplay) {
        [self _operateAudioPlay:player];
    }
    return YES;
}

- (void)operateAudio:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback {
    NSString *audioId = args[@"audioId"];
    NSString *operationType = args[@"operationType"];
    if (!audioId || !operationType) {
        !callback ?: callback(NO);
        return;
    }
    CGHAudioPlayer *player = self.audioInstanceStore[audioId];
    if (!player || !player.player) {
        !callback ?: callback(NO);
        return;
    }
    
    @weakify(self);
    [self.audioQueue addOperationWithBlock:^{
        @strongify(self);
        if ([operationType isEqualToString:@"play"]) {
            [self _operateAudioPlay:player];
            
        } else if ([operationType isEqualToString:@"pause"]) {
            [self _operateAudioPause:player];
            
        } else if ([operationType isEqualToString:@"stop"]) {
            [self _operateAudioStop:player];
            
        } else if ([operationType isEqualToString:@"seek"]) {
            [self _operateAudioSeek:player args:args];
        }
        !callback ?: callback(YES);
    }];
}

- (void)_operateAudioPlay:(CGHAudioPlayer *)player {
    if (player.playbackState != CGHPlayerPlaybackStatePlaying) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_play];
    }
    if (player.player.status != AVPlayerStatusReadyToPlay || player.player.currentItem.playbackBufferEmpty) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_waiting];
    }
    if (player.isPlayEnded) {
        [self _player:player seekTime:kCMTimeZero];
    }
    [player play];
}

- (void)_operateAudioPause:(CGHAudioPlayer *)player {
    [player pause];
    if (player.playbackState == CGHPlayerPlaybackStatePlaying) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_pause];
    }
}

- (void)_operateAudioStop:(CGHAudioPlayer *)player {
    [player stop];
    if (player.playbackState == CGHPlayerPlaybackStatePlaying) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_stop];
    } else if (CMTimeGetSeconds(player.player.currentTime) > 0) {
        [self _player:player seekTime:kCMTimeZero];
    }
}

- (void)_operateAudioSeek:(CGHAudioPlayer *)player args:(NSDictionary *)args {
    CGFloat currentTime = [args[@"currentTime"] floatValue]/1000;
    CMTime time = CMTimeMake(currentTime, 1);
    [self _player:player seekTime:time];
}

- (BOOL)removeAudio {
    for (NSString *audioId in self.audioInstanceStore.allKeys) {
        CGHAudioPlayer *player = self.audioInstanceStore[audioId];
        [player destroy];
    };
    [self.audioInstanceStore removeAllObjects];
    [self.audioQueue cancelAllOperations];
    return YES;
}

- (BOOL)setMuted:(NSDictionary *)args {
    for (NSString *audioId in self.audioInstanceStore.allKeys) {
        CGHAudioPlayer *player = self.audioInstanceStore[audioId];
        [player setMuted:[args[@"muted"] boolValue]];
    };
    return YES;
}

- (void)getAudioState:(NSDictionary *)args callback:(void(^)(NSDictionary *state))callback {
    NSString *audioId = args[@"audioId"];
    if (!audioId) {
        !callback ?: callback(nil);
        return;
    }
    CGHAudioPlayer *player = self.audioInstanceStore[audioId];
    [self.audioQueue addOperationWithBlock:^{
        AVPlayerItem *currentItem = player.player.currentItem;
        NSString *src = player.src ?: @"";
        NSDictionary *res;
        if (currentItem.status == AVPlayerStatusReadyToPlay) {
            CGFloat duration = CMTimeGetSeconds(currentItem.duration)*1000;
            CGFloat currentTime = CMTimeGetSeconds(currentItem.currentTime)*1000;
            BOOL paused = player.playbackState == CGHPlayerPlaybackStatePaused || player.playbackState == CGHPlayerPlaybackStatePlayStopped;
            res = @{@"duration": @(duration),
                    @"currentTime": @(currentTime),
                    @"paused": @(paused),
                    @"src": src,
                    @"startTime": @0,
                    @"buffered": @(duration)};
        } else {
            res = @{@"duration": NSNull.null,
                    @"currentTime": @(0),
                    @"paused": @(NO),
                    @"src": src};
        }
        !callback ?: callback(res);
    }];
}

- (void)_player:(CGHAudioPlayer *)player seekTime:(CMTime)seekTime {
    if (player.player.status != AVPlayerItemStatusReadyToPlay) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_waiting];
        return;
    }
    
    if (!player.isSeeking) {
         [self onAudioStateChange:player.audioId state:kCGHAudioState_seeking];
    }
    @weakify(self);
    [player seekToTime:seekTime completionHandler:^(CGHAudioPlayer * _Nonnull player, BOOL finished) {
        @strongify(self);
        [self onAudioStateChange:player.audioId state:kCGHAudioState_seeked];
        [self onAudioStateChange:player.audioId state:kCGHAudioState_canplay];
        if (player.playbackState == CGHPlayerPlaybackStatePlaying) {
            [player.player play];
        } else if (player.playbackState == CGHPlayerPlaybackStatePaused || player.playbackState == CGHPlayerPlaybackStatePlayStopped) {
            [player.player pause];
        }
    }];
}

#pragma mark - APPSERVICE_ON_EVENT
- (void)onAudioStateChange:(NSString *)audioId state:(NSString *)state {
    NSDictionary *data =
  @{@"audioId": audioId,
    @"state": state};
//    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onAudioStateChange" data:data];
}

- (void)onAudioStateChange:(NSString *)audioId error:(NSError *)error {
    NSDictionary *data =
  @{@"audioId": audioId,
    @"state": @"error",
    @"errMsg": @"MediaError",
    @"errCode": @10004
  };
//    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onAudioStateChange" data:data];
}

@end
