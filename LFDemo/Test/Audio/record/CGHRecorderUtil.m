//
//  CGHRecorderUtil.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/27.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHRecorderUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "YYKitMacro.h"

@implementation CGHRecorderUtil

+ (void)mergeAudios:(nonnull NSArray*)urls toPath:(nonnull NSString *)destPath completeHandler:(void(^)(NSError *__nullable error, NSURL *__nullable outputUrl))completeHandler {
    if (urls.count < 2 || !destPath) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"params error"}];
        !completeHandler ?: completeHandler(error, nil);
        return;
    }
    
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    CMTime beginTime = kCMTimeZero;
    for (NSString *sourceURL in urls) {
        AVURLAsset  *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:sourceURL] options:nil];
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        BOOL success = [compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:beginTime error:&error];
        if (!success) {
            !completeHandler ?: completeHandler(error, nil);
            break;
        }
        beginTime = CMTimeAdd(beginTime, audioAsset.duration);
    }
    
    NSURL *outputURL = [NSURL fileURLWithPath:destPath];
    AVAssetExportSession *assetExportSession = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    assetExportSession.outputURL = outputURL;
    assetExportSession.outputFileType = AVFileTypeWAVE;
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (assetExportSession.status) {
            case AVAssetExportSessionStatusCompleted: {
                !completeHandler ?: completeHandler(nil, outputURL);
            }  break;
                
            case AVAssetExportSessionStatusFailed: {
                !completeHandler ?: completeHandler(assetExportSession.error, nil);
            }  break;
                
            default: break;
        }
    }];
}

+ (void)convetM4aToWav:(NSString *)srcPath destPath:(NSString *)destPath completeHandler:(void (^)(NSError * _Nullable))completeHandler {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if ([fileManager fileExistsAtPath:destPath]) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"destPath is exists"}];
        !completeHandler ?: completeHandler(error);
    }
    
    if (![fileManager fileExistsAtPath:destPath.stringByDeletingLastPathComponent] && ![fileManager createDirectoryAtPath:destPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"mkdir fail"}];
        !completeHandler ?: completeHandler(error);
    }
    
    NSURL *originalUrl = [NSURL fileURLWithPath:srcPath];
    NSURL *destUrl     = [NSURL fileURLWithPath:destPath];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:originalUrl options:nil];
    
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&error];
    if (error) {
        !completeHandler ?: completeHandler(error);
        return;
    }
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks audioSettings:nil];
    if (![assetReader canAddOutput:assetReaderOutput]) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"AVAssetReaderOutput -canAddOutput fail"}];
        completeHandler(error);
        return;
    }
    [assetReader addOutput:assetReaderOutput];
    
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:destUrl fileType:AVFileTypeWAVE error:&error];
    if (error) {
        !completeHandler ?: completeHandler(error);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings =
  @{AVFormatIDKey:@(kAudioFormatLinearPCM),
    AVSampleRateKey:@8000,
    AVNumberOfChannelsKey:@1,
    AVLinearPCMIsNonInterleaved:@NO,
    AVLinearPCMBitDepthKey:@16,
    AVLinearPCMIsFloatKey:@NO,
    AVLinearPCMIsBigEndianKey:@NO};
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    assetWriterInput.expectsMediaDataInRealTime = NO;
    if (![assetWriter canAddInput:assetWriterInput]) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"AVAssetWriterInput -canAddOutput fail"}];
        !completeHandler ?: completeHandler(error);
        return;
    }
    [assetWriter addInput:assetWriterInput];
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = songAsset.tracks.firstObject;
    CMTime startTime = CMTimeMake(0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime:startTime];
    
    void(^completeBlock)(void) = ^{
        NSLog(@"convert end");
        NSError *error = nil;
        NSFileManager *fileManager = NSFileManager.defaultManager;
        if ([fileManager fileExistsAtPath:srcPath] && ![fileManager removeItemAtPath:srcPath error:&error]) {
            NSLog(@"remove src fail");
        }
        !completeHandler ?: completeHandler(nil);
    };
    
    NSLog(@"convert begin");
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock: ^{
        while (assetWriterInput.readyForMoreMediaData) {
            CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
            if (nextBuffer) {
                [assetWriterInput appendSampleBuffer:nextBuffer];
                CFRelease(nextBuffer);
                
            } else {
                [assetWriterInput markAsFinished];
                [assetWriter finishWritingWithCompletionHandler:^{
                    completeBlock();
                }];
                [assetReader cancelReading];
                break;
            }
        }
     }];
    
}

@end
