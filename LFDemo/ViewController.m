//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import <YYKit.h>
#import "JSContextTestVC.h"

#define DY_APPSTORE 1

@interface ViewController ()
@property (nonatomic, strong) UILabel *badgeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
}

- (IBAction)testAction:(id)sender {
//    UIViewController *vc = [[TestFileDownloadTableVC alloc] initWithNibName:@"TestFileDownloadTableVC" bundle:NSBundle.mainBundle];
    [self.navigationController pushViewController:NSClassFromString(@"JSContextTestVC").new animated:YES];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
