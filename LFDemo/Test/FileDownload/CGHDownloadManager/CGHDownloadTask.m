//
//  CGHDownloadTask.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHDownloadTask.h"
#import "CGHDownloadUtil.h"
#import <YYKit.h>
#import "AFURLSessionManager.h"

typedef NSMutableDictionary<NSString *, id> CGHCallbacksDictionary;
static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface CGHDownloadTask()
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, copy) NSString *srcUrl;
@property (nonatomic, copy) NSString *destUrl;
@property (nonatomic, copy) NSString *resumeDataDir;
@property (nonatomic, weak) AFURLSessionManager *manager;
@property (strong, nonatomic) NSMutableArray<CGHCallbacksDictionary *> *callbackBlocks;
@end

@implementation CGHDownloadTask

- (instancetype)init {
    self = [super init];
    if (self) {
        _callbackBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)download:(NSString *)srcUrl destUrl:(NSString *)destUrl progress:(CGHLoaderProgressBlock)progressBlock completed:(CGHLoaderCompletedBlock)completedBlock {
    self.srcUrl = srcUrl;
    self.destUrl = destUrl;
    if (!self.resumeDataDir) {
        self.resumeDataDir = [[CGHDownloadManager shareManager] valueForKey:@"resumeDataDir"];
    }
    if (!self.manager) {
        self.manager = [[CGHDownloadManager shareManager] valueForKey:@"sessionManager"];
    }
    
    //callbacks
    [self addHandlersForProgress:progressBlock completed:completedBlock];
    
    //task
    if ([[CGHDownloadManager shareManager] isTaskRunning:srcUrl]) { return; }
    [self _resumeByManager:self.manager];
}

- (id)addHandlersForProgress:(CGHLoaderProgressBlock)progressBlock
                   completed:(CGHLoaderCompletedBlock)completedBlock {
    CGHCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
    @synchronized (self) {
        [self.callbackBlocks addObject:callbacks];
    }
    return callbacks;
}

- (NSArray<id> *)callbacksForKey:(NSString *)key {
    NSMutableArray<id> *callbacks;
    @synchronized (self) {
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    }
    // We need to remove [NSNull null] because there might not always be a progress block for each callback
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy]; // strip mutability here
}

- (void)_resumeByManager:(AFURLSessionManager *)manager {
    if (!manager) {
        NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"session is nil"}];
        [self _completionHandler:nil filePath:nil error:error];
        return;
    }
    
    NSString *resumeDataPath = [self _resumeDataCachePath];
    NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
    NSURLSessionDownloadTask *downloadTask;
    if (resumeData) {
        @weakify(self);
        downloadTask = [manager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            @strongify(self);
            [self callProgressBlocksWithTotalUnitCount:downloadProgress.totalUnitCount completedUnitCount:downloadProgress.completedUnitCount];
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            @strongify(self);
            return [self _destination:targetPath response:response];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            @strongify(self);
            [self _completionHandler:response filePath:filePath error:error];
        }];
        
    } else {
        NSURL *URL = [NSURL URLWithString:self.srcUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        @weakify(self);
        downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            @strongify(self);
            [self callProgressBlocksWithTotalUnitCount:downloadProgress.totalUnitCount completedUnitCount:downloadProgress.completedUnitCount];
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            @strongify(self);
            return [self _destination:targetPath response:response];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            @strongify(self);
            [self _completionHandler:response filePath:filePath error:error];
        }];
    }
    [downloadTask resume];
    self.task = downloadTask;
    
    [self callProgressBlocksWithTotalUnitCount:NSURLResponseUnknownLength completedUnitCount:0];
}

- (void)cancel:(void (^)(void))completionHandler {
    @weakify(self);
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        @strongify(self);
        [self cacheResumeData:resumeData];
        !completionHandler ?: completionHandler();
    }];
}

- (void)cancel {
    [self cancel:nil];
}

