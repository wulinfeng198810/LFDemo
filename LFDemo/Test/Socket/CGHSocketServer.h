//
//  CGHSocketServer.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHSocketServer : NSObject
- (instancetype)initWithPort:(NSInteger)port;
- (void)run;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
