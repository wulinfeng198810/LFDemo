//
//  CGHAudioStateManager.m
//  MiniProgramFramework
//
//  Created by wulinfeng on 2019/9/28.
//  Copyright © 2019 wulinfeng. All rights reserved.
//

#import "CGHAudioStateManager.h"
#import <AVFoundation/AVFoundation.h>
#import "YYKit.h"


#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

static void *kCGHStatusKVOKey = &kCGHStatusKVOKey;

static NSString * kCGHAudioState_play = @"play";
static NSString * kCGHAudioState_canplay = @"canplay";
static NSString * kCGHAudioState_seeking = @"seeking";
static NSString * kCGHAudioState_waiting = @"waiting";
static NSString * kCGHAudioState_seeked = @"seeked";
static NSString * kCGHAudioState_pause = @"pause";
static NSString * kCGHAudioState_ended = @"ended";

#pragma mark - CGHAVPlayer
@interface CGHAVPlayer : AVPlayer
@property (nonatomic, copy) NSString * audioId;
@property (nonatomic, copy) NSString * src;
@property (nonatomic, assign) BOOL paused;
//@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, assign) BOOL obeyMuteSwitch;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat buffered;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) BOOL loop;

@property (nonatomic, assign) BOOL isStop;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) CMTime seekTime;
@end


@implementation CGHAVPlayer
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

- (void)pause {
    self.paused = YES;
    [super pause];
}

- (void)play {
    self.paused = NO;
    self.isStop = NO;
    [super play];
}

- (BOOL)isPlayEnded {
    AVPlayerItem *currentItem = self.currentItem;
    if (currentItem && currentItem.status == AVPlayerStatusReadyToPlay && CMTimeGetSeconds(currentItem.duration) > 0) {
        return CMTimeCompare(currentItem.duration, currentItem.currentTime) == 0;
    }
    return NO;
}

@end


#pragma mark - CGHAVPlayerItem
@interface CGHAVPlayerItem : AVPlayerItem
@property (nonatomic, copy) NSString *audioId;
@end

@implementation CGHAVPlayerItem
@end



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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
//        self.delegate = delegate;
        self.audioInstanceStore = [[YYThreadSafeDictionary alloc] initWithCapacity:0];
        self.taskId = 1;
        _lock = dispatch_semaphore_create(1);
        
        NSOperationQueue *fileQueue = [[NSOperationQueue alloc] init];
        fileQueue.name = @"mini.audioQueue.";
        fileQueue.maxConcurrentOperationCount = 1;
        self.audioQueue = fileQueue;
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
- (void)createAudioInstance:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback {
    NSString *audioId = args[@"audioId"];
    if (!audioId) {
        !callback ?: callback(NO);
        return;
    }

    @weakify(self);
    [self.audioQueue addOperationWithBlock:^{
        @strongify(self);
        CGHAVPlayer *player = [[CGHAVPlayer alloc] init];
        self.audioInstanceStore[audioId] = player;
        !callback ?: callback(YES);
    }];
}

- (void)destroyAudioInstance:(NSDictionary *)args callback:(void(^)(BOOL isSuccess))callback {
    NSString *audioId = args[@"audioId"];
    if (!audioId) {
        !callback ?: callback(NO);
        return;
    }
    CGHAVPlayer *player = self.audioInstanceStore[audioId];
    if (!player) {
        !callback ?: callback(NO);
        return;
    }
    
    @weakify(self);
    [self.audioQueue addOperationWithBlock:^{
        @strongify(self);
        [player pause];
        [self removeStreamerObserver:(CGHAVPlayerItem *)player.currentItem];
        [self.audioInstanceStore removeObjectForKey:audioId];
        !callback ?: callback(YES);
    }];
}

