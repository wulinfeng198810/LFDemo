//
//  DYCircleCacheHelper.m
//  LFDemo
//
//  Created by wlf on 2019/2/15.
//  Copyright © 2019 lio. All rights reserved.
//

#import "DYCircleCacheHelper.h"
#import <YYKit.h>



@implementation DYCircleCacheHelper

+ (void)cacheStatisticsAppClassConfig:(YYCache *)yyCache {
    //YYCache *yyCache = [YYCache cacheWithName:kCacheStatisticsAppClass];
//    [yyCache.memoryCache setCountLimit:10];//内存最大缓存数据个数
//    [yyCache.memoryCache setAutoTrimInterval:10];
//    [yyCache.memoryCache setCostLimit:1*1024];//内存最大缓存开销 目前这个毫无用处
//    [yyCache.diskCache setCostLimit:1*1024];//磁盘最大缓存开销
//    [yyCache.diskCache setCountLimit:10];//磁盘最大缓存数据个数
//    [yyCache.diskCache setAutoTrimInterval:10];//设置磁盘lru动态清理频率 默认 60秒
    
    yyCache.memoryCache.ageLimit = 5;
    yyCache.diskCache.ageLimit = 5;
}

static NSString * const kLastTimeKey = @"lastTimeKey";

+ (BOOL)cacheStatisticsAppClassID:(NSString *)ID {
    if (!ID) { return NO; }
//    YYCache *yyCache = [YYCache cacheWithName:kCacheStatisticsAppClass];
//    [self cacheStatisticsAppClassConfig:yyCache];
//    BOOL isContains = [yyCache containsObjectForKey:kCacheStatisticsAppClassID];
//    NSMutableArray *mArr;
//    if (isContains) {
//        NSArray *arr = (NSArray *)[yyCache objectForKey:kCacheStatisticsAppClassID];
//        mArr = [arr mutableCopy];
//    } else {
//        mArr = @[].mutableCopy;
//    }
//    NSLog(@"-------");
//    for (NSString *ID in mArr) {
//        NSLog(@"%@", ID);
//    }
//    if ([mArr containsObject:ID]) {
//        return NO;
//    } else {
//        [mArr addObject:ID];
//    }
//
//    [yyCache setObject:mArr.copy forKey:kCacheStatisticsAppClassID];
//
//    NSLog(@"++++++++");
//    for (NSString *ID in mArr) {
//        NSLog(@"%@", ID);
//    }
//    return YES;
    
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval offsetTime = 6*60*60;
//    NSTimeInterval offsetTime = 5;
    NSUserDefaults *usd = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [usd objectForKey:kCacheStatisticsAppClass];
    if (!dict) {
        dict = @{};
    }
    NSMutableDictionary *mDict = dict.mutableCopy;
    
    
    CGFloat time = [dict[ID] floatValue];
    if (time != 0) { //已存在
        if (curTime - time > offsetTime) { //超过一天
            mDict[ID] = @(curTime);
        } else {
            return NO;
        }
        
    } else { //
        mDict[ID] = @(curTime);
    }
    
    [usd setObject:mDict forKey:kCacheStatisticsAppClass];
    return YES;
}

@end
