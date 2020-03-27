//
//  CGHAudioPlayer.h
//  MiniProgramExample
//
//  Created by wulinfeng on 2020/3/24.
//  Copyright © 2020 wulinfeng. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, CGHPlayerPlaybackState) {
    CGHPlayerPlaybackStateUnknown = 0,
    CGHPlayerPlaybackStatePlaying,
    CGHPlayerPlaybackStatePaused,
    CGHPlayerPlaybackStatePlayFailed,
    CGHPlayerPlaybackStatePlayStopped
};

NS_ASSUME_NONNULL_BEGIN

@interface CGHAudioPlayer : NSObject
@property (readonly) AVPlayer *player;
@property (readonly) NSString *audioId;
@property (readonly) NSString *src;
@property (readonly) BOOL paused;
@property (readonly) CGFloat volume;
@property (readonly) NSInteger timestamp;
@property (readonly) BOOL obeyMuteSwitch;
@property (readonly) CGFloat currentTime;
@property (readonly) CGFloat duration;
@property (readonly) CGFloat buffered;
@property (readonly) CGFloat startTime;
@property (readonly) BOOL autoplay;
@property (readonly) BOOL loop;

@property (readonly) CGHPlayerPlaybackState playbackState;
@property (readonly) BOOL isSeeking;
@property (readonly) CMTime seekTime;
@property (readonly) BOOL isPlayEnded;

@property (nonatomic, copy) void(^statusHandler)(CGHAudioPlayer *player, AVPlayerStatus status);
@property (nonatomic, copy) void(^endPlayHandler)(CGHAudioPlayer *player);

- (void)setAudioState:(NSDictionary *)args;

- (void)play;

- (void)pause;

- (void)stop;

- (void)seekToTime:(CMTime)time completionHandler:(nullable void (^)(CGHAudioPlayer *player, BOOL finished))completionHandler;

- (void)destroy;

- (void)setMuted:(BOOL)muted;

@end

NS_ASSUME_NONNULL_END
