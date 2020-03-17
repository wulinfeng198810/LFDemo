//
//  JSContextTestVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/10/31.
//  Copyright © 2019 lio. All rights reserved.
//

#import "JSContextTestVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "CGHDownloadUtil.h"
#import "CGHJSTimer.h"

@interface JSContextTestVC ()
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) CGHJSTimer *jsTimerManager;
@end

@implementation JSContextTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.greenColor;
    self.jsTimerManager = CGHJSTimer.new;
    [self jsInitWithName:@"jsContext"];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"init js" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    UIButton *testBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 250, 100, 100)];
    [testBtn1 setTitle:@"执行js" forState:UIControlStateNormal];
    testBtn1.backgroundColor = UIColor.redColor;
    [testBtn1 addTarget:self action:@selector(testBtn1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn1];
}

- (void)jsInitWithName:(NSString *)name {
    self.jsContext = [[JSContext alloc] init];
    self.jsContext.name = name ?: @"appserviceJSContext";
//    NSString *js = @"var global={CGJSCore:{handle:function(arg){return arg}}}";
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index.js" ofType:nil];
//    NSString *basePath = [filePath stringByDeletingLastPathComponent];
//    NSURL *baseUrl = [NSURL fileURLWithPath:basePath];
//    [self.jsContext evaluateScript:js withSourceURL:baseUrl];
//    JSValue *globalCGJSCore = [self.jsContext evaluateScript:@"global.CGJSCore"];
//    globalCGJSCore[@"handle"] = ^id(NSString *str) {
//        // NSLog(@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL));
//        __block id response;
//        dispatch_semaphore_t s = dispatch_semaphore_create(0);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            response = [NSString stringWithFormat:@"%@ __ from native", str];
//            dispatch_semaphore_signal(s);
//        });
//        dispatch_semaphore_wait(s, DISPATCH_TIME_FOREVER);
//        return response;
//    };
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index.js" ofType:nil];
    NSString *basePath = [filePath stringByDeletingLastPathComponent];
    NSURL *baseUrl = [NSURL fileURLWithPath:basePath];

    NSError *error = nil;
    NSString *js = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
    [self.jsContext evaluateScript:js withSourceURL:baseUrl];
}

- (void)testBtn:(UIButton *)sender {
    [self.jsTimerManager registerInto:self.jsContext forKeyedSubscript:@"__timers__"];
}

- (void)testBtn1:(UIButton *)sender {
    
//    JSValue *value = [self.jsContext objectForKeyedSubscript:@"global"];
//    JSValue *value1 = [self.jsContext evaluateScript:@"global"];
//    JSValue *value2 = [self.jsContext evaluateScript:@"global.CGJSCore.handle"];
//    NSLog(@"");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"indexa.js" ofType:nil];
    NSString *basePath = [filePath stringByDeletingLastPathComponent];
    NSURL *baseUrl = [NSURL fileURLWithPath:basePath];

    NSError *error = nil;
    NSString *js = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
    [self.jsContext evaluateScript:js withSourceURL:baseUrl];
}

@end
