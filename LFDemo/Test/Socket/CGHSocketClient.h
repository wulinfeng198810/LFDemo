//
//  CGHSocketClient.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHSocketClient : NSObject
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port;
- (void)connect;
- (void)close;
- (void)sendMessage:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
