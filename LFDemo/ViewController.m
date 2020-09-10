//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/UTCoreTypes.h>
#import <YYKit.h>
#import "LFAbstractActionSheet.h"

#define DY_APPSTORE 1

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
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
//    UIViewController *vc = [[TestAudioVC alloc] initWithNibName:@"TestAudioVC" bundle:NSBundle.mainBundle];
////    [self.navigationController pushViewController:NSClassFromString(@"JSContextTestVC").new animated:YES];
//    [self.navigationController pushViewController:vc animated:YES];
    
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [testBtn setTitle:@"测试" forState:UIControlStateNormal];
    testBtn.backgroundColor = UIColor.redColor;
    [testBtn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
    
    LFAbstractActionSheet *picker = [[LFAbstractActionSheet alloc] init];
    [picker show:testBtn inContainer:self.view];
}

@end
