//
//  CGHWebSocketManager.h
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

typedef NS_ENUM(NSUInteger,WebSocketConnectType){
    WebSocketDefault = 0, //初始状态,未连接
    WebSocketConnect,      //已连接
    WebSocketDisconnect    //连接后断开
};

@protocol WebSocketManagerDelegate <NSObject>
- (void)webSocketManagerDidReceiveMessageWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_BEGIN
@interface CGHWebSocketManager : NSObject
@property (nonatomic, strong) SRWebSocket *webSocket;
@property(nonatomic,weak)  id<WebSocketManagerDelegate > delegate;
@property (nonatomic, assign)   BOOL isConnect;  //是否连接
@property (nonatomic, assign)   WebSocketConnectType connectType;
+(instancetype)shared;
- (void)connectServer:(NSString *)url;//建立长连接
- (void)reConnectServer;//重新连接
- (void)RMWebSocketClose;//关闭长连接
- (void)sendDataToServer:(NSString *)data;//发送数据给服务器
@end
NS_ASSUME_NONNULL_END
