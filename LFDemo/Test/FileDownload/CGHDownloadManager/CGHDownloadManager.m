//
//  CGHDownloadManager.m
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHDownloadManager.h"
#import "YYKitMacro.h"
#import "YYThreadSafeArray.h"
#import "AFURLSessionManager.h"
#import "CGHDownloadUtil.h"
#import "CGHDownloadTask.h"

@interface CGHDownloadManager()
@property (nonatomic, copy) NSString *resumeDataDir;
@property (nonatomic, assign) NSInteger maxConcurrentCount;
@property (nonatomic, strong) YYThreadSafeArray *queue;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@end

@implementation CGHDownloadManager
+ (instancetype)shareManager {
    static CGHDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.resumeDataDir = [manager setupDir];
        manager.maxConcurrentCount = 5;
        manager.queue = [YYThreadSafeArray array];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(applicationWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
    });
    return manager;
}

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionManager.completionQueue = dispatch_queue_create("com.chigua.downloadResumeQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _sessionManager;
}

#pragma mark - applicationWillTerminate
- (void)applicationWillTerminateNotification:(NSNotification *)sender {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    for (CGHDownloadTask *dTask in self.queue) {
        NSURLSessionDownloadTask *task = dTask.task;
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        [self _saveResumeDataWithTask:dTask];
    }
}

- (void)_saveResumeDataWithTask:(CGHDownloadTask *)dTask {
    NSURLSessionDownloadTask *task = dTask.task;
    NSSet *set = [CGHDownloadUtil getProperties:NSClassFromString(@"__NSCFLocalDownloadTask")];
    if (![set containsObject:@"downloadFile"]) return;
    id propertyValue = [task valueForKeyPath:@"downloadFile"];
    set = [CGHDownloadUtil getProperties:[propertyValue class]];
    if (![set containsObject:@"path"]) return;
    NSString *temFilePath = [propertyValue valueForKeyPath:@"path"];
    NSData *resumeData = [self _reCreateResumeDataWithTask:task tmFilePath:temFilePath];
    [dTask cacheResumeData:resumeData];
}

- (NSData *)_reCreateResumeDataWithTask:(NSURLSessionDownloadTask *)task tmFilePath:(NSString *)tmFilePath {
    NSMutableDictionary *resumeDataDict = [NSMutableDictionary dictionary];
    NSMutableURLRequest *newResumeRequest = [task.currentRequest mutableCopy];
    NSData *tmData = [NSData dataWithContentsOfFile:tmFilePath];
    [newResumeRequest addValue:[NSString stringWithFormat:@"bytes=%@-",@(tmData.length)] forHTTPHeaderField:@"Range"];
    [resumeDataDict setObject:newResumeRequest.URL.absoluteString forKey:@"NSURLSessionDownloadURL"];
    NSData *newResumeRequestData = [NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
    NSData *oriData = [NSKeyedArchiver archivedDataWithRootObject:task.originalRequest];
    [resumeDataDict setObject:@(tmData.length) forKey:@"NSURLSessionResumeBytesReceived"];
    [resumeDataDict setObject:newResumeRequestData forKey:@"NSURLSessionResumeCurrentRequest"];
    [resumeDataDict setObject:@(2) forKey:@"NSURLSessionResumeInfoVersion"];
    [resumeDataDict setObject:oriData forKey:@"NSURLSessionResumeOriginalRequest"];
    [resumeDataDict setObject:[tmFilePath lastPathComponent] forKey:@"NSURLSessionResumeInfoTempFileName"];
    return [NSPropertyListSerialization dataWithPropertyList:resumeDataDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
}

#pragma mark - util
- (NSString *)setupDir {
    NSString *downloadDir = [self downloadDir];
    
    NSError *error;
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if (![fileManager fileExistsAtPath:downloadDir] && ![fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        return nil;
    }
    return downloadDir;
}

- (NSString *)downloadDir {
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downloadDir = [document stringByAppendingFormat:@"/comChiguaDownload/resumeDataDir"];
    return downloadDir;
}

- (void)checkMaxConcurrent {
    if (self.queue.count+1 > self.maxConcurrentCount) {
        CGHDownloadTask *lruTask = self.queue.firstObject;
        [lruTask cancel];
    }
}

- (CGHDownloadTask *)isExists:(NSString *)url {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"srcUrl = %@", url];
    CGHDownloadTask *task = [self.queue filteredArrayUsingPredicate:pre].firstObject;
    return task;
}

#pragma mark - public
- (void)download:(NSString *)url toPath:(NSString *)destUrl progress:(CGHLoaderProgressBlock)progressBlock completionHandler:(CGHLoaderCompletedBlock)completionHandler {
    [self checkMaxConcurrent];
    
    CGHDownloadTask *task = [self isExists:url];
    if (!task) {
        task = [[CGHDownloadTask alloc] init];
        [self.queue addObject:task];
        
        @weakify(self);
        task.completionBlock = ^{
            @strongify(self);
            CGHDownloadTask *_task = [self isExists:url];
            if ([self.queue containsObject:_task]) {
                [self.queue removeObject:_task];
            }
        };
    }
    
    [task download:url destUrl:destUrl progress:progressBlock completed:completionHandler];
}

- (BOOL)isTaskRunning:(NSString *)url {
    CGHDownloadTask *task = [self isExists:url];
    return task != nil && task.task != nil && task.task.state == NSURLSessionTaskStateRunning;
}

- (void)cancel:(NSString *)url {
    CGHDownloadTask *task = [self isExists:url];
    [task cancel];
}

- (void)cancelAllTasks {
    for (CGHDownloadTask *task in self.queue) {
        [task cancel];
    }
}

- (void)clear {
    NSError *error;
    NSString *downloadDir = [self downloadDir];
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if ([fileManager fileExistsAtPath:downloadDir] && ![fileManager removeItemAtPath:downloadDir error:&error]) {
    }
}

@end
