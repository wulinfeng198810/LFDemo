//
//  CGHDownloadTask.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGHDownloadManager.h"
#import "YYKitMacro.h"

@interface CGHDownloadTask : NSObject
@property (nonatomic, copy) void (^completionBlock)(void);
@property (readonly) NSString *srcUrl;
@property (readonly) NSString *destUrl;
@property (readonly) NSURLSessionDownloadTask *task;

- (void)download:(NSString *)srcUrl destUrl:(NSString *)destUrl progress:(CGHLoaderProgressBlock)progressBlock completed:(CGHLoaderCompletedBlock)completedBlock;
- (void)cancel;
- (void)cancel:(void(^)(void))completionHandler;
- (BOOL)cacheResumeData:(NSData *)resumeData;
@end
