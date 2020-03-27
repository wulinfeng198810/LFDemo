#import "CGHBaseModuleManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGHRecorderManager : CGHBaseModuleManager
@property (readonly) NSString *destPath; //wav
@property (readonly) BOOL isRecording;

- (void)startRecord:(nullable NSDictionary *)setting toPath:(NSString *)destPath startHandler:(void(^)(NSError *_Nullable error))startHandler;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)stop;

- (void)startRecord:(NSString *)destPath completeHandler:(void (^)(NSError *error, NSString *tmpFilePath))completeHandler;
- (BOOL)stopRecord;

@end

NS_ASSUME_NONNULL_END
