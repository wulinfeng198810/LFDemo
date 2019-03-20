//
//  DYCircleCacheHelper.h
//  LFDemo
//
//  Created by wlf on 2019/2/15.
//  Copyright © 2019 lio. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString * const kCacheStatisticsAppClass = @"com.dianyou.gamecenter.cacheStatisticsAppClass"; /**< 吃瓜课堂统计 id 缓存 */
static NSString * const kCacheStatisticsAppClassID = @"kCacheStatisticsAppClassID"; /**< 吃瓜课堂统计 id 缓存 */
NS_ASSUME_NONNULL_BEGIN

@interface DYCircleCacheHelper : NSObject
+ (BOOL)cacheStatisticsAppClassID:(NSString *)ID;
@end

NS_ASSUME_NONNULL_END
