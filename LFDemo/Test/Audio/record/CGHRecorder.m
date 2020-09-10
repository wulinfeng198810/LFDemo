
#import "CGHRecorder.h"
#import "YYKitMacro.h"
#import "YYTimer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CGHRecorderUtil.h"

@interface CGHRecorder()<AVAudioRecorderDelegate>
@property (nonatomic, copy) NSString *destPath;
@property (nonatomic, copy) NSDictionary *setting;
@property (nonatomic, strong) YYTimer *timer;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) NSInteger totalTime;
@property (nonatomic, assign) NSInteger leftRecordTime;
@property (nonatomic, assign) BOOL interrupt;
@property (nonatomic, assign) BOOL interruptAutoResume;
@property (nonatomic, copy) NSString *tempDir;
@property (nonatomic, assign) int tag;
@property (nonatomic, strong) NSMutableArray *interruptionRecordings;
@property (nonatomic, copy) void (^completeHandler)(NSError *error, NSDictionary *info);
@property (nonatomic, copy) void (^interruptionHandler)(CGHRecorder *record, NSDictionary *interruptionInfo);
@end

@implementation CGHRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *randomDir = [NSString stringWithFormat:@"tmp_record_%@(%@)", NSUUID.UUID.UUIDString, @((long long)NSDate.date.timeIntervalSince1970)];
        self.tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:randomDir];
        self.tag = 1;
    }
    return self;
}

- (void)startRecordToPath:(NSString *)destPath completeHandler:(void (^)(NSError *error, NSDictionary *info))completeHandler {
    self.interruptAutoResume = YES;
    [self startRecord:nil duration:60 toPath:destPath startHandler:nil interruptionHandler:nil completeHandler:completeHandler];
}

- (void)startRecord:(NSDictionary *)setting duration:(NSInteger)duration toPath:(NSString *)destPath startHandler:(void (^)(NSError * _Nullable))startHandler interruptionHandler:(void (^)(CGHRecorder * _Nullable, NSDictionary * _Nullable))interruptionHandler completeHandler:(void (^)(NSError * _Nullable, NSDictionary * _Nullable))completeHandler {
    if (self.recorder) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"is recording"}];
        !startHandler ?: startHandler(error);
        !completeHandler ?: completeHandler(error, nil);
        return;
    }
    
    self.destPath = destPath;
    self.setting = setting ?: [self defaultSettings];
    self.completeHandler = completeHandler;
    self.interruptionHandler = interruptionHandler;
    self.totalTime = duration;
    self.leftRecordTime = duration;
    @weakify(self);
    [self _checkGrantOfRecord:^(BOOL granted) {
        @strongify(self);
        if (!granted) {
            NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"no granted for recorder"}];
            NSLog(@"record error: %@", error);
            !startHandler ?: startHandler(error);
            !completeHandler ?: completeHandler(error, nil);
            return;
        }
        
        NSError *error;
        AVAudioRecorder *recorder = [self _startAudioRecord:self.setting duration:self.leftRecordTime toPath:[self suggestedFilePath] error:&error];
        if (!recorder) {
            NSLog(@"record init error: %@", error);
            !startHandler ?: startHandler(error);
            !completeHandler ?: completeHandler(error, nil);
            return;
        }
        
        self.recorder = recorder;
        [self observerAVAudioSessionInterruption];
        self.timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(metering) repeats:YES];
        !startHandler ?: startHandler(nil);
    }];
}

- (BOOL)pause {
    if (self.recorder && self.recorder.isRecording) {
        [self.recorder pause];
        return YES;
    }
    return NO;
}

- (BOOL)resume {
    if (self.interrupt) {
        return [self interruptResume];
    }
    
    if (self.recorder && !self.recorder.isRecording) {
        BOOL ret = [self.recorder record];
        return ret;
    }
    return NO;
}

- (BOOL)stop {
    if(self.recorder) {
        [self.recorder stop];
        return YES;
    }
    if (self.interrupt) {
        [self _stop];
        return YES;
    }
    return NO;
}

- (NSDictionary *)recordFileInfo:(NSString *)filePath {
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    unsigned long audioDuration = (unsigned long)CMTimeGetSeconds(audioAsset.duration);
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil].fileSize;
    NSDictionary *info = @{@"tempFilePath":filePath, @"fileSize":@(fileSize), @"duration":@(audioDuration)};
    return info;
}

- (void)_checkGrantOfRecord:(void(^)(BOOL granted))completionHandler {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        completionHandler(granted);
    }];
}

- (AVAudioRecorder *)_startAudioRecord:(NSDictionary *)setting duration:(NSInteger)duration toPath:(NSString *)destPath error:(NSError **)error {
    NSError *_err;
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if (!destPath || [fileManager fileExistsAtPath:destPath]) {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"destPath is nil or file exists"}];
        return nil;
    }
    if (![fileManager fileExistsAtPath:destPath.stringByDeletingLastPathComponent] && ![fileManager createDirectoryAtPath:destPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:&_err]) {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"mkdir fail"}];
        return nil;
    }
    
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:destPath] settings:setting error:&_err];
    if (_err) {
        *error = _err;
        return nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&_err];
    if (_err) {
        *error = _err;
        return nil;
    }
    [audioSession setActive:YES error:&_err];
    if (_err) {
        *error = _err;
        return nil;
    }
    recorder.delegate = self; 
    recorder.meteringEnabled = YES;
    
    
    BOOL prepare = [recorder prepareToRecord];
    if (!prepare) {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"prepareToRecord error"}];
        return nil;
    }
    
    BOOL startRecord = [recorder recordForDuration:duration];
    if (!startRecord) {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"startRecord error"}];
        return nil;
    }
    return recorder;
}

