//
//  TestAudioVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/10/8.
//  Copyright © 2019 lio. All rights reserved.
//

#import "TestAudioVC.h"
#import <YYKit.h>
#import "CGHAudioStateManager.h"

@interface TestAudioVC ()
@property (nonatomic, strong) CGHAudioStateManager *audioStateManager;
@end

@implementation TestAudioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioStateManager = [[CGHAudioStateManager alloc] initWithDelegate:nil];
    [self.audioStateManager createAudioInstance:@{@"audioId": @"1"} callback:^(BOOL isSuccess) {
        ;
    }];
}

- (IBAction)play:(UIButton *)sender {
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"bullet.mp3" ofType:nil];
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
