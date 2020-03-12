//
//  JSContextTestVC.m
//  LFDemo
//
//  Created by wulinfeng on 2019/10/31.
//  Copyright © 2019 lio. All rights reserved.
//

#import "JSContextTestVC.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSContextTestVC ()
@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation JSContextTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.jsContext = [[JSContext alloc] init];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"执行js" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (void)testBtn:(UIButton *)sender {
    [sender removeFromSuperview];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index.js" ofType:nil];
    NSString *basePath = [filePath stringByDeletingLastPathComponent];
    NSURL *baseUrl = [NSURL fileURLWithPath:basePath];

    NSError *error = nil;
    NSString *js = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:&error];
    [self.jsContext evaluateScript:js withSourceURL:baseUrl];
}

@end
