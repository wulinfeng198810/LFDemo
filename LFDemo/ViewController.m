//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import "YYCache_TestVC.h"
#import <YYKit.h>

#define DY_APPSTORE 1

@interface ViewController ()
@property (nonatomic, strong) YYLabel *agressLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if !DY_APPSTORE
    NSLog(@"1111");
#endif
    NSLog(@"4444");
#if !DY_APPSTORE
    NSLog(@"2222");
#endif
    NSLog(@"3333");
}

- (IBAction)testAction:(id)sender {
    UIViewController *vc = [[YYCache_TestVC alloc] initWithNibName:@"YYCache_TestVC" bundle:NSBundle.mainBundle];
//    [self.navigationController pushViewController:NSClassFromString(@"UITextFieldViewTestVC").new animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
