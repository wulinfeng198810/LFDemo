//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import "Test/TableView/LFOptimazeTableVC.h"
#import "Test/NSNotificationCenter/NSNotificationCenterVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)testAction:(id)sender {
    [self.navigationController pushViewController:NSNotificationCenterVC.new animated:YES];
}

@end
