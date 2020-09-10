//
//  CGHWebSocketManager.m
//  LFDemo
//
//  Created by wulinfeng on 2020/4/24.
//  Copyright © 2020 lio. All rights reserved.
//

#import "CGHWebSocketManager.h"
#import "SRWebSocket.h"

@interface CGHWebSocketManager() <SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;
@end

@implementation CGHWebSocketManager

- (void)connectServer:(NSString *)server port:(NSString *)port
{
    [self connect:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%@",server,port]]];
}

- (void)connect:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _socket = [[SRWebSocket alloc] initWithURLRequest:request];
    _socket.delegate = self;
}

- (void)open {
    [_socket open];
}

- (void)close {
    [_socket close];
}

// Send a UTF8 String or Data.
- (void)send:(id)data {
    [_socket send:data];
}

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data {
    [_socket sendPing:data];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"%s %@", __func__, message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"%s %@", __func__, webSocket);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%s %@", __func__, error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"%s %@", __func__, reason);
}

@end