#pragma mark - callback
- (NSURL *)_destination:(NSURL *)targetPath response:(NSURLResponse *)response {
    NSURL *dir = [NSURL fileURLWithPath:self.resumeDataDir];
    return [dir URLByAppendingPathComponent:[response suggestedFilename]];
}

- (void)_completionHandler:(NSURLResponse *)response filePath:(NSURL *)filePath error:(NSError *)error {
    if (error) {
        NSInteger errorCode = error.code;
        if (errorCode == NSURLErrorCancelled) {
            [self callCompletionBlocksWithFilePath:nil error:error];
            return;
        }
        
        if ([self shouldCacheResumDataWithError:error]) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            [self cacheResumeData:resumeData];
        } else {
            [self _removeCacheResumeData];
        }
        [self callCompletionBlocksWithFilePath:nil error:error];
        return;
    }
    
    [self _removeCacheResumeData];
    
    // move file to destination
    NSError *_error;
    if (![CGHDownloadUtil moveItemAtPath:filePath.path toPath:self.destUrl error:&_error]) {
        [self callCompletionBlocksWithFilePath:nil error:_error];
        return;
    }
    
    [self callCompletionBlocksWithFilePath:filePath error:nil];
}

- (void)callCompletionBlocksWithError:(NSError *)error {
    [self callCompletionBlocksWithFilePath:nil error:error];
}

- (void)callProgressBlocksWithTotalUnitCount:(int64_t)totalUnitCount completedUnitCount:(int64_t)completedUnitCount {
    NSArray<id> *progressBlocks = [self callbacksForKey:kProgressCallbackKey];
    dispatch_main_async_safe(^{
        for (CGHLoaderProgressBlock progressBlock in progressBlocks) {
            progressBlock(totalUnitCount, completedUnitCount);
        }
    });
}

- (void)callCompletionBlocksWithFilePath:(NSURL *)filePath error:(NSError *)error {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_async_safe(^{
        for (CGHLoaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(filePath, error);
        }
    });
    
    !self.completionBlock ?: self.completionBlock();
}

- (BOOL)shouldCacheResumDataWithError:(NSError *)error {
    BOOL shouldCacheResumData = NO;
    // Filter the error domain and check error codes
    NSInteger code = error.code;
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        shouldCacheResumData = (   code == NSURLErrorNotConnectedToInternet
                                //|| code != NSURLErrorCancelled //cancel handled by `NSURLSessionDownloadTask -cancelByProducingResumeData:`
                                || code == NSURLErrorTimedOut
                                || code == NSURLErrorInternationalRoamingOff
                                || code == NSURLErrorDataNotAllowed
                                || code == NSURLErrorCannotFindHost
                                || code == NSURLErrorCannotConnectToHost
                                || code == NSURLErrorNetworkConnectionLost);
    }
    return shouldCacheResumData;
}

#pragma mark - file util
- (BOOL)cacheResumeData:(NSData *)resumeData {
    if (!resumeData || resumeData.length == 0) {
        NSLog(@"resumeData is nil");
        return NO;
    }
    NSLog(@"resumeData: %@", @(resumeData.length));
    
    NSString *resumeDataPath = [self _resumeDataCachePath];
    if (![CGHDownloadUtil removeItemAtPath:resumeDataPath]) {
        return NO;
    }
    BOOL ret = [resumeData writeToFile:resumeDataPath atomically:YES];
    return ret;
}

- (BOOL)_removeCacheResumeData {
    NSString *resumeDataPath = [self _resumeDataCachePath];
    if (![CGHDownloadUtil removeItemAtPath:resumeDataPath]) {
        return NO;
    }
    return YES;
}

- (NSString *)_resumeDataCachePath {
    NSString *sourcePath = self.srcUrl;
    NSString *resumeDataPath = [self.resumeDataDir stringByAppendingFormat:@"/%@_resumeData", sourcePath.lastPathComponent.stringByDeletingPathExtension];
    return resumeDataPath;
}

@end

