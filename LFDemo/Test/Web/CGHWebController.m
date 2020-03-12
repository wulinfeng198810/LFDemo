//
//  CGHWebController.m
//  LFDemo
//
//  Created by wulinfeng on 2019/9/19.
//  Copyright © 2019 lio. All rights reserved.
//

#import "CGHWebController.h"
#import <YYKit.h>
#import <WebKit/WebKit.h>
@interface CGHWebController ()<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webview;
@end

@implementation CGHWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (void)testBtn:(UIButton *)sender {
    [sender removeFromSuperview];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *fileEncodePath = [htmlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *fileURL = [NSURL fileURLWithPath:fileEncodePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    
    self.webview = [[WKWebView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 200}];
    [self.view addSubview:self.webview];
    
    NSString *injectClientId = [@"var cg_oauth_client_id = " stringByAppendingString:@"'asdasdf'"];
    [self.webview evaluateJavaScript:injectClientId completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        !error ?: NSLog(@"inject window.cg_oauth_client_id error");
    }];
    
    [self.webview loadRequest:request];
    self.webview.navigationDelegate = self;
}

- (void)backBtn:(UIButton *)sender {
//    [CGHWebManager sharedInstance].web = self;
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
}

@end
