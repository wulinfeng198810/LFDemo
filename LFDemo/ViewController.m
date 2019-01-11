//
//  ViewController.m
//  LFDemo
//
//  Created by LioWu on 2018/11/4.
//  Copyright © 2018年 lio. All rights reserved.
//

#import "ViewController.h"
#import "UITextFieldTestVC.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testAction:(id)sender {
    UIViewController *vc = [[UITextFieldTestVC alloc] initWithNibName:@"UITextFieldTestVC" bundle:NSBundle.mainBundle];
//    [self.navigationController pushViewController:NSClassFromString(@"UITextFieldViewTestVC").new animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
