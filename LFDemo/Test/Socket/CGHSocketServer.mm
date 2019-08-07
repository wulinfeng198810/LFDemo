//
//  CGHSocketServer.m
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import "CGHSocketServer.h"
#include <websocketpp/config/asio_no_tls.hpp>
#import <websocketpp/server.hpp>
#import <cstdio>

typedef websocketpp::server<websocketpp::config::asio> server;

static void on_message(websocketpp::connection_hdl, server::message_ptr msg) {
//    printf("%s", msg->get_payload().c_str());
    NSString *str= [NSString stringWithCString:msg->get_payload().c_str() encoding:[NSString defaultCStringEncoding]];
    NSLog(@"%@", str);
    std::cout << msg->get_payload() << std::endl;
}

@interface CGHSocketServer()

// 保存客户端socket
@property (nonatomic, copy) NSMutableArray *clientSockets;
// 客户端标识和心跳接收时间的字典
@property (nonatomic, copy) NSMutableDictionary *clientPhoneTimeDicts;

@property (nonatomic, assign) NSInteger port;

@end

@implementation CGHSocketServer

- (instancetype)initWithPort:(NSInteger)port
{
    self = [super init];
    if (self) {
        self.port = port;
    }
    return self;
}

- (void)run
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        server webSocketServer;
        
        webSocketServer.set_message_handler(&on_message);
        webSocketServer.set_access_channels(websocketpp::log::alevel::all);
        webSocketServer.set_error_channels(websocketpp::log::elevel::all);
        
        webSocketServer.init_asio();
        webSocketServer.listen(self.port);
        webSocketServer.start_accept();
        
        webSocketServer.run();
    });
}

- (void)stop {
    
}

// socket是保存的客户端socket, 表示给客户端socket发送消息
- (void)sendMessage:(NSString *)text {
    
}

#pragma mark - Lazy Load
- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}

@end
