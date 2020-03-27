
#import "CGHRecorderManager.h"
#import "YYKitMacro.h"
#import "CGHRecorder.h"
//#import "CGHFileManager.h"

@interface CGHRecorderManager() <AVAudioRecorderDelegate>
@property (nonatomic, copy) NSString *destPath;
@property (nonatomic, strong) CGHRecorder *recorder;
@end

@implementation CGHRecorderManager

- (BOOL)isRecording {
    return self.recorder != nil;
}

- (void)startRecord:(NSDictionary *)setting toPath:(nonnull NSString *)destPath startHandler:(nonnull void (^)(NSError * _Nullable))startHandler {
    if (self.recorder) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"is recording"}];
        !startHandler ?: startHandler(error);
        return;
    }
    self.destPath = destPath;
    
    NSInteger duration = [setting[@"duration"] integerValue];
    if (duration <= 0) duration = 60000;
    duration = MIN(600000, duration)/1000;
    
    __block BOOL initRecorderSuccess = NO;
    @weakify(self);
    self.recorder = CGHRecorder.new;
    [self.recorder startRecord:nil duration:duration toPath:self.destPath startHandler:^(NSError *error) {
        NSLog(@"~~~ startHandler error:%@", error);
        @strongify(self);
        initRecorderSuccess = error == nil;
        !startHandler ?: startHandler(error);
        if (!error) [self onRecorderStateChange:@"start"];
        
    } interruptionHandler:^(CGHRecorder *record, NSDictionary *interruptionInfo) {
        NSLog(@"~~~ interruptionHandler record:%@, info:%@", record, interruptionInfo);
        @strongify(self);
        AVAudioSessionInterruptionType type = [interruptionInfo[AVAudioSessionInterruptionTypeKey] integerValue];
        if (type == AVAudioSessionInterruptionTypeBegan) {
            [self onRecorderStateChange:@"interruptionBegin"];
            [self onRecorderStateChange:@"pause"];
        } else {
            [self onRecorderStateChange:@"interruptionEnd"];
        }
        
    } completeHandler:^(NSError *error, NSDictionary *info) {
        NSLog(@"~~~ completeHandler error:%@, info:%@", error, info);
        @strongify(self);
        if (initRecorderSuccess) {
            if (info) {
                [self onRecorderStateChangeStop:info];
            } else {
                [self onRecorderStateChangeError:nil];
            }
        }
        self.recorder = nil;
    }];
}

- (BOOL)pause {
    BOOL ret = [self.recorder pause];
    if (ret) {
        [self onRecorderStateChange:@"pause"];
    }
    return ret;
}

- (BOOL)resume {
    BOOL ret = [self.recorder resume];
    return ret;
}

- (BOOL)stop {
    BOOL ret = [self.recorder stop];
    if (ret) {
        //-startRecordHandler 已处理
    }
    return ret;
}

- (void)startRecord:(NSString *)destPath completeHandler:(void (^)(NSError *, NSString *))completeHandler {
    if (self.recorder) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"is recording"}];
        !completeHandler ?: completeHandler(error, nil);
        return;
    }
    self.destPath = destPath;
    
    @weakify(self);
    self.recorder = CGHRecorder.new;
    [self.recorder startRecordToPath:destPath completeHandler:^(NSError * _Nullable error, NSDictionary * _Nullable info) {
        @strongify(self);
        !completeHandler ?: completeHandler(error, info[@"tempFilePath"]);
        self.recorder = nil;
    }];
}

- (BOOL)stopRecord {
    return [self.recorder stop];
}

#pragma mark - APPSERVICE_ON_EVENT
- (void)onRecorderStateChange:(NSString *)state {
    NSDictionary *data = @{@"state": state};
    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onRecorderStateChange" data:data];
}

- (void)onRecorderStateChangeStop:(NSDictionary *)info {
    NSMutableDictionary *mDict = info.mutableCopy;
    mDict[@"state"] = @"stop";
    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onRecorderStateChange" data:mDict];
}

- (void)onRecorderStateChangeError:(NSError *)error {
    NSDictionary *data =
  @{@"state": @"error",
    @"errMsg": @"MediaError",
    @"errCode": @10004
  };
    [self.delegate.appServiceOnEventDispatcher APPSERVICE_ON_EVENT:@"onRecorderStateChange" data:data];
}

@end


