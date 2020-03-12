//
//  CGHDownloadManager.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CGHLoaderProgressBlock)(int64_t totalUnitCount, int64_t completedUnitCount);
typedef void(^CGHLoaderCompletedBlock)(NSURL *filePath, NSError * error);

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

@interface CGHDownloadManager : NSObject

+ (instancetype)shareManager;

- (void)download:(NSString *)url
          toPath:(NSString *)destUrl
        progress:(CGHLoaderProgressBlock)progressBlock
completionHandler:(CGHLoaderCompletedBlock)completionHandler;

- (BOOL)isTaskRunning:(NSString *)url;

- (void)cancel:(NSString *)url;

- (void)cancelAllTasks;

@end
