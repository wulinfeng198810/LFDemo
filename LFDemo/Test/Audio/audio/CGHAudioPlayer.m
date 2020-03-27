//
//  CGHAudioPlayer.m
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/24.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import "CGHAudioPlayer.h"
#import "YYKitMacro.h"

static void *kCGHStatusKVOKey = &kCGHStatusKVOKey;

@interface CGHAVPlayerItem : AVPlayerItem
@property (nonatomic, copy) NSString *audioId;
@end

@implementation CGHAVPlayerItem
@end



@interface CGHAudioPlayer()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, copy) NSString *audioId;
@property (nonatomic, copy) NSString *src;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, assign) BOOL obeyMuteSwitch;
@property (nonatomic, assign) CGFloat currentTime;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat buffered;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) BOOL loop;

@property (nonatomic, assign) CGHPlayerPlaybackState playbackState;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) CMTime seekTime;
@end

@implementation CGHAudioPlayer

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAudioState:(NSDictionary *)args {
    NSString *src = args[@"src"];
    [self setValuesForKeysWithDictionary:args];
    if (!self.player) {
        self.player = [[AVPlayer alloc] init];
    }
    CGHAVPlayerItem *currentItem = (CGHAVPlayerItem *)self.player.currentItem;
    if (currentItem) {
        [self removeStreamerObserver:currentItem];
    }
    
    NSURL *url = ([src.lowercaseString hasPrefix:@"http"] || [src.lowercaseString hasPrefix:@"https"]) ? [NSURL URLWithString:src] : [NSURL fileURLWithPath:src];
    CGHAVPlayerItem *currentPlayerItem = [CGHAVPlayerItem playerItemWithURL:url];
    currentPlayerItem.audioId = self.audioId;
    
    self.playbackState = CGHPlayerPlaybackStateUnknown;
    self.isSeeking = NO;
    self.seekTime = kCMTimeZero;
    self.player.volume = (self.volume > 0 && self.volume < 1) ? self.volume : 1;
    [self addStreamerObserver:currentPlayerItem];
    
    [self.player replaceCurrentItemWithPlayerItem:currentPlayerItem];
    if (self.duration) {//init seek
        CGFloat currentTime = [args[@"currentTime"] floatValue]/1000;
        CMTime time = CMTimeMake(currentTime, 1);
        [self.player seekToTime:time completionHandler:^(BOOL isFinished) {}];
    }
}

- (void)play {
    self.playbackState = CGHPlayerPlaybackStatePlaying;
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player play];
    }
}

- (void)pause {
    self.playbackState = CGHPlayerPlaybackStatePaused;
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player pause];
    }
}

- (void)stop {
    self.playbackState = CGHPlayerPlaybackStatePlayStopped;
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player pause];
    }
}

- (void)seekToTime:(CMTime)seekTime completionHandler:(nullable void (^)(CGHAudioPlayer * _Nonnull, BOOL))completionHandler {
    self.isSeeking = YES;
    self.seekTime = seekTime;
    @weakify(self);
    [self.player seekToTime:seekTime completionHandler:^(BOOL isFinished) {
        @strongify(self);
        self.isSeeking = NO;
        !completionHandler ?: completionHandler(self, isFinished);
    }];
}

- (BOOL)isPlayEnded {
    AVPlayerItem *currentItem = self.player.currentItem;
    if (currentItem && currentItem.status == AVPlayerStatusReadyToPlay && CMTimeGetSeconds(currentItem.duration) > 0) {
        return CMTimeCompare(currentItem.duration, currentItem.currentTime) == 0;
    }
    return NO;
}

- (void)destroy {
    [self.player pause];
    if (self.player.currentItem) {
        [self removeStreamerObserver:(CGHAVPlayerItem *)self.player.currentItem];
    }
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
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
        NSInteger oldStatus = [change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newStatus = [change[NSKeyValueChangeNewKey] integerValue];
        if (oldStatus == newStatus) { return; }
        NSString *status;
        switch (newStatus) {
            case AVPlayerStatusUnknown:
                status = @"AVPlayerStatusUnknown";
                break;
            case AVPlayerStatusReadyToPlay: {
                status = @"AVPlayerStatusReadyToPlay";
            }
                break;
            case AVPlayerStatusFailed: {
                status = @"AVPlayerStatusFailed";
            }
                break;
            default:
                break;
        }
        if (newStatus == AVPlayerStatusReadyToPlay || newStatus == AVPlayerStatusFailed) {
            if (newStatus == AVPlayerStatusFailed) {
                self.playbackState = CGHPlayerPlaybackStatePlayFailed;
                NSLog(@"play fail %@", status);
            }
            !self.statusHandler ?: self.statusHandler(self, newStatus);
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
    if (playerItem != self.player.currentItem) {
        return;
    }
    self.paused = YES;
    !self.endPlayHandler ?: self.endPlayHandler(self);
}
@end
