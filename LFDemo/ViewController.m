//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testAction:(id)sender {
    [self.navigationController pushViewController:NSClassFromString(@"LFTextShowAllVC").new animated:YES];
}

@end
