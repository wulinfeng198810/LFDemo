
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHRecorder : NSObject
@property (readonly) AVAudioRecorder *recorder;

- (void)startRecordToPath:(NSString *)destPath completeHandler:(nonnull void (^)(NSError *__nullable error, NSDictionary *__nullable info))completeHandler;

- (void)startRecord:(nullable NSDictionary *)setting duration:(NSInteger)duration toPath:(nonnull NSString *)destPath startHandler:(nullable void (^)(NSError *__nullable error))startHandler interruptionHandler:(nullable void (^)(CGHRecorder *__nullable record, NSDictionary *__nullable interruptionInfo))interruptionHandler completeHandler:(nullable void (^)(NSError *__nullable error, NSDictionary *__nullable info))completeHandler;

- (BOOL)pause;

- (BOOL)resume;

- (BOOL)stop;

- (NSDictionary *)recordFileInfo:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