- (BOOL)setAudioState:(NSDictionary *)args {
    NSString *audioId = args[@"audioId"];
    if (!audioId) { return NO; }
    CGHAVPlayer *player = self.audioInstanceStore[audioId];
    if (!player) { return NO; }
    if (player.src) { return NO; }
    
    [player setValuesForKeysWithDictionary:args];
    if (player.loop || player.autoplay) {
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
    CGHAVPlayer *player = self.audioInstanceStore[audioId];
    if (!player || !player.src) {
        !callback ?: callback(NO);
        return;
    }
    
    @weakify(self);
    [self.audioQueue addOperationWithBlock:^{
        @strongify(self);
        if ([operationType isEqualToString:@"play"]) {
            [self _operateAudioPlay:player];
            
        } else if ([operationType isEqualToString:@"pause"]) {
            [self onAudioStateChange:player.audioId state:kCGHAudioState_pause];
            [player pause];
            
        } else if ([operationType isEqualToString:@"stop"]) {
            [self onAudioStateChange:player.audioId state:kCGHAudioState_ended];
            player.isStop = YES;
            [player pause];
            
        } else if ([operationType isEqualToString:@"seek"]) {
            [self _operateAudioSeek:player args:args];
        }
        !callback ?: callback(YES);
    }];
}

- (void)_operateAudioPlay:(CGHAVPlayer *)player {
    [self onAudioStateChange:player.audioId state:kCGHAudioState_play];
    if (player.status != AVPlayerStatusReadyToPlay || player.isSeeking) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_waiting];
    }
    if (!player.currentItem) {
        CGHAVPlayerItem *currentPlayerItem = [CGHAVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:player.src]];
        currentPlayerItem.audioId = player.audioId;
        [self addStreamerObserver:currentPlayerItem];
        [player replaceCurrentItemWithPlayerItem:currentPlayerItem];
    }
    if ([player isPlayEnded]) {
        [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
    }
    [player play];
}

- (void)_operateAudioSeek:(CGHAVPlayer *)player args:(NSDictionary *)args {
    CGFloat currentTime = [args[@"currentTime"] floatValue]/1000;
    CMTime time = CMTimeMake(currentTime, 1);
    [self _playerVer0:player seekTime:time];
}

- (BOOL)removeAudio {
    for (NSString *audioId in self.audioInstanceStore.allKeys) {
        CGHAVPlayer *player = self.audioInstanceStore[audioId];
        [player pause];
        [self removeStreamerObserver:(CGHAVPlayerItem *)player.currentItem];
    };
    [self.audioInstanceStore removeAllObjects];
    [self.audioQueue cancelAllOperations];
    return YES;
}

- (BOOL)setMuted:(NSDictionary *)args {
    for (NSString *audioId in self.audioInstanceStore.allKeys) {
        CGHAVPlayer *player = self.audioInstanceStore[audioId];
        player.muted = [args[@"muted"] boolValue];
    };
    return YES;
}

- (void)getAudioState:(NSDictionary *)args callback:(void(^)(NSDictionary *state))callback {
    NSString *audioId = args[@"audioId"];
    if (!audioId) {
        !callback ?: callback(nil);
        return;
    }
    CGHAVPlayer *player = self.audioInstanceStore[audioId];
    [self.audioQueue addOperationWithBlock:^{
        AVPlayerItem *currentItem = player.currentItem;
        NSDictionary *res;
        if (currentItem.status == AVPlayerStatusReadyToPlay) {
            CGFloat duration = CMTimeGetSeconds(currentItem.duration)*1000;
            CGFloat currentTime = CMTimeGetSeconds(currentItem.currentTime)*1000;
            BOOL paused = player.paused;
            res = @{@"duration": @(duration),
                    @"currentTime": @(currentTime),
                    @"paused": @(paused),
                    @"src": @"",
                    @"startTime": @0,
                    @"buffered": @(duration)};
        } else {
            res = @{@"duration": NSNull.null,
                    @"currentTime": @(0),
                    @"paused": @(NO),
                    @"src": @""};
        }
        !callback ?: callback(res);
    }];
}


