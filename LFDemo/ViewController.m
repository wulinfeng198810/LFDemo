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
#import "CGHContactsUtil.h"

#define DY_APPSTORE 1

@interface ViewController ()
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) CGHContactsUtil *util;
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
//    [self.navigationController pushViewController:NSClassFromString(@"JSContextTestVC").new animated:YES];
//    [self.navigationController pushViewController:vc animated:YES];
    
    _util = CGHContactsUtil.new;
//    [_util addNewContact:nil presentingVC:self noGrantedHandler:nil cancelHandler:nil completeHandler:^(BOOL success) {
//        ;
//    }];
    
    
//    [_util chooseContact:self noGrantedHandler:^{
//        ;
//    } cancelHandler:^{
//        ;
//    } completeHandler:^(NSDictionary * _Nonnull contact) {
//        NSLog(@"%@", contact);
//    }];
    
//    [_util editContact:self noGrantedHandler:^{
//        ;
//    } cancelHandler:^{
//        ;
//    } completeHandler:^{
//        NSLog(@"111");
//    }];
    
    NSDictionary *dict =
  @{@"familyName": @(4444),
    @"middleName": @"middleName",
    @"givenName": @"givenName",
    @"nickname": @"nickname",
    @"organization": @"organization",
    @"title": @"title",
    @"homePhoneNumber": @"15712079019",
    @"workPhoneNumber": @(110),
    @"homeAddressCity": @"深圳市",
    @"addressCity": @"长沙市",
    @"remark": @(12321),
    @"url": @"www.baidu.com",
    @"email": @"1111@qq.com"
    };
    
    [_util addNewContact:dict presentingVC:self noGrantedHandler:^{
        ;
    } cancelHandler:^{
        ;
    } completeHandler:^{
        NSLog(@"222");
    }];
}

@end
