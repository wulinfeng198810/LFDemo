//
//  CGHSocketTestVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/8/5.
//  Copyright © 2019 lio. All rights reserved.
//

#import "CGHSocketTestVC.h"
#import <YYKit.h>
#include "CCWebSocket.h"
#import "CGHSocketClient.h"

@interface CGHSocketTestVC ()
@property (nonatomic, strong) CGHWebSocketServer *server;
@property (nonatomic, strong) CGHSocketClient *socketClient;
@end

@implementation CGHSocketTestVC

- (void)dealloc {
    NSLog(@"CGHSocketTestVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)startServer:(id)sender {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        self.server = [[CGHWebSocketServer alloc] init];
        [self.server startServer:9002];
    });
}

- (IBAction)serverSendMsg {
}

- (IBAction)socketClient:(id)sender {
    self.socketClient = [[CGHSocketClient alloc] initWithHost:@"localhost" port:9002];
    [self.socketClient connect];
}
- (IBAction)socketSendMsg:(id)sender {
    [self.socketClient sendMessage:@"login"];
}

- (IBAction)webSocketClient:(id)sender {
    [self.server stop];
}

- (IBAction)webSendMsg:(id)sender {
    [self.socketClient close];
}


@end