#pragma mark - seek
- (void)_player:(CGHAVPlayer *)player seekTime:(CMTime)seekTime {
    [self _player:player seekSmoothlyToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

- (void)_player:(CGHAVPlayer *)player seekSmoothlyToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    player.seekTime = time;
    if (!player.isSeeking) {
        [self _player:player trySeekToTargetTimeWithToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}

- (void)_player:(CGHAVPlayer *)player trySeekToTargetTimeWithToleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    if (player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self _player:player seekToTargetTimeToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}

- (void)_player:(CGHAVPlayer *)player seekToTargetTimeToleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL))completionHandler {
    player.isSeeking = YES;
    CMTime seekingTime = player.seekTime;
    @weakify(player);
    [player seekToTime:seekingTime toleranceBefore:toleranceBefore
             toleranceAfter:toleranceAfter completionHandler:
     ^(BOOL isFinished) {
         @strongify(player);
         if (CMTIME_COMPARE_INLINE(seekingTime, ==, player.seekTime)) {
             // seek completed
             player.isSeeking = NO;
             if (completionHandler) {
                 completionHandler(isFinished);
             }
         } else {
             // targetTime has changed, seek again
             [self _player:player trySeekToTargetTimeWithToleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
             NSLog(@"targetTime has changed, seek again");
         }
     }];
    [player play];
}

- (void)_playerVer0:(CGHAVPlayer *)player seekTime:(CMTime)seekTime {
    [self onAudioStateChange:player.audioId state:kCGHAudioState_seeking];
    if (player.currentItem.status != AVPlayerItemStatusReadyToPlay || player.isSeeking) {
        [self onAudioStateChange:player.audioId state:kCGHAudioState_waiting];
        return;
    }
     
    player.isSeeking = YES;
    player.seekTime = seekTime;
    @weakify(player);
    [player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL isFinished) {
        @strongify(player);
        // seek completed
        player.isSeeking = NO;
        [self onAudioStateChange:player.audioId state:kCGHAudioState_seeked];
        [self onAudioStateChange:player.audioId state:kCGHAudioState_canplay];
    }];
}


#pragma mark - status observer
- (void)removeStreamerObserver:(CGHAVPlayerItem *)playerItem {
    if (!playerItem) { return; }
    [playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)addStreamerObserver:(CGHAVPlayerItem *)playerItem {
    if (!playerItem) { return; }
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:kCGHStatusKVOKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kCGHStatusKVOKey) {
        CGHAVPlayerItem *playerItem = object;
        NSInteger oldStatus = [change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newStatus = [change[NSKeyValueChangeNewKey] integerValue];
        if (oldStatus == newStatus) { return; }
        NSString *status;
        switch (newStatus) {
            case AVPlayerStatusUnknown:
                status = @"未知";
                break;
            case AVPlayerStatusReadyToPlay: {
                status = @"已准备";
                [self onAudioStateChange:playerItem.audioId state:kCGHAudioState_canplay];
            }
                break;
            case AVPlayerStatusFailed: {
                status = @"失败";
            }
                break;
            default:
                break;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playbackFinished:(NSNotification *)noti {
    CGHAVPlayerItem *playerItem = noti.object;
    if (![playerItem isKindOfClass:CGHAVPlayerItem.class]) {
        return;
    }
    CGHAVPlayer *player = self.audioInstanceStore[playerItem.audioId];
    if (player.loop) {
        [self _player:player seekTime:kCMTimeZero];
    } else {
        player.paused = YES;
        [self onAudioStateChange:player.audioId state:kCGHAudioState_ended];
    }
}

#pragma mark - APPSERVICE_ON_EVENT
- (void)onAudioStateChange:(NSString *)audioId state:(NSString *)state {
    NSDictionary *data =
  @{@"audioId": audioId,
    @"state": state};
//    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onAudioStateChange" data:data];
}

@end