- (BOOL)interruptResume {
    self.interrupt = NO;
    NSError *error;
    self.tag++;
    AVAudioRecorder *recorder = [self _startAudioRecord:self.setting duration:self.leftRecordTime toPath:[self suggestedFilePath] error:&error];
    if (recorder) {
        self.recorder = recorder;
        return YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSFileManager.defaultManager removeItemAtPath:self.tempDir error:nil];
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"interrupt resume fail"}];
        !self.completeHandler ?: self.completeHandler(error, nil);
        [self _releaseRecorder];
    });
    return NO;
}

- (NSString *)suggestedFilePath {
    NSString *fileName = [NSString stringWithFormat:@"%d.wav", self.tag];
    NSString *filePath = [self.tempDir stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)metering {
    if (self.recorder.isRecording) [self.recorder updateMeters];
    double volume = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    NSLog(@"isRecording:%d volume:%.2f", self.recorder.isRecording, volume);
}

- (NSDictionary *)defaultSettings {
//    NSDictionary *defaultSettings =
//    @{AVFormatIDKey:@(kAudioFormatMPEG4AAC),
//      AVSampleRateKey:@16000,
//      AVNumberOfChannelsKey:@1,
//      AVEncoderBitDepthHintKey:@16,
//      AVEncoderAudioQualityKey:@(AVAudioQualityMin)
//    };
    NSMutableDictionary *defaultSettings = @{}.mutableCopy;
    defaultSettings[AVFormatIDKey] = @(kAudioFormatLinearPCM);
        defaultSettings[AVSampleRateKey] = @16000;
    //    recordSetting[AVNumberOfChannelsKey] = @2;
        defaultSettings[AVNumberOfChannelsKey] = @1;
        // Linear PCM Format Settings
        defaultSettings[AVLinearPCMBitDepthKey] = @16;
        defaultSettings[AVLinearPCMIsBigEndianKey] = @NO;
        defaultSettings[AVLinearPCMIsFloatKey] = @NO;
        // Encoder Settings
        defaultSettings[AVEncoderAudioQualityKey] = @(AVAudioQualityMedium);
        defaultSettings[AVEncoderBitRateKey] = @128000;
    return defaultSettings.mutableCopy;
}

- (void)_releaseRecorder {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [audioSession setActive:YES error:NULL];
    
    [self.timer invalidate];
    self.timer = nil;
    self.recorder = nil;
    self.completeHandler = nil;
    self.interruptionHandler = nil;
    [self removeObserver];
}

#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"%s: %@, flag:%d", __func__, recorder.url.path, flag);
    if (!flag) {
        [recorder deleteRecording];
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"record fail"}];
        !self.completeHandler ?: self.completeHandler(error, nil);
        [self _releaseRecorder];
        return;
    }
    
    NSString *filePath = recorder.url.path;
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    unsigned long audioDuration = (unsigned long)CMTimeGetSeconds(audioAsset.duration);
    if (!self.interruptionRecordings) {
        self.interruptionRecordings = @[].mutableCopy;
    }
    if (audioDuration > 0) {
        self.leftRecordTime = self.leftRecordTime - audioDuration;
        NSLog(@"leftRecordTime: %d", self.leftRecordTime);
        [self.interruptionRecordings addObject:filePath];
    } else {
        [self _stop];
        return;
    }
    
    //after interruption may 'resume'
    if (self.interrupt) return;
    
    [self _stop];
}

- (void)_stop {
    @weakify(self);
    [self _mergeAudios:self.interruptionRecordings converToWavPath:self.destPath completeHandler:^(NSError *error) {
        @strongify(self);
        if (error) {
            !self.completeHandler ?: self.completeHandler(error, nil);
        } else {
            NSDictionary *info = [self recordFileInfo:self.destPath];
            !self.completeHandler ?: self.completeHandler(nil, info);
        }
        [self _releaseRecorder];
    }];
}

- (void)_mergeAudios:(NSArray *)filePaths converToWavPath:(NSString *)wavPath completeHandler:(void (^)(NSError *error))completeHandler {
    if (filePaths.count == 0) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"mergeAudios count is 0"}];
        !completeHandler ?: completeHandler(error);
        return;
    }
    
    if (filePaths.count == 1) {
        [CGHRecorderUtil convetM4aToWav:filePaths.firstObject destPath:wavPath completeHandler:^(NSError * _Nonnull error) {
            !completeHandler ?: completeHandler(error);
        }];
        return;
    }
    
    NSString *mergePath = [self.tempDir stringByAppendingPathComponent:@"merge.wav"];
    [CGHRecorderUtil mergeAudios:filePaths toPath:mergePath completeHandler:^(NSError * _Nonnull error, NSURL * _Nonnull outputUrl) {
        if (error) {
            !completeHandler ?: completeHandler(error);
            return;
        }
        [CGHRecorderUtil convetM4aToWav:outputUrl.path destPath:wavPath completeHandler:^(NSError * _Nonnull error) {
            !completeHandler ?: completeHandler(error);
        }];
    }];
}

#pragma mark - observer
- (void)observerAVAudioSessionInterruption {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interrupt:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)interrupt:(NSNotification *)noti {
    AVAudioSessionInterruptionType type = [noti.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        self.interrupt = YES;
        [self.recorder stop];
        
    } else {
        if (self.interruptAutoResume) {
            [self interruptResume];
        }
    }
    
    !self.interruptionHandler ?: self.interruptionHandler(self, noti.userInfo);
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
