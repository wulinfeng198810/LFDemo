//
//  SocketWebVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/8/7.
//  Copyright © 2019 lio. All rights reserved.
//

#import "SocketWebVC.h"
#import <WebKit/WebKit.h>

@interface SocketWebVC ()
@property (weak, nonatomic) IBOutlet WKWebView *webview;

@end

@implementation SocketWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *bundleStr = [[NSBundle mainBundle] pathForResource:@"feedback" ofType:@"html"];
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
