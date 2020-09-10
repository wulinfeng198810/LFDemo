//
//  CGHWebSocketManager.h
//  LFDemo
//
//  Created by wulinfeng on 2020/4/24.
//  Copyright © 2020 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGHWebSocketManager : NSObject
- (void)connectServer:(NSString *)server port:(NSString *)port;
- (void)connect:(NSURL *)url;

- (void)open;

- (void)close;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
