//
//  TestAudioVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/10/8.
//  Copyright © 2019 lio. All rights reserved.
//

#import "TestAudioVC.h"
#import <YYKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CGHRecorderManager.h"
#import "CGHAudioStateManager.h"
#import "CGHRecorderUtil.h"

@interface TestAudioVC ()
@property (nonatomic, strong) CGHRecorderManager *recorderManager;
@property (nonatomic, strong) CGHAudioStateManager *audioStateManager;
@property (nonatomic, copy) NSString *filePath;
@end

@implementation TestAudioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recorderManager = CGHRecorderManager.new;
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route inputs]) {
        NSLog(@"%@", desc);
    }
    
//
    self.audioStateManager = [[CGHAudioStateManager alloc] initWithDelegate:nil];
    [self.audioStateManager createAudioInstance:@{@"audioId": @"1"}];
    
    [self merge];
    
}

- (void)merge {
    NSArray *arr = @[@"0.wav", @"1.wav"];
    NSMutableArray *files = @[].mutableCopy;
    NSString *bundlePath = NSBundle.mainBundle.bundlePath;
    NSString *tmpWavPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"merge.wav"];
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [files addObject:[bundlePath stringByAppendingPathComponent:obj]];
    }];
    [CGHRecorderUtil mergeAudios:files toPath:tmpWavPath completeHandler:^(NSError * _Nullable error, NSURL * _Nullable outputUrl) {
        NSLog(@"");
    }];
}

#pragma mark - record
- (IBAction)startRecord:(id)sender {
    [self.recorderManager startRecord:nil toPath:[self suggestedFilePath] startHandler:^(NSError * _Nullable error) {
        NSLog(@"startHandler: %@", error);
    }];
}
- (IBAction)pauseRecord:(id)sender {
    [self.recorderManager pause];
}
- (IBAction)resumeRecord:(id)sender {
    [self.recorderManager resume];
}
- (IBAction)stopRecord:(id)sender {
    [self.recorderManager stop];
}

- (NSString *)suggestedFilePath {
    NSString *tmpDir = NSTemporaryDirectory();
//    NSString *tmpDir = [CGHFileManager appTempDirPath:self.delegate.appInfo.appId];
    NSString *fileName = [NSString stringWithFormat:@"tmp_record_%@(%@).wav", NSUUID.UUID.UUIDString, @((long long)NSDate.date.timeIntervalSince1970)];
    NSString *filePath = [tmpDir stringByAppendingPathComponent:fileName];
    return filePath;
}


#pragma mark - audio
- (IBAction)play:(UIButton *)sender {
//    NSString *filePath = [NSBundle.mainBundle pathForResource:@"sing.mp3" ofType:nil];
//    NSString *filePath = self.recorderManager.destPath;
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"merge.wav"];
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        NSLog(@"file not exists：%@", filePath);
        return;
    };
    NSLog(@"%@", filePath);
    
    
    NSString *opStr = [NSString stringWithFormat: @"{\"src\":\"%@\",\"startTime\":0,\"paused\":true,\"currentTime\":0,\"duration\":0,\"obeyMuteSwitch\":true,\"volume\":1,\"autoplay\":false,\"loop\":false,\"buffered\":0,\"timestamp\":1572571926621,\"audioId\":\"1\"}", filePath];
    NSDictionary *op = [opStr jsonValueDecoded];
    
    [self.audioStateManager setAudioState:op];
}

- (IBAction)seek:(UIButton *)sender {
    NSString *opStr = @"{\"timestamp\":1572571926621,\"audioId\":\"1\",\"operationType\":\"play\"}";
    NSDictionary *op = [opStr jsonValueDecoded];
    [self.audioStateManager operateAudio:op callback:^(BOOL isSuccess) {
        ;
    }];
}

- (IBAction)pause:(UIButton *)sender {
    NSDictionary *op = @{};
    [self.audioStateManager operateAudio:op callback:^(BOOL isSuccess) {
        ;
    }];
}

@end
