//
//  CGHSocketClient.m
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import "CGHSocketClient.h"

#include <iostream>
#include "websocket_endpoint.h"

@interface CGHSocketClient()
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong) NSTimer *connectTimer;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) int msgId;
@end

@implementation CGHSocketClient
{
    websocket_endpoint endpoint;
}

- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port
{
    CGHSocketClient *client = [CGHSocketClient new];
    client.host = host;
    client.port = port;
    return client;
}


- (void)connect {
    NSString *url = [NSString stringWithFormat:@"ws://%@:%ld", self.host, (long)self.port];
    endpoint.connect([url UTF8String]);
}

- (void)close {
    endpoint.close(0, websocketpp::close::status::normal, "quit");
}

- (void)sendMessage:(NSString *)text
{
    endpoint.send(0, text.UTF8String);
}

@end
