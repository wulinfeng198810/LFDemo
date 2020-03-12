//
//  CGHDownloadUtil.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/5.
//  Copyright © 2020 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHDownloadUtil : NSObject
+ (NSSet *)getProperties:(Class)clazz;
+ (BOOL)removeItemAtPath:(NSString *)path;
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)destPath error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
