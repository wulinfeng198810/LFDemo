//
//  CGHRecorderUtil.h
//  LFDemo
//
//  Created by wulinfeng on 2020/3/27.
//  Copyright © 2020 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHRecorderUtil : NSObject

/// merge multiple audio files
/// the basic logic was derived from here: http://stackoverflow.com/a/16040992/634958
+ (void)mergeAudios:(nonnull NSArray*)urls toPath:(nonnull NSString *)destPath completeHandler:(void(^)(NSError *__nullable error, NSURL *__nullable outputUrl))handler;


/// audio format convert, `.m4a` to `.wav`
+ (void)convetM4aToWav:(nonnull NSString *)srcPath destPath:(nonnull NSString *)destpath completeHandler:(void (^)(NSError *__nullable error))completed;
@end

NS_ASSUME_NONNULL_END
