//
//  CCWebSocket.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/6.
//  Copyright © 2019 lio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGHWebSocketServer : NSObject
- (void)startServer:(short)port;
- (void)stop;
@end
