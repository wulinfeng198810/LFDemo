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
@interface CGHWebController ()<WKNavigationDelegate, WKUIDelegate>
@property (strong, nonatomic) WKWebView *webview;
@end

@implementation CGHWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    
//    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
//    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
//    testBtn.backgroundColor = UIColor.redColor;
//    [testBtn addTarget:self action:@selector(testBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testBtn];
    
    [self testBtn:nil];
}

- (void)testBtn:(UIButton *)sender {
    [sender removeFromSuperview];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSString *fileEncodePath = [htmlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *fileURL = [NSURL fileURLWithPath:fileEncodePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    
    self.webview = [[WKWebView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kScreenHeight}];
    self.webview.scrollView.backgroundColor = UIColor.blueColor;
    
    
    [self.webview evaluateJavaScript:@"document.body.style.backgroundColor=\"#0000FF\"" completionHandler:nil];
    [self.view addSubview:self.webview];
    
    NSString *injectClientId = [@"var cg_oauth_client_id = " stringByAppendingString:@"'asdasdf'"];
    [self.webview evaluateJavaScript:injectClientId completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        !error ?: NSLog(@"inject window.cg_oauth_client_id error");
    }];
//    [self.webview loadRequest:request];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    
}

- (void)backBtn:(UIButton *)sender {
//    [CGHWebManager sharedInstance].web = self;
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
}

// JS端调用prompt函数时，会触发此代理方法。
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSError *err = nil;
    NSData *dataFromString = [prompt dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:dataFromString options:NSJSONReadingMutableContainers error:&err];
    if (!err)
    {
        NSString *type = [payload objectForKey:@"type"];
        if (type && [type isEqualToString:@"JSbridge"])
        {
            NSString *returnValue = @"";
            NSString *functionName = [payload objectForKey:@"functionName"];
            NSDictionary *args = [payload objectForKey:@"arguments"];
            if ([functionName isEqualToString:@"OC_Fun_05"])
            {
                returnValue = [self OC_Fun_05:args];
            }
            else if ([functionName isEqualToString:@"OC_Fun_06"])
            {
                returnValue = [self OC_Fun_06:args];
            }
            
            completionHandler(returnValue);
        }
    } else {
        completionHandler(nil);
    }
}

- (NSString *)OC_Fun_05:(NSDictionary *)args
{
    return @"Fun:OC_Fun_05";
}
- (NSString *)OC_Fun_06:(NSDictionary *)args
{
    return @"Fun:OC_Fun_06";
}

@end
